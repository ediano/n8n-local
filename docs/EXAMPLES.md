# Exemplos de Uso

## 📚 Guia de Exemplos

Este documento contém exemplos práticos de como usar o ambiente n8n local.

## 🚀 Cenários de Uso

### 1. Automação de Email

**Objetivo**: Enviar email diariamente com relatório.

**Workflow**:

1. Schedule Trigger (diário às 9h)
2. HTTP Request (buscar dados de API)
3. Function (processar dados)
4. Gmail node (enviar email)

**Comandos úteis**:

```bash
# Ver logs do n8n durante execução
docker-compose logs -f n8n
```

### 2. Webhook para Processar Dados

**Objetivo**: Receber dados via webhook e salvar no banco.

**Workflow**:

1. Webhook node (POST)
2. Function (validar dados)
3. Postgres node (inserir no banco)
4. Webhook Response (retornar confirmação)

**Testar webhook**:

```bash
curl -X POST http://localhost:5678/webhook/test \
  -H "Content-Type: application/json" \
  -d '{"name": "Teste", "email": "teste@example.com"}'
```

### 3. Integração com APIs Externas

**Objetivo**: Sincronizar dados entre dois sistemas.

**Workflow**:

1. Cron node (executar a cada hora)
2. HTTP Request (API 1 - buscar dados)
3. Function (transformar dados)
4. HTTP Request (API 2 - enviar dados)

### 4. Notificações Slack

**Objetivo**: Enviar alertas para Slack quando condição for atendida.

**Workflow**:

1. Webhook/Schedule Trigger
2. IF node (verificar condição)
3. Slack node (enviar mensagem)

### 5. Backup Automático

**Objetivo**: Fazer backup diário do banco de dados.

**Script**:

```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups"
mkdir -p $BACKUP_DIR

docker-compose exec -T postgres pg_dump -U admin n8n_base > "$BACKUP_DIR/n8n_backup_$DATE.sql"

echo "Backup criado: n8n_backup_$DATE.sql"

# Manter apenas últimos 7 backups
cd $BACKUP_DIR
ls -t | tail -n +8 | xargs -r rm
```

Tornar executável:

```bash
chmod +x backup.sh
```

Executar:

```bash
./backup.sh
```

Agendar com cron (Linux/Mac):

```bash
crontab -e
# Adicionar linha:
0 2 * * * /caminho/completo/backup.sh
```

## 🛠️ Comandos Úteis

### Gerenciamento de Workflows

```bash
# Exportar todos os workflows (via CLI do n8n)
docker-compose exec n8n fish -c "n8n export:workflow --all --output=/tmp/workflows.json"

# Copiar para host
docker cp ai_n8n:/tmp/workflows.json ./workflows_backup.json

# Importar workflows
docker cp ./workflows_backup.json ai_n8n:/tmp/workflows.json
docker-compose exec n8n fish -c "n8n import:workflow --input=/tmp/workflows.json"
```

### Gerenciamento de Credenciais

```bash
# Exportar credenciais
docker-compose exec n8n fish -c "n8n export:credentials --all --output=/tmp/credentials.json"

# Copiar para host
docker cp ai_n8n:/tmp/credentials.json ./credentials_backup.json
```

⚠️ **ATENÇÃO**: Credenciais contêm informações sensíveis!

### Limpeza e Manutenção

```bash
# Limpar execuções antigas (via SQL)
docker-compose exec postgres psql -U admin n8n_base -c "
DELETE FROM execution_entity
WHERE \"stoppedAt\" < NOW() - INTERVAL '30 days';
"

# Ver tamanho do banco
docker-compose exec postgres psql -U admin n8n_base -c "
SELECT pg_size_pretty(pg_database_size('n8n_base'));
"

# Vacuum do banco (otimizar)
docker-compose exec postgres psql -U admin n8n_base -c "VACUUM FULL;"
```

## 🔧 Scripts Úteis

### Script de Inicialização Completa

```bash
#!/bin/bash
# start.sh

echo "🚀 Iniciando ambiente n8n..."

# Verificar se Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando!"
    exit 1
fi

# Parar containers existentes
echo "⏹️  Parando containers existentes..."
docker-compose down

# Iniciar serviços
echo "▶️  Iniciando serviços..."
docker-compose up -d

# Aguardar PostgreSQL estar pronto
echo "⏳ Aguardando PostgreSQL..."
sleep 5

# Verificar saúde
echo "🔍 Verificando serviços..."
docker-compose ps

echo "✅ Ambiente iniciado!"
echo "📱 Acesse: http://localhost:5678"
```

### Script de Parada Segura

```bash
#!/bin/bash
# stop.sh

echo "⏹️  Parando ambiente n8n..."

# Fazer backup antes de parar
echo "💾 Fazendo backup..."
./backup.sh

# Parar containers
echo "🛑 Parando containers..."
docker-compose down

echo "✅ Ambiente parado com segurança!"
```

### Script de Reset Completo

```bash
#!/bin/bash
# reset.sh

echo "⚠️  ATENÇÃO: Isso vai DELETAR TODOS OS DADOS!"
read -p "Tem certeza? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cancelado."
    exit 0
fi

# Backup final
echo "💾 Fazendo backup final..."
./backup.sh

# Parar e remover tudo
echo "🗑️  Removendo containers e volumes..."
docker-compose down -v

# Recriar ambiente limpo
echo "🆕 Recriando ambiente..."
docker-compose up -d

echo "✅ Ambiente resetado!"
```

### Script de Monitoramento

```bash
#!/bin/bash
# monitor.sh

echo "📊 Monitoramento n8n"
echo "===================="

# Status dos containers
echo ""
echo "📦 Status dos Containers:"
docker-compose ps

# Uso de recursos
echo ""
echo "💻 Uso de Recursos:"
docker stats --no-stream ai_n8n ai_postgres

# Tamanho dos volumes
echo ""
echo "💾 Tamanho dos Volumes:"
docker volume ls -q | grep n8n | xargs -I {} sh -c 'echo -n "{}: " && docker system df -v | grep {} | awk "{print \$3}"'

# Logs recentes
echo ""
echo "📝 Últimos Logs do n8n:"
docker-compose logs --tail=10 n8n

echo ""
echo "📝 Últimos Logs do PostgreSQL:"
docker-compose logs --tail=10 postgres
```

## 🎯 Casos de Uso Reais

### 1. Sincronização de Dados CRM → Planilha

**Contexto**: Sincronizar contatos do CRM para Google Sheets diariamente.

**Implementação**:

1. Schedule Trigger (diário às 8h)
2. HTTP Request (GET contatos do CRM)
3. Function (formatar dados)
4. Google Sheets (append rows)
5. Slack (notificar conclusão)

### 2. Processamento de Formulários Web

**Contexto**: Processar submissões de formulário via webhook.

**Implementação**:

1. Webhook Trigger
2. Function (validar campos)
3. IF (verificar se válido)
   - True: Salvar no banco + Enviar email confirmação
   - False: Retornar erro

### 3. Monitoramento de Website

**Contexto**: Verificar se site está online a cada 5 minutos.

**Implementação**:

1. Cron (a cada 5 minutos)
2. HTTP Request (verificar status)
3. IF (status != 200)
   - True: Slack/Email de alerta
   - False: Continue

### 4. Agregação de Métricas

**Contexto**: Coletar métricas de várias APIs e consolidar.

**Implementação**:

1. Schedule Trigger (a cada hora)
2. Merge node para múltiplos HTTP Requests
3. Function (agregar dados)
4. PostgreSQL (salvar métricas)
5. HTTP Request (enviar para dashboard)

## 📝 Templates de Workflow

### Template Básico de API

```json
{
  "name": "API Request Template",
  "nodes": [
    {
      "name": "Schedule",
      "type": "n8n-nodes-base.scheduleTrigger",
      "position": [250, 300]
    },
    {
      "name": "HTTP Request",
      "type": "n8n-nodes-base.httpRequest",
      "position": [450, 300]
    },
    {
      "name": "Process Data",
      "type": "n8n-nodes-base.function",
      "position": [650, 300]
    }
  ]
}
```

### Template de Webhook

```json
{
  "name": "Webhook Template",
  "nodes": [
    {
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "position": [250, 300],
      "parameters": {
        "httpMethod": "POST",
        "path": "webhook-path"
      }
    },
    {
      "name": "Respond to Webhook",
      "type": "n8n-nodes-base.respondToWebhook",
      "position": [650, 300]
    }
  ]
}
```

## 🧪 Testes

### Testar Conexão com PostgreSQL

```bash
docker-compose exec n8n fish -c "
n8n execute --workflow='Test DB Connection'
"
```

### Testar Webhook Localmente

```bash
# Enviar POST
curl -X POST http://localhost:5678/webhook/test \
  -H "Content-Type: application/json" \
  -d '{
    "user": "teste",
    "action": "create"
  }'

# Enviar GET com parâmetros
curl "http://localhost:5678/webhook/test?id=123&type=user"
```

### Testar Cron Expression

Acesse: https://crontab.guru/

Exemplos:

- `0 9 * * *` - Diariamente às 9h
- `*/5 * * * *` - A cada 5 minutos
- `0 0 * * 0` - Todo domingo à meia-noite

## 📚 Recursos Adicionais

### Documentação de Nodes

- [Todos os nodes n8n](https://docs.n8n.io/integrations/builtin/app-nodes/)
- [Core nodes](https://docs.n8n.io/integrations/builtin/core-nodes/)

### Exemplos da Comunidade

- [n8n Workflows](https://n8n.io/workflows/)
- [Templates oficiais](https://n8n.io/workflows/categories)

### APIs Úteis para Testar

- [JSONPlaceholder](https://jsonplaceholder.typicode.com/) - API fake para testes
- [ReqRes](https://reqres.in/) - API de teste
- [HTTPBin](https://httpbin.org/) - Testes HTTP

---

**Contribua**: Se você tem um caso de uso interessante, considere adicionar aqui!
