# AuMiau Mail

Servidor SMTP/IMAP do domínio `aumiau.app.br`, separado do Compose da API.

O certificado TLS é obtido pelo Caddy da API para `mail.aumiau.app.br` e
montado no container do mailserver. A imagem é fixada na versão estável
15.1.0.

## Operação

```bash
docker compose up -d
docker exec -it aumiau-mailserver setup email list
docker exec -it aumiau-mailserver setup config dkim
```

O conteúdo gerado em `docker-data/dms/config/opendkim/keys/aumiau.app.br/mail.txt`
deve ser publicado como TXT em `mail._domainkey.aumiau.app.br`.

Portas para clientes:

- SMTP submission: 587 com STARTTLS.
- SMTP implicit TLS: 465.
- IMAP implicit TLS: 993.

O acesso administrativo ao servidor é feito pelo script `setup` dentro do
container. Senhas de contas ficam fora do repositório.
