#!/usr/bin/env bash

# n8n-local Helper Script
# Facilita operações comuns do ambiente n8n local

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções auxiliares
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Verificar se Docker está rodando
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker não está rodando!"
        exit 1
    fi
}

# Comandos
cmd_start() {
    print_header "Iniciando ambiente n8n"
    check_docker
    
    docker-compose down 2>/dev/null || true
    docker-compose up -d
    
    print_info "Aguardando serviços iniciarem..."
    sleep 5
    
    docker-compose ps
    
    print_success "Ambiente iniciado!"
    print_info "Acesse: http://localhost:5678"
}

cmd_stop() {
    print_header "Parando ambiente n8n"
    
    docker-compose down
    
    print_success "Ambiente parado!"
}

cmd_restart() {
    print_header "Reiniciando ambiente n8n"
    
    docker-compose restart
    
    print_success "Ambiente reiniciado!"
}

cmd_logs() {
    print_header "Logs do ambiente n8n"
    
    if [ -z "$1" ]; then
        docker-compose logs -f
    else
        docker-compose logs -f "$1"
    fi
}

cmd_status() {
    print_header "Status do ambiente"
    
    echo "📦 Containers:"
    docker-compose ps
    
    echo -e "\n💻 Recursos:"
    docker stats --no-stream ai_n8n ai_postgres 2>/dev/null || print_warning "Containers não estão rodando"
    
    echo -e "\n💾 Volumes:"
    docker volume ls | grep n8n-local || print_warning "Volumes não encontrados"
}

cmd_backup() {
    print_header "Backup do banco de dados"
    
    BACKUP_DIR="./backups"
    mkdir -p "$BACKUP_DIR"
    
    DATE=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/n8n_backup_$DATE.sql"
    
    print_info "Fazendo backup..."
    docker-compose exec -T postgres pg_dump -U admin n8n_base > "$BACKUP_FILE"
    
    print_success "Backup criado: $BACKUP_FILE"
    
    # Manter apenas últimos 7 backups
    cd "$BACKUP_DIR"
    ls -t *.sql 2>/dev/null | tail -n +8 | xargs -r rm
    cd - > /dev/null
    
    print_info "Mantendo apenas os 7 backups mais recentes"
}

cmd_restore() {
    if [ -z "$1" ]; then
        print_error "Uso: $0 restore <arquivo_backup.sql>"
        exit 1
    fi
    
    if [ ! -f "$1" ]; then
        print_error "Arquivo não encontrado: $1"
        exit 1
    fi
    
    print_header "Restaurar backup"
    print_warning "Isso vai SOBRESCREVER os dados atuais!"
    
    read -p "Tem certeza? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        print_info "Cancelado."
        exit 0
    fi
    
    print_info "Restaurando backup..."
    docker-compose exec -T postgres psql -U admin n8n_base < "$1"
    
    print_success "Backup restaurado!"
}

cmd_reset() {
    print_header "Reset completo do ambiente"
    print_warning "Isso vai DELETAR TODOS OS DADOS!"
    
    read -p "Tem certeza? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        print_info "Cancelado."
        exit 0
    fi
    
    # Backup antes de resetar
    print_info "Fazendo backup final..."
    cmd_backup
    
    print_info "Removendo containers e volumes..."
    docker-compose down -v
    
    print_info "Recriando ambiente..."
    docker-compose up -d
    
    print_success "Ambiente resetado!"
}

cmd_shell() {
    SERVICE=${1:-n8n}
    
    print_header "Shell no container $SERVICE"
    
    if [ "$SERVICE" = "n8n" ]; then
        docker-compose exec n8n fish
    elif [ "$SERVICE" = "postgres" ]; then
        docker-compose exec postgres bash
    else
        print_error "Serviço inválido. Use: n8n ou postgres"
        exit 1
    fi
}

cmd_psql() {
    print_header "PostgreSQL CLI"
    
    docker-compose exec postgres psql -U admin n8n_base
}

cmd_clean() {
    print_header "Limpeza de dados antigos"
    
    DAYS=${1:-30}
    
    print_info "Removendo execuções com mais de $DAYS dias..."
    
    docker-compose exec postgres psql -U admin n8n_base -c "
        DELETE FROM execution_entity 
        WHERE \"stoppedAt\" < NOW() - INTERVAL '$DAYS days';
    "
    
    print_info "Otimizando banco de dados..."
    docker-compose exec postgres psql -U admin n8n_base -c "VACUUM FULL;"
    
    print_success "Limpeza concluída!"
}

cmd_update() {
    print_header "Atualizar n8n"
    
    print_info "Fazendo backup antes de atualizar..."
    cmd_backup
    
    print_info "Parando containers..."
    docker-compose down
    
    print_info "Reconstruindo imagem..."
    docker-compose build --no-cache n8n
    
    print_info "Iniciando novamente..."
    docker-compose up -d
    
    print_success "Atualização concluída!"
}

cmd_help() {
    cat << EOF
n8n-local Helper Script
=======================

Uso: $0 <comando> [argumentos]

Comandos disponíveis:

  start              Iniciar o ambiente
  stop               Parar o ambiente
  restart            Reiniciar o ambiente
  logs [serviço]     Ver logs (n8n, postgres ou todos)
  status             Ver status de containers, recursos e volumes
  
  backup             Fazer backup do banco de dados
  restore <arquivo>  Restaurar backup
  clean [dias]       Limpar execuções antigas (padrão: 30 dias)
  
  shell [serviço]    Abrir shell (n8n ou postgres, padrão: n8n)
  psql               Abrir PostgreSQL CLI
  
  update             Atualizar n8n para última versão
  reset              Reset completo (DELETA TODOS OS DADOS)
  
  help               Mostrar esta ajuda

Exemplos:

  $0 start                    # Iniciar ambiente
  $0 logs n8n                 # Ver logs do n8n
  $0 backup                   # Fazer backup
  $0 restore backup.sql       # Restaurar backup
  $0 clean 60                 # Limpar execuções com +60 dias
  $0 shell postgres           # Abrir shell no PostgreSQL

EOF
}

# Main
COMMAND=${1:-help}

case $COMMAND in
    start)
        cmd_start
        ;;
    stop)
        cmd_stop
        ;;
    restart)
        cmd_restart
        ;;
    logs)
        shift
        cmd_logs "$@"
        ;;
    status)
        cmd_status
        ;;
    backup)
        cmd_backup
        ;;
    restore)
        shift
        cmd_restore "$@"
        ;;
    reset)
        cmd_reset
        ;;
    shell)
        shift
        cmd_shell "$@"
        ;;
    psql)
        cmd_psql
        ;;
    clean)
        shift
        cmd_clean "$@"
        ;;
    update)
        cmd_update
        ;;
    help|--help|-h)
        cmd_help
        ;;
    *)
        print_error "Comando desconhecido: $COMMAND"
        echo ""
        cmd_help
        exit 1
        ;;
esac
