# Script Helper n8n.sh

## 📜 Visão Geral

O `n8n.sh` é um script helper bash que simplifica operações comuns no ambiente n8n local. Ele fornece uma interface amigável para gerenciar containers, backups e manutenção.

## 🚀 Uso Básico

### Primeira Execução

```bash
# Tornar o script executável
chmod +x n8n.sh

# Ver ajuda
./n8n.sh help
```

## 📋 Comandos Disponíveis

### Gerenciamento de Containers

#### `start` - Iniciar Ambiente

```bash
./n8n.sh start
```

**O que faz**:

- Para containers existentes
- Inicia todos os serviços (n8n e PostgreSQL)
- Aguarda 5 segundos para estabilização
- Mostra status dos containers
- Exibe URL de acesso

**Exemplo de output**:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Iniciando ambiente n8n
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ️  Aguardando serviços iniciarem...
NAME          STATUS         PORTS
ai_n8n        Up 5 seconds   0.0.0.0:5678->5678/tcp
ai_postgres   Up 5 seconds   0.0.0.0:5432->5432/tcp
✅ Ambiente iniciado!
ℹ️  Acesse: http://localhost:5678
```

#### `stop` - Parar Ambiente

```bash
./n8n.sh stop
```

**O que faz**:

- Para todos os containers
- Mantém volumes e dados

#### `restart` - Reiniciar Ambiente

```bash
./n8n.sh restart
```

**O que faz**:

- Reinicia todos os containers sem remover volumes

#### `status` - Ver Status

```bash
./n8n.sh status
```

**O que mostra**:

- Status dos containers
- Uso de recursos (CPU, memória)
- Volumes Docker

**Exemplo de output**:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Status do ambiente
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Containers:
NAME          STATUS         PORTS
ai_n8n        Up 10 minutes  0.0.0.0:5678->5678/tcp
ai_postgres   Up 10 minutes  0.0.0.0:5432->5432/tcp

💻 Recursos:
CONTAINER     CPU %   MEM USAGE / LIMIT   MEM %
ai_n8n        0.5%    180MiB / 15.6GiB    1.13%
ai_postgres   0.2%    45MiB / 1GiB        4.39%

💾 Volumes:
n8n-local_n8n_data
n8n-local_postgres_data
```

#### `logs` - Ver Logs

```bash
./n8n.sh logs [serviço]
```

**Parâmetros**:

- Sem parâmetro: mostra logs de todos os serviços
- `n8n`: mostra apenas logs do n8n
- `postgres`: mostra apenas logs do PostgreSQL

**Exemplos**:

```bash
# Todos os logs
./n8n.sh logs

# Apenas n8n
./n8n.sh logs n8n

# Apenas PostgreSQL
./n8n.sh logs postgres
```

### Backup e Restore

#### `backup` - Fazer Backup

```bash
./n8n.sh backup
```

**O que faz**:

- Cria diretório `./backups` se não existir
- Gera backup do banco PostgreSQL
- Nomeia arquivo com timestamp: `n8n_backup_YYYYMMDD_HHMMSS.sql`
- Mantém apenas os 7 backups mais recentes
- Remove backups antigos automaticamente

**Exemplo de output**:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Backup do banco de dados
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ️  Fazendo backup...
✅ Backup criado: ./backups/n8n_backup_20260117_143022.sql
ℹ️  Mantendo apenas os 7 backups mais recentes
```

#### `restore` - Restaurar Backup

```bash
./n8n.sh restore <arquivo_backup.sql>
```

**O que faz**:

- Pede confirmação (requer digitar "yes")
- Restaura backup no banco de dados
- **⚠️ SOBRESCREVE dados atuais**

**Exemplo**:

```bash
./n8n.sh restore ./backups/n8n_backup_20260117_143022.sql
```

**Exemplo de output**:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Restaurar backup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  Isso vai SOBRESCREVER os dados atuais!
Tem certeza? (yes/no): yes
ℹ️  Restaurando backup...
✅ Backup restaurado!
```

### Manutenção

#### `clean` - Limpar Execuções Antigas

```bash
./n8n.sh clean [dias]
```

**Parâmetros**:

- `dias`: número de dias para manter (padrão: 30)

**O que faz**:

- Remove execuções antigas do banco de dados
- Otimiza banco com VACUUM FULL
- Libera espaço em disco

**Exemplos**:

```bash
# Limpar execuções com mais de 30 dias
./n8n.sh clean

# Limpar execuções com mais de 60 dias
./n8n.sh clean 60

# Limpar execuções com mais de 7 dias
./n8n.sh clean 7
```

**Exemplo de output**:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Limpeza de dados antigos
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ️  Removendo execuções com mais de 30 dias...
ℹ️  Otimizando banco de dados...
✅ Limpeza concluída!
```

#### `update` - Atualizar n8n

```bash
./n8n.sh update
```

**O que faz**:

- Faz backup automático antes de atualizar
- Para containers
- Reconstrói imagem do n8n (sem cache)
- Inicia ambiente novamente
- Atualiza n8n para última versão disponível

**⚠️ Atenção**: Pode levar alguns minutos

#### `reset` - Reset Completo

```bash
./n8n.sh reset
```

**O que faz**:

- Pede confirmação (requer digitar "yes")
- Faz backup final automático
- **Remove TODOS os containers e volumes**
- Recria ambiente do zero

**⚠️ CUIDADO**: Remove todos os dados!

### Acesso aos Containers

#### `shell` - Abrir Shell

```bash
./n8n.sh shell [serviço]
```

**Parâmetros**:

- Sem parâmetro ou `n8n`: abre shell Fish no container n8n
- `postgres`: abre shell Bash no container PostgreSQL

**Exemplos**:

```bash
# Shell no n8n
./n8n.sh shell
# ou
./n8n.sh shell n8n

# Shell no PostgreSQL
./n8n.sh shell postgres
```

**Uso**:

```bash
$ ./n8n.sh shell
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Shell no container n8n
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

root@container:/usr/src/app# n8n --version
1.x.x
root@container:/usr/src/app# exit
```

#### `psql` - PostgreSQL CLI

```bash
./n8n.sh psql
```

**O que faz**:

- Abre cliente PostgreSQL (psql)
- Conecta automaticamente ao banco `n8n_base`
- Permite executar queries SQL

**Exemplo de uso**:

```bash
$ ./n8n.sh psql
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PostgreSQL CLI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

n8n_base=# \dt
n8n_base=# SELECT COUNT(*) FROM workflow_entity;
n8n_base=# \q
```

### Ajuda

#### `help` - Mostrar Ajuda

```bash
./n8n.sh help
```

**O que mostra**:

- Lista completa de comandos
- Descrição de cada comando
- Exemplos de uso

## 🔄 Workflows Comuns

### Setup Inicial

```bash
# 1. Tornar executável
chmod +x n8n.sh

# 2. Iniciar ambiente
./n8n.sh start

# 3. Verificar status
./n8n.sh status
```

### Backup Regular

```bash
# Fazer backup manual
./n8n.sh backup

# Ou criar cron job para backup automático
# Adicionar ao crontab: crontab -e
# 0 2 * * * cd /caminho/para/n8n-local && ./n8n.sh backup
```

### Manutenção Semanal

```bash
# Limpar execuções antigas
./n8n.sh clean 30

# Ver status de recursos
./n8n.sh status
```

### Desenvolvimento

```bash
# Abrir shell para testes
./n8n.sh shell

# Ver logs em tempo real
./n8n.sh logs n8n
```

### Troubleshooting

```bash
# Ver logs de erro
./n8n.sh logs

# Reiniciar ambiente
./n8n.sh restart

# Se problemas persistirem
./n8n.sh reset  # ⚠️ Remove todos os dados
```

## 🎨 Cores e Ícones

O script usa cores e ícones para melhor visualização:

- ✅ **Verde**: Sucesso
- ❌ **Vermelho**: Erro
- ⚠️ **Amarelo**: Aviso
- ℹ️ **Azul**: Informação

## 📝 Notas

### Compatibilidade

- **Docker Compose v2**: Usa `docker compose` (sem hífen)
- **Docker Compose v1**: Usa `docker-compose` (com hífen)
- O script funciona com ambas as versões

### Backups

- Backups são salvos em `./backups/`
- Apenas os 7 backups mais recentes são mantidos
- Backups são criados automaticamente em operações destrutivas (`reset`, `update`)

### Segurança

- Comandos destrutivos (`reset`, `restore`) pedem confirmação
- Requerem digitar "yes" explicitamente (não aceita "y")

### Performance

- `clean`: Executa VACUUM FULL, pode demorar em bancos grandes
- `update`: Reconstrói imagem, pode demorar alguns minutos

## 🔗 Ver Também

- [README.md](../README.md) - Documentação principal
- [QUICKSTART.md](../QUICKSTART.md) - Início rápido
- [FAQ.md](FAQ.md) - Perguntas frequentes
- [EXAMPLES.md](EXAMPLES.md) - Exemplos de uso
