# Arquitetura do Projeto

## 📐 Visão Geral

Este documento descreve a arquitetura do ambiente de desenvolvimento n8n local.

## 🏗️ Componentes

### 1. Container n8n

**Imagem Base**: Node.js 22 (Debian-based)

**Customizações**:

- Shell: Fish (substituindo bash)
- Ferramentas: curl, wget, fish
- n8n instalado globalmente via npm

**Configuração**:

- **Porta**: 5678 (mapeada para o host)
- **Volume**: `n8n_data:/usr/src/app`
- **Comando**: `sleep infinity` (mantém container ativo)

**Variáveis de Ambiente**:

```yaml
DB_TYPE: postgresdb # Tipo de banco de dados
DB_POSTGRESDB_DATABASE: n8n_base # Nome do banco
DB_POSTGRESDB_HOST: postgres # Host (nome do serviço)
DB_POSTGRESDB_PORT: 5432 # Porta do PostgreSQL
DB_POSTGRESDB_USER: admin # Usuário do banco
DB_POSTGRESDB_SCHEMA: public # Schema
DB_POSTGRESDB_PASSWORD: admin # Senha
```

### 2. Container PostgreSQL

**Imagem**: postgres:18.0

**Configuração**:

- **Porta**: 5432 (mapeada para o host)
- **Volume**: `postgres_data:/var/lib/postgresql/data`
- **Limites de Recursos**:
  - CPU: 0.5 cores (50% de um core)
  - Memória: 1GB

**Variáveis de Ambiente**:

```yaml
POSTGRES_USER: admin # Usuário administrador
POSTGRES_PASSWORD: admin # Senha do admin
POSTGRES_DB: n8n_base # Banco criado na inicialização
```

## 🔄 Fluxo de Dados

```
┌─────────────────┐
│   Navegador     │
│   localhost:5678│
└────────┬────────┘
         │
         │ HTTP
         ▼
┌─────────────────┐
│  Container n8n  │
│  Porta: 5678    │
└────────┬────────┘
         │
         │ PostgreSQL Protocol
         ▼
┌─────────────────┐
│   PostgreSQL    │
│   Porta: 5432   │
└─────────────────┘
```

## 💾 Persistência de Dados

### Volumes Docker

1. **n8n_data**

   - Propósito: Armazenar dados da aplicação n8n
   - Montagem: `/usr/src/app`
   - Tipo: Named volume

2. **postgres_data**
   - Propósito: Armazenar dados do PostgreSQL
   - Montagem: `/var/lib/postgresql/data`
   - Tipo: Named volume

### Estratégia de Backup

Para fazer backup dos dados:

```bash
# Usando script helper (Recomendado)
./n8n.sh backup

# Ou manualmente com Docker Compose v2
docker compose exec postgres pg_dump -U admin n8n_base > backup.sql

# ou v1
docker-compose exec postgres pg_dump -U admin n8n_base > backup.sql

# Restaurar backup
./n8n.sh restore backup.sql
# ou
docker compose exec -T postgres psql -U admin n8n_base < backup.sql
```

## 🌐 Rede

**Nome**: `ai_network_default`

**Tipo**: Bridge (padrão)

**Serviços Conectados**:

- n8n (ai_n8n)
- postgres (ai_postgres)

**Comunicação**:

- Os containers se comunicam usando os nomes dos serviços como hostname
- Resolução DNS automática fornecida pelo Docker

## 🔧 Dev Container

### Configuração

O Dev Container estende a configuração base com:

1. **Compose Override**:

   - Monta o diretório atual em `/usr/src/app:cached`
   - Sobrescreve o comando para `sleep infinity`

2. **Workspace**:
   - Folder: `/usr/src/app`
   - Service: n8n

### Benefícios

- Desenvolvimento isolado
- Ambiente consistente entre desenvolvedores
- Integração com VS Code
- Hot-reload de mudanças

## 🔒 Segurança

### ⚠️ Considerações de Segurança

**Ambiente de Desenvolvimento**:

- Credenciais fixas e simples (admin/admin)
- Portas expostas no host
- Sem SSL/TLS

**Para Produção**:

- [ ] Usar credenciais fortes e únicas
- [ ] Implementar secrets management
- [ ] Configurar SSL/TLS
- [ ] Restringir acesso às portas
- [ ] Implementar autenticação adicional
- [ ] Configurar backups automáticos
- [ ] Usar variáveis de ambiente externas

## 📊 Recursos e Limites

### PostgreSQL

```yaml
limits:
  cpus: "0.5" # 50% de um core CPU
  memory: "1GB" # 1 Gigabyte de RAM
```

**Justificativa**:

- Evita uso excessivo de recursos
- Adequado para desenvolvimento local
- Pode ser ajustado conforme necessidade

### n8n

- Sem limites definidos
- Usa recursos conforme disponibilidade
- Recomendado para ambientes com workflows complexos

## 🔄 Ciclo de Vida dos Containers

### Inicialização

1. Docker Compose inicia o serviço PostgreSQL
2. PostgreSQL cria banco `n8n_base` se não existir
3. Docker Compose aguarda PostgreSQL estar pronto
4. Container n8n inicia
5. n8n conecta ao PostgreSQL usando variáveis de ambiente

### Dependências

```yaml
depends_on:
  - "postgres"
```

- n8n só inicia após postgres estar disponível
- Garante ordem de inicialização correta

## 🎯 Decisões Arquiteturais

### Por que Node.js 22?

- Versão LTS mais recente
- Melhor performance
- Suporte a features modernas do JavaScript

### Por que PostgreSQL 18.0?

- Compatibilidade com n8n
- Performance superior
- Features robustas de ACID

### Por que Fish Shell?

- Sintaxe mais amigável
- Auto-sugestões inteligentes
- Melhor experiência de desenvolvimento

### Por que `sleep infinity`?

- Mantém container ativo para desenvolvimento
- Permite executar n8n manualmente
- Facilita debugging e testes

## 📈 Escalabilidade

### Limitações Atuais

- Single container para n8n
- Single container para PostgreSQL
- Sem load balancing
- Sem replicação de dados

### Possíveis Melhorias

1. **Alta Disponibilidade**:

   - PostgreSQL com replicação
   - Múltiplas instâncias n8n
   - Load balancer (nginx/traefik)

2. **Performance**:

   - Redis para cache
   - CDN para assets estáticos
   - Otimização de queries

3. **Monitoramento**:
   - Prometheus para métricas
   - Grafana para dashboards
   - Logs centralizados

## 🔗 Referências

- [n8n Documentation](https://docs.n8n.io/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/18/)
- [Dev Containers Specification](https://containers.dev/)
