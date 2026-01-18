# 🚀 Início Rápido

Guia de 5 minutos para começar a usar o n8n local.

## ⚡ Setup Rápido

### 1️⃣ Pré-requisitos

Certifique-se de ter instalado:

- Docker
- Docker Compose

```bash
# Verificar instalação
docker --version
docker-compose --version
```

### 2️⃣ Clonar e Iniciar

```bash
# Clonar repositório
git clone https://github.com/seu-usuario/n8n-local.git
cd n8n-local

# Iniciar ambiente
docker-compose up -d

# Aguardar containers iniciarem (30 segundos)
docker-compose ps
```

### 3️⃣ Acessar n8n

Abra seu navegador em:

```
http://localhost:5678
```

### 4️⃣ Configuração Inicial

1. Crie sua conta (dados locais)
2. Configure seu email e senha
3. Comece a criar workflows!

## 📝 Primeiro Workflow

### Exemplo: Hello World com Schedule

1. Clique em **"New Workflow"**
2. Adicione um **Schedule Trigger**
   - Mode: Every 5 minutes
3. Adicione um **Function** node
   - JavaScript Code:
   ```javascript
   return [
     {
       json: {
         message: "Hello World!",
         timestamp: new Date().toISOString(),
       },
     },
   ];
   ```
4. Adicione um **Set** node para formatar
5. Clique em **"Execute Workflow"**

🎉 Pronto! Seu primeiro workflow está funcionando!

## 🔧 Comandos Úteis

```bash
# Ver logs
docker-compose logs -f

# Parar ambiente
docker-compose down

# Reiniciar
docker-compose restart

# Entrar no container n8n
docker-compose exec n8n fish
```

## 📚 Próximos Passos

1. 📖 Leia o [README completo](README.md)
2. 🏗️ Entenda a [arquitetura](docs/ARCHITECTURE.md)
3. 💡 Veja [exemplos práticos](docs/EXAMPLES.md)
4. ❓ Consulte o [FAQ](docs/FAQ.md)
5. 🌐 Visite [n8n.io/workflows](https://n8n.io/workflows/) para templates

## 🐛 Problemas?

### n8n não abre?

```bash
# Ver se está rodando
docker-compose ps

# Ver logs
docker-compose logs n8n
```

### Porta 5678 em uso?

Altere no `docker-compose.yml`:

```yaml
ports:
  - "8080:5678" # Usar porta 8080
```

## 🆘 Ajuda

- 📚 [Documentação completa](docs/README.md)
- ❓ [FAQ](docs/FAQ.md)
- 🔒 [Segurança](docs/SECURITY.md)
- 💬 [Comunidade n8n](https://community.n8n.io/)

---

**Tempo total**: ~5 minutos ⏱️

**Pronto para automatizar!** 🎯
