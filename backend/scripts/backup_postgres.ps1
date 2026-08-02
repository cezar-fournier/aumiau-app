param([string]$OutputDirectory = ".\backups", [int]$RetentionDays = 14)

$ErrorActionPreference = "Stop"
$backend = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$output = [IO.Path]::GetFullPath((Join-Path $backend $OutputDirectory))
[IO.Directory]::CreateDirectory($output) | Out-Null
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$dump = Join-Path $output "aumiau-$timestamp.dump"
$containerDump = "/tmp/aumiau-$timestamp.dump"

docker compose -f (Join-Path $backend "compose.yaml") exec -T db pg_dump -U aumiau -d aumiau -Fc -f $containerDump
if ($LASTEXITCODE -ne 0) { throw "Falha ao gerar o backup PostgreSQL." }
docker compose -f (Join-Path $backend "compose.yaml") cp "db:$containerDump" $dump
if ($LASTEXITCODE -ne 0) { throw "Falha ao copiar o backup do container." }
docker compose -f (Join-Path $backend "compose.yaml") exec -T db rm -f $containerDump

$hash = Get-FileHash -Algorithm SHA256 -LiteralPath $dump
"$($hash.Hash.ToLower())  $([IO.Path]::GetFileName($dump))" | Set-Content -Encoding ascii -LiteralPath "$dump.sha256"
$cutoff = (Get-Date).AddDays(-$RetentionDays)
Get-ChildItem -LiteralPath $output -File | Where-Object {
    $_.LastWriteTime -lt $cutoff -and $_.Name -match '^aumiau-.*\.(dump|sha256)$'
} | Remove-Item -Force
Write-Output $dump

