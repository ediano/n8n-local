# AI N8N

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Required-blue.svg)](https://www.docker.com/)
[![n8n](https://img.shields.io/badge/n8n-Workflow%20Automation-orange.svg)](https://n8n.io/)

## 📋 Descrição

Este projeto fornece um ambiente de desenvolvimento local para o [n8n](https://n8n.io/) (workflow automation tool) usando Docker e PostgreSQL. Inclui suporte para desenvolvimento via VS Code Dev Containers.

---

## ⚡ Início Rápido

```bash
# Clonar o repositório
git clone https://github.com/seu-usuario/n8n-local.git
cd n8n-local

# Iniciar ambiente
docker-compose up -d

# Ou use o script helper
./n8n.sh start

# Acessar n8n
# http://localhost:5678
```

💡 **Dica**: Use o script `./n8n.sh help` para ver todos os comandos disponíveis!

📖 **Primeira vez?** Veja o [Guia de Início Rápido](QUICKSTART.md)

---

## 🏗️ Arquitetura

O projeto utiliza Docker Compose para orquestrar dois serviços principais:

- **n8n**: Ferramenta de automação de workflows
- **PostgreSQL 18.0**: Banco de dados para persistência

📚 **Detalhes técnicos**: [Documentação de Arquitetura](docs/ARCHITECTURE.md)

---

## 📦 Pré-requisitos

- Docker (versão 20.10 ou superior)
- Docker Compose (versão 2.0 ou superior)
- VS Code com extensão Dev Containers (opcional, para desenvolvimento)

## 🚀 Como Usar

### Iniciar o Ambiente

```bash
docker-compose up -d
```

### Acessar o n8n

Após iniciar os containers, acesse o n8n em:

- **URL**: http://localhost:5678

### Parar o Ambiente

```bash
docker-compose down
```

### Parar e Remover Volumes (⚠️ Remove todos os dados)

```bash
docker-compose down -v
```

## 🛠️ Configuração

### n8n Container

- **Container Name**: `ai_n8n`
- **Porta**: 5678
- **Base Image**: Node.js 22
- **Shell**: Fish
- **Instalação Global**: n8n (via npm)

### PostgreSQL Container

- **Container Name**: `ai_postgres`
- **Porta**: 5432
- **Database**: n8n_base
- **Usuário**: admin
- **Senha**: admin
- **Limites de Recursos**:
  - CPU: 0.5 cores
  - Memória: 1GB

### Variáveis de Ambiente

As seguintes variáveis de ambiente são configuradas para o n8n:

```yaml
DB_TYPE: postgresdb
DB_POSTGRESDB_DATABASE: n8n_base
DB_POSTGRESDB_HOST: postgres
DB_POSTGRESDB_PORT: 5432
DB_POSTGRESDB_USER: admin
DB_POSTGRESDB_SCHEMA: public
DB_POSTGRESDB_PASSWORD: admin
```

## 📂 Estrutura do Projeto

```
.
├── .devcontainer/
│   ├── devcontainer.json       # Configuração do Dev Container
│   └── docker-compose.yml      # Override para desenvolvimento
├── .vscode/                    # Configurações do VS Code
├── docker-compose.yml          # Configuração principal dos serviços
├── Dockerfile.node             # Dockerfile customizado para n8n
├── .gitignore                  # Arquivos ignorados pelo Git
├── LICENSE                     # Licença MIT
└── README.md                   # Este arquivo
```

## 🔧 Desenvolvimento com VS Code

Este projeto inclui configuração para VS Code Dev Containers. Para usar:

1. Abra o projeto no VS Code
2. Quando solicitado, clique em "Reopen in Container"
3. Ou use o comando: `Dev Containers: Reopen in Container`

O Dev Container monta o diretório atual em `/usr/src/app` com cache para melhor performance.

## 💾 Volumes

Dois volumes Docker são criados para persistência de dados:

- `n8n_data`: Dados do n8n
- `postgres_data`: Dados do PostgreSQL

## 🌐 Rede

Uma rede Docker customizada é criada:

- **Nome**: `ai_network_default`

---

## 📚 Documentação Completa

### 📖 Guias Principais

- **[🚀 Início Rápido](QUICKSTART.md)** - Comece em 5 minutos
- **[🔧 Guia de Instalação](docs/SETUP.md)** - Instalação detalhada e configurações avançadas
- **[🏗️ Arquitetura](docs/ARCHITECTURE.md)** - Entenda a estrutura técnica
- **[💡 Exemplos](docs/EXAMPLES.md)** - Casos de uso práticos e scripts
- **[❓ FAQ](docs/FAQ.md)** - Perguntas frequentes e soluções
- **[🔒 Segurança](docs/SECURITY.md)** - Boas práticas e hardening

### 🤝 Contribuição

- **[Como Contribuir](CONTRIBUTING.md)** - Guia para contribuidores
- **[Changelog](CHANGELOG.md)** - Histórico de mudanças

### 📋 Índice Completo

Veja o [**Índice da Documentação**](docs/README.md) para lista completa.

---

## 🐛 Troubleshooting

### Problemas Comuns

**O n8n não inicia**

```bash
docker-compose logs postgres
docker-compose logs n8n
```

**Erro de conexão com o banco**

```bash
docker-compose restart
```

**Porta em uso**

Altere as portas no [docker-compose.yml](docker-compose.yml)

📖 **Mais soluções**: Consulte o [FAQ](docs/FAQ.md) com dezenas de problemas e soluções.

---

## 💡 Exemplos de Uso

### Criar Workflow Simples

1. Acesse http://localhost:5678
2. Clique em "New Workflow"
3. Adicione nodes e conecte-os
4. Execute e teste

### Backup do Banco de Dados

```bash
docker-compose exec postgres pg_dump -U admin n8n_base > backup.sql
```

### Executar n8n Manualmente

```bash
docker-compose exec n8n fish
n8n start
```

📚 **Mais exemplos**: Veja [Guia de Exemplos](docs/EXAMPLES.md) com casos de uso reais.

---

## 🔒 Segurança

⚠️ **IMPORTANTE**: Este ambiente é configurado para **desenvolvimento local**.

Para produção:

- Altere credenciais padrão
- Configure SSL/TLS
- Implemente autenticação forte
- Não exponha portas desnecessariamente

🔐 **Guia completo**: [Documentação de Segurança](docs/SECURITY.md)

---

## 🌐 Rede

Uma rede Docker customizada é criada:

- **Nome**: `ai_network_default`

## 🐛 Troubleshooting

### O n8n não inicia

1. Verifique se o PostgreSQL está rodando:

   ```bash
   docker-compose logs postgres
   ```

2. Verifique os logs do n8n:
   ```bash
   docker-compose logs n8n
   ```

### Erro de conexão com o banco de dados

1. Certifique-se de que o PostgreSQL está completamente inicializado
2. Reinicie os containers:
   ```bash
   docker-compose restart
   ```

### Resetar o ambiente

Para começar do zero:

```bash
docker-compose down -v
docker-compose up -d
```

## 📚 Recursos Adicionais

- [Documentação oficial do n8n](https://docs.n8n.io/)
- [n8n Community](https://community.n8n.io/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👤 Autor

**Ediano Silva Santos**

---

**Nota**: Este é um ambiente de desenvolvimento local. Para uso em produção, ajuste as credenciais e configurações de segurança apropriadamente.
