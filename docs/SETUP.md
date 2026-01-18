# Guia de Instalação e Configuração

## 📋 Pré-requisitos

### Sistema Operacional

- Linux (Ubuntu, Debian, Fedora, etc.)
- macOS
- Windows (com WSL2)

### Software Necessário

#### Docker

**Linux**:

```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER
newgrp docker
```

**macOS**:

- Baixe [Docker Desktop para Mac](https://www.docker.com/products/docker-desktop)

**Windows**:

- Instale [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install)
- Baixe [Docker Desktop para Windows](https://www.docker.com/products/docker-desktop)

#### Docker Compose

O Docker Compose v2 já vem incluído no Docker Desktop e nas instalações recentes do Docker Engine.

**Linux (se necessário instalar v1)**:

```bash
# Instalar Docker Compose v1 (legado)
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

Verifique a instalação:

```bash
docker --version

# Docker Compose v2 (integrado)
docker compose version

# ou Docker Compose v1 (standalone)
docker-compose --version
```

**Nota**: Este projeto suporta ambas as versões. A documentação usa `docker compose` (v2), mas você pode usar `docker-compose` (v1) se preferir.

### Verificação de Recursos

Certifique-se de ter recursos disponíveis:

- **RAM**: Mínimo 4GB (8GB recomendado)
- **Disco**: Mínimo 10GB livres
- **CPU**: 2 cores ou mais

## 🚀 Instalação

### 1. Clone o Repositório

```bash
git clone https://github.com/seu-usuario/n8n-local.git
cd n8n-local
```

### 2. Verifique os Arquivos

```bash
ls -la
```

Você deve ver:

- `docker-compose.yml`
- `Dockerfile.node`
- `README.md`
- `.devcontainer/`
- etc.

### 3. Inicie os Serviços

```bash
# Recomendado: usar script helper
chmod +x n8n.sh
./n8n.sh start

# Ou usar Docker Compose diretamente
docker compose up -d
# ou (v1)
docker-compose up -d
```

### 4. Verifique os Containers

```bash
./n8n.sh status
# ou
docker compose ps
# ou (v1)
docker-compose ps
```

Saída esperada:

```
NAME          COMMAND                  STATUS         PORTS
ai_n8n        "sleep infinity"         Up 10 seconds  0.0.0.0:5678->5678/tcp
ai_postgres   "docker-entrypoint.s…"   Up 10 seconds  0.0.0.0:5432->5432/tcp
```

### 5. Acesse o n8n

Abra seu navegador e acesse:

```
http://localhost:5678
```

## ⚙️ Configuração Inicial do n8n

### Primeiro Acesso

1. Acesse http://localhost:5678
2. Crie uma conta de usuário (dados locais)
3. Configure suas preferências

### Executar n8n Manualmente (Opcional)

Se preferir executar o n8n manualmente dentro do container:

```bash
# Entre no container
docker-compose exec n8n fish

# Execute o n8n
n8n start
```

## 🔧 Configurações Avançadas

### Personalizar Variáveis de Ambiente

Crie um arquivo `.env`:

```bash
touch .env
```

Adicione suas variáveis:

```env
# PostgreSQL
POSTGRES_USER=seu_usuario
POSTGRES_PASSWORD=sua_senha_forte
POSTGRES_DB=n8n_production

# n8n
N8N_ENCRYPTION_KEY=sua_chave_de_encriptacao
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=senha_forte
```

Atualize o `docker-compose.yml` para usar essas variáveis:

```yaml
environment:
  - POSTGRES_USER=${POSTGRES_USER}
  - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
  # etc...
```

### Configurar SMTP (Email)

Adicione ao `docker-compose.yml` (seção n8n):

```yaml
environment:
  - N8N_EMAIL_MODE=smtp
  - N8N_SMTP_HOST=smtp.gmail.com
  - N8N_SMTP_PORT=587
  - N8N_SMTP_USER=seu-email@gmail.com
  - N8N_SMTP_PASS=sua-senha-app
  - N8N_SMTP_SENDER=seu-email@gmail.com
```

### Configurar Webhook URL

```yaml
environment:
  - WEBHOOK_URL=https://seu-dominio.com/
```

### Aumentar Limites de Recursos

Edite `docker-compose.yml`:

```yaml
postgres:
  # ...
  deploy:
    resources:
      limits:
        cpus: "1.0" # 1 core completo
        memory: "2GB" # 2GB de RAM
```

## 🐳 Comandos Docker Úteis

### Ver Logs

```bash
# Todos os serviços
docker-compose logs -f

# Apenas n8n
docker-compose logs -f n8n

# Apenas PostgreSQL
docker-compose logs -f postgres
```

### Reiniciar Serviços

```bash
# Todos
docker-compose restart

# Apenas n8n
docker-compose restart n8n
```

### Parar Serviços

```bash
docker-compose stop
```

### Remover Containers (mantém volumes)

```bash
docker-compose down
```

### Remover Tudo (⚠️ incluindo dados)

```bash
docker-compose down -v
```

### Entrar no Container

```bash
# n8n
docker-compose exec n8n fish

# PostgreSQL
docker-compose exec postgres bash
```

### Acessar PostgreSQL CLI

```bash
docker-compose exec postgres psql -U admin -d n8n_base
```

## 🔍 Verificação de Saúde

### Testar Conexão com n8n

```bash
curl http://localhost:5678/healthz
```

### Testar Conexão com PostgreSQL

```bash
docker-compose exec postgres pg_isready -U admin
```

### Verificar Uso de Recursos

```bash
docker stats
```

## 📝 VS Code Dev Container

### Pré-requisitos

1. Instale a extensão [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Usar Dev Container

1. Abra o projeto no VS Code
2. Pressione `F1` ou `Ctrl+Shift+P`
3. Digite: "Dev Containers: Reopen in Container"
4. Aguarde o ambiente ser criado

### Verificar que Está Dentro do Container

No terminal integrado do VS Code:

```bash
echo $HOSTNAME
# Deve mostrar o ID do container
```

## 🐛 Solução de Problemas

### Porta 5678 Já em Uso

```bash
# Encontrar processo usando a porta
sudo lsof -i :5678

# Ou alterar a porta no docker-compose.yml
ports:
  - "8080:5678"  # Use porta 8080 no host
```

### Porta 5432 Já em Uso

```bash
# Parar PostgreSQL local
sudo systemctl stop postgresql

# Ou alterar a porta no docker-compose.yml
ports:
  - "5433:5432"
```

### Container n8n Não Inicia

```bash
# Ver logs detalhados
docker-compose logs n8n

# Reconstruir imagem
docker-compose build --no-cache n8n
docker-compose up -d
```

### Erro de Permissão no Volume

```bash
# Verificar permissões
docker-compose exec n8n ls -la /usr/src/app

# Se necessário, ajustar permissões
docker-compose exec n8n chown -R node:node /usr/src/app
```

### PostgreSQL Não Aceita Conexões

```bash
# Verificar se está rodando
docker-compose ps postgres

# Ver logs
docker-compose logs postgres

# Reiniciar
docker-compose restart postgres
```

## 🔄 Atualização

### Atualizar n8n

```bash
# Parar serviços
docker-compose down

# Reconstruir imagem com nova versão
docker-compose build --no-cache n8n

# Iniciar novamente
docker-compose up -d
```

### Atualizar PostgreSQL

⚠️ **ATENÇÃO**: Fazer backup antes!

```bash
# Backup
docker-compose exec postgres pg_dumpall -U admin > backup.sql

# Atualizar versão no docker-compose.yml
image: postgres:19.0  # Nova versão

# Recriar container
docker-compose up -d postgres
```

## 📚 Próximos Passos

Após a instalação bem-sucedida:

1. Leia o [README.md](../README.md) para visão geral
2. Veja [ARCHITECTURE.md](ARCHITECTURE.md) para entender a estrutura
3. Consulte [exemplos de workflows](https://n8n.io/workflows/)
4. Junte-se à [comunidade n8n](https://community.n8n.io/)

## 🆘 Suporte

Se encontrar problemas:

1. Verifique os logs: `docker-compose logs`
2. Consulte a [documentação n8n](https://docs.n8n.io/)
3. Abra uma issue no repositório
4. Pergunte na comunidade n8n

## ✅ Checklist de Instalação

- [ ] Docker instalado e funcionando
- [ ] Docker Compose disponível
- [ ] Repositório clonado
- [ ] Containers iniciados com sucesso
- [ ] n8n acessível em localhost:5678
- [ ] PostgreSQL respondendo
- [ ] Conta criada no n8n
- [ ] Primeiro workflow testado
