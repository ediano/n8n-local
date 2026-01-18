# AI N8N

Ambiente de desenvolvimento local para n8n com PostgreSQL utilizando Docker Compose.

## 📋 Sobre o Projeto

Este projeto configura um ambiente completo do n8n (ferramenta de automação de workflows) com banco de dados PostgreSQL, ideal para desenvolvimento e testes locais.

## 🚀 Tecnologias

- **n8n**: Plataforma de automação de workflows
- **PostgreSQL 18.0**: Banco de dados relacional
- **Docker & Docker Compose**: Containerização

## 📦 Pré-requisitos

- Docker instalado
- Docker Compose instalado
- Porta 3000 disponível (n8n)
- Porta 5432 disponível (PostgreSQL)

## ⚙️ Configuração

### 1. Clonar o repositório

```bash
git clone <url-do-repositorio>
cd n8n-local
```

### 2. Configurar variáveis de ambiente (opcional)

Copie o arquivo de exemplo e ajuste conforme necessário:

```bash
cp .env.example .env
```

As variáveis já estão configuradas no docker-compose.yml, mas você pode personalizá-las no arquivo .env se desejar.

### 3. Iniciar os serviços

```bash
docker compose up -d
```

### 4. Parar os serviços

```bash
docker compose down
```

### 5. Parar e remover volumes (limpar dados)

```bash
docker compose down -v
```

## 🔗 Acessos

- **n8n Interface**: http://localhost:3000
- **PostgreSQL**: localhost:5432

## 🗄️ Banco de Dados

### Credenciais PostgreSQL

- **Host**: postgres (interno) / localhost (externo)
- **Porta**: 5432
- **Database**: n8n_base
- **Usuário**: admin
- **Senha**: admin
- **Schema**: public

### Recursos do PostgreSQL

- CPU: 0.5 cores
- Memória: 1GB

## 📂 Volumes

O projeto utiliza volumes Docker para persistência de dados:

- `n8n_data`: Dados do n8n (/home/node/.n8n)
- `postgres_data`: Dados do PostgreSQL (/var/lib/postgresql)

## 🌐 Rede

- **Nome da rede**: ai_network_default
- Todos os containers estão na mesma rede para comunicação interna

## 🔧 Configurações do n8n

- Autenticação básica: Desativada
- Tipo de banco: PostgreSQL
- Porta interna: 5678 (mapeada para 3000 no host)

## 📝 Comandos Úteis

### Ver logs dos containers

```bash
docker compose logs -f
```

### Ver logs apenas do n8n

```bash
docker compose logs -f n8n
```

### Ver logs apenas do PostgreSQL

```bash
docker compose logs -f postgres
```

### Reiniciar serviços

```bash
docker compose restart
```

### Acessar shell do container n8n

```bash
docker exec -it ai_n8n sh
```

### Acessar PostgreSQL

```bash
docker exec -it ai_postgres psql -U admin -d n8n_base
```

### Backup do banco de dados

```bash
docker exec ai_postgres pg_dump -U admin n8n_base > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Restaurar backup

```bash
cat backup.sql | docker exec -i ai_postgres psql -U admin -d n8n_base
```

## 🔒 Segurança

**ATENÇÃO**: Este ambiente é configurado para desenvolvimento local. Para produção:

- Altere as senhas padrão
- Ative autenticação no n8n
- Configure SSL/TLS
- Ajuste as limitações de recursos
- Use variáveis de ambiente seguras

## 🐛 Troubleshooting

### Porta já em uso

Se as portas 3000 ou 5432 já estiverem em uso, edite o docker-compose.yml alterando o mapeamento de portas.

### Container não inicia

Verifique os logs:

```bash
docker compose logs
```

### Erro de conexão com banco de dados

Aguarde alguns segundos após iniciar os containers. O PostgreSQL pode levar um tempo para estar completamente disponível.

## 📄 Licença

Consulte o arquivo [LICENSE](LICENSE) para mais detalhes.
