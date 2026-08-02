param([Parameter(Mandatory = $true)][string]$DumpPath)

$ErrorActionPreference = "Stop"
$backend = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$dump = (Resolve-Path -LiteralPath $DumpPath).Path
$database = "aumiau_restore_check_$(Get-Date -Format 'yyyyMMddHHmmss')"
$containerDump = "/tmp/restore-check.dump"
try {
    docker compose -f (Join-Path $backend "compose.yaml") cp $dump "db:$containerDump"
    docker compose -f (Join-Path $backend "compose.yaml") exec -T db createdb -U aumiau $database
    docker compose -f (Join-Path $backend "compose.yaml") exec -T db pg_restore -U aumiau -d $database --exit-on-error $containerDump
    docker compose -f (Join-Path $backend "compose.yaml") exec -T db psql -U aumiau -d $database -v ON_ERROR_STOP=1 -c "SELECT count(*) FROM users;"
    if ($LASTEXITCODE -ne 0) { throw "A restauração de verificação falhou." }
    Write-Output "Restauração verificada com sucesso em $database."
}
finally {
    docker compose -f (Join-Path $backend "compose.yaml") exec -T db dropdb -U aumiau --if-exists $database
    docker compose -f (Join-Path $backend "compose.yaml") exec -T db rm -f $containerDump
}

