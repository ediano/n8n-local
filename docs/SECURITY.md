# Guia de Segurança

## 🔒 Visão Geral de Segurança

Este documento contém práticas recomendadas de segurança para o ambiente n8n local.

## ⚠️ IMPORTANTE: Ambiente de Desenvolvimento

Este projeto é configurado para **DESENVOLVIMENTO LOCAL** e não deve ser exposto à internet sem as devidas modificações de segurança.

**Riscos do ambiente padrão**:

- Credenciais fixas e simples
- Sem SSL/TLS
- Sem autenticação adicional
- Portas expostas no host
- Sem rate limiting
- Sem monitoramento de segurança

## 🎯 Níveis de Segurança

### Nível 1: Desenvolvimento Local (Atual)

✅ **Aceitável para**:

- Desenvolvimento em máquina local
- Testes isolados
- Aprendizado

❌ **NÃO usar para**:

- Produção
- Dados sensíveis
- Acesso via internet

### Nível 2: Desenvolvimento em Equipe

**Melhorias necessárias**:

1. **Usar arquivo .env para credenciais**:

```bash
# .env
POSTGRES_USER=usuario_unico
POSTGRES_PASSWORD=senha_forte_aleatoria
POSTGRES_DB=n8n_dev

N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=senha_forte_admin
```

2. **Adicionar .env ao .gitignore**:

```bash
echo ".env" >> .gitignore
```

3. **Criar .env.example**:

```bash
# .env.example (sem valores reais)
POSTGRES_USER=
POSTGRES_PASSWORD=
POSTGRES_DB=
N8N_BASIC_AUTH_USER=
N8N_BASIC_AUTH_PASSWORD=
```

### Nível 3: Produção

**Requisitos obrigatórios**:

1. SSL/TLS
2. Firewall configurado
3. Autenticação forte
4. Backups automáticos
5. Monitoramento
6. Atualizações regulares
7. Secrets management
8. Rede isolada
9. Rate limiting
10. Logs de auditoria

## 🔐 Práticas Recomendadas

### 1. Credenciais

#### ❌ Nunca Faça

```yaml
# docker-compose.yml
environment:
  - POSTGRES_PASSWORD=admin # Senha fraca e hardcoded
```

#### ✅ Faça Isso

```yaml
# docker-compose.yml
environment:
  - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
```

```bash
# .env (não versionado)
POSTGRES_PASSWORD=S3nh@F0rt3_C0mpl3x4_Al34t0r14
```

#### Gerar Senhas Fortes

```bash
# Linux/Mac
openssl rand -base64 32

# Ou
head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32
```

### 2. Variáveis de Ambiente Sensíveis

**Variáveis que DEVEM estar em .env**:

- Senhas de banco de dados
- Chaves de API
- Tokens de autenticação
- Chaves de encriptação
- SMTP passwords
- OAuth secrets

**Exemplo .env completo**:

```env
# PostgreSQL
POSTGRES_USER=n8n_user
POSTGRES_PASSWORD=sua_senha_super_forte_aqui
POSTGRES_DB=n8n_production

# n8n Basic Auth
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=outra_senha_forte

# n8n Encryption
N8N_ENCRYPTION_KEY=sua_chave_de_32_caracteres_hex

# SMTP (se usar)
N8N_SMTP_HOST=smtp.gmail.com
N8N_SMTP_PORT=587
N8N_SMTP_USER=seu-email@gmail.com
N8N_SMTP_PASS=senha_app_gmail
N8N_SMTP_SENDER=seu-email@gmail.com

# Webhook
WEBHOOK_URL=https://seu-dominio.com/
```

### 3. Exposição de Portas

#### ❌ Desenvolvimento

```yaml
ports:
  - "5432:5432" # PostgreSQL exposto - risco de segurança
```

#### ✅ Produção

```yaml
# Não expor PostgreSQL
# ports:
#   - "5432:5432"

# Apenas n8n via proxy reverso
```

### 4. Rede Docker

#### Isolar Serviços

```yaml
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true # Sem acesso externo

services:
  n8n:
    networks:
      - frontend
      - backend

  postgres:
    networks:
      - backend # Apenas rede interna
```

### 5. Volumes e Permissões

```yaml
volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: none
      device: /caminho/seguro/com/permissoes/restritas
      o: bind
```

```bash
# Configurar permissões adequadas
sudo chown -R 999:999 /caminho/volumes/postgres
sudo chmod 700 /caminho/volumes/postgres
```

## 🛡️ Hardening

### Docker

```yaml
# docker-compose.yml
services:
  n8n:
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - SETGID
      - SETUID
    read_only: true
    tmpfs:
      - /tmp
```

### PostgreSQL

```yaml
postgres:
  environment:
    - POSTGRES_HOST_AUTH_METHOD=scram-sha-256
  command: >
    postgres
    -c ssl=on
    -c ssl_cert_file=/path/to/cert.pem
    -c ssl_key_file=/path/to/key.pem
```

### n8n

```yaml
environment:
  - N8N_BASIC_AUTH_ACTIVE=true
  - N8N_SECURE_COOKIE=true
  - N8N_JWT_AUTH_ACTIVE=true
  - N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
```

## 🔍 Auditoria e Monitoramento

### Logs

```yaml
services:
  n8n:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Monitorar Acessos

```bash
# Ver últimos acessos
docker-compose logs n8n | grep "GET\|POST"

# Monitorar tentativas de autenticação
docker-compose logs n8n | grep "auth"
```

### Alertas

Configure alertas para:

- Múltiplas tentativas de login falhas
- Acesso de IPs suspeitos
- Uso anormal de recursos
- Erros críticos

## 🚨 Resposta a Incidentes

### Se Suspeitar de Comprometimento

1. **Isolar imediatamente**:

```bash
docker-compose down
```

2. **Preservar evidências**:

```bash
# Copiar logs
docker-compose logs > incident_$(date +%Y%m%d_%H%M%S).log

# Backup do banco (para análise)
docker-compose exec postgres pg_dump -U admin n8n_base > incident_backup.sql
```

3. **Investigar**:

- Revisar logs
- Verificar execuções de workflows
- Checar credenciais armazenadas
- Verificar alterações não autorizadas

4. **Remediar**:

- Trocar TODAS as credenciais
- Atualizar containers
- Revisar configurações
- Reforçar segurança

5. **Documentar**:

- O que aconteceu
- Como foi detectado
- Ações tomadas
- Prevenção futura

## 🔄 Manutenção de Segurança

### Checklist Semanal

- [ ] Verificar logs de acesso
- [ ] Checar uso de recursos
- [ ] Revisar workflows ativos
- [ ] Verificar credenciais expiradas

### Checklist Mensal

- [ ] Atualizar containers
- [ ] Revisar permissões
- [ ] Testar backups
- [ ] Auditar acessos
- [ ] Verificar vulnerabilidades conhecidas

### Checklist Trimestral

- [ ] Revisar todas as configurações de segurança
- [ ] Atualizar senhas
- [ ] Renovar certificados SSL
- [ ] Revisar políticas de acesso
- [ ] Treinar equipe em segurança

## 📚 Recursos de Segurança

### Ferramentas

- [Docker Bench Security](https://github.com/docker/docker-bench-security)
- [Trivy](https://github.com/aquasecurity/trivy) - Scanner de vulnerabilidades
- [OWASP ZAP](https://www.zaproxy.org/) - Security testing

### Executar Scan de Segurança

```bash
# Scan de vulnerabilidades com Trivy
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image ai_n8n:latest

# Docker Bench
docker run --rm --net host --pid host --userns host --cap-add audit_control \
  -v /var/lib:/var/lib \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /etc:/etc --label docker_bench_security \
  docker/docker-bench-security
```

## ⚖️ Compliance

### LGPD/GDPR

Se processar dados pessoais:

- [ ] Implementar criptografia em repouso
- [ ] Implementar criptografia em trânsito
- [ ] Manter logs de acesso
- [ ] Implementar direito ao esquecimento
- [ ] Documentar processamento de dados
- [ ] Implementar consentimento explícito
- [ ] Permitir exportação de dados

### Melhores Práticas

1. **Minimização de dados**: Coletar apenas o necessário
2. **Limitação de finalidade**: Usar dados apenas para fins declarados
3. **Precisão**: Manter dados atualizados
4. **Limitação de armazenamento**: Deletar quando não necessário
5. **Integridade e confidencialidade**: Proteger adequadamente

## 🆘 Recursos de Ajuda

- [n8n Security](https://docs.n8n.io/hosting/security/)
- [Docker Security](https://docs.docker.com/engine/security/)
- [PostgreSQL Security](https://www.postgresql.org/docs/current/security.html)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)

---

**Lembre-se**: Segurança é um processo contínuo, não um estado final!
