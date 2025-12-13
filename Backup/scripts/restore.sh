#!/bin/bash
# Script para restauração de backup com pgBackRest (Local - sem Docker)
# Banco: Star Wars

set -e


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

STANZA="star_wars"
CONFIG_FILE="/etc/pgbackrest/pgbackrest.conf"


OS="$(uname -s)"
if [ "$OS" = "Darwin" ]; then

    PG_DATA="/opt/homebrew/var/postgresql@15"
    PG_SERVICE="postgresql@15"
else

    PG_DATA="/var/lib/postgresql/15/main"
    PG_SERVICE="postgresql"
fi


show_help() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}   pgBackRest Restore Script - Star Wars DB${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
    echo "Uso: $0 [OPÇÃO]"
    echo ""
    echo "Opções:"
    echo "  latest              Restaura o backup mais recente"
    echo "  point-in-time TIME  Restaura para um ponto específico no tempo"
    echo "                      Formato: 'YYYY-MM-DD HH:MM:SS'"
    echo "  backup-set LABEL    Restaura um backup específico pelo label"
    echo "  delta               Restaura usando método delta (mais rápido)"
    echo "  info                Mostra backups disponíveis"
    echo "  help                Exibe esta mensagem"
    echo ""
    echo "Exemplos:"
    echo "  $0 latest"
    echo "  $0 point-in-time '2025-12-12 10:30:00'"
    echo "  $0 delta"
    echo ""
    echo -e "${YELLOW}ATENÇÃO: A restauração requer que o PostgreSQL esteja PARADO!${NC}"
    echo ""
}


log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] AVISO:${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERRO:${NC} $1"
}


check_pg_stopped() {
    if pg_isready 2>/dev/null; then
        log_error "PostgreSQL ainda está rodando!"
        log_error "Pare o PostgreSQL antes de restaurar:"
        if [ "$OS" = "Darwin" ]; then
            log_error "  brew services stop $PG_SERVICE"
        else
            log_error "  sudo systemctl stop $PG_SERVICE"
        fi
        exit 1
    fi
    log "PostgreSQL está parado - OK para restaurar"
}


restore_latest() {
    log "Iniciando restauração do backup mais recente..."
    

    if [ -d "${PG_DATA}" ] && [ "$(ls -A ${PG_DATA})" ]; then
        log_warn "Fazendo backup do diretório de dados atual..."
        mv ${PG_DATA} ${PG_DATA}.old.$(date +%Y%m%d%H%M%S)
        mkdir -p ${PG_DATA}
    fi
    
    if pgbackrest --stanza=$STANZA --config=$CONFIG_FILE restore; then
        log "Restauração concluída com sucesso!"
        log "Inicie o PostgreSQL:"
        if [ "$OS" = "Darwin" ]; then
            echo "  brew services start $PG_SERVICE"
        else
            echo "  sudo systemctl start $PG_SERVICE"
        fi
    else
        log_error "Falha na restauração!"
        exit 1
    fi
}


restore_point_in_time() {
    local target_time=$1
    log "Iniciando restauração para: ${target_time}"
    
    if [ -d "${PG_DATA}" ] && [ "$(ls -A ${PG_DATA})" ]; then
        log_warn "Fazendo backup do diretório de dados atual..."
        mv ${PG_DATA} ${PG_DATA}.old.$(date +%Y%m%d%H%M%S)
        mkdir -p ${PG_DATA}
    fi
    
    if pgbackrest --stanza=$STANZA --config=$CONFIG_FILE restore \
        --type=time \
        --target="${target_time}" \
        --target-action=promote; then
        log "Restauração PITR concluída com sucesso!"
        log "Inicie o PostgreSQL:"
        if [ "$OS" = "Darwin" ]; then
            echo "  brew services start $PG_SERVICE"
        else
            echo "  sudo systemctl start $PG_SERVICE"
        fi
    else
        log_error "Falha na restauração PITR!"
        exit 1
    fi
}


restore_delta() {
    log "Iniciando restauração delta..."
    
    if pgbackrest --stanza=$STANZA --config=$CONFIG_FILE restore --delta; then
        log "Restauração delta concluída com sucesso!"
        log "Inicie o PostgreSQL:"
        if [ "$OS" = "Darwin" ]; then
            echo "  brew services start $PG_SERVICE"
        else
            echo "  sudo systemctl start $PG_SERVICE"
        fi
    else
        log_error "Falha na restauração delta!"
        exit 1
    fi
}


restore_backup_set() {
    local backup_label=$1
    log "Iniciando restauração do backup: ${backup_label}"
    
    if [ -d "${PG_DATA}" ] && [ "$(ls -A ${PG_DATA})" ]; then
        log_warn "Fazendo backup do diretório de dados atual..."
        mv ${PG_DATA} ${PG_DATA}.old.$(date +%Y%m%d%H%M%S)
        mkdir -p ${PG_DATA}
    fi
    
    if pgbackrest --stanza=$STANZA --config=$CONFIG_FILE restore --set=$backup_label; then
        log "Restauração concluída com sucesso!"
        log "Inicie o PostgreSQL:"
        if [ "$OS" = "Darwin" ]; then
            echo "  brew services start $PG_SERVICE"
        else
            echo "  sudo systemctl start $PG_SERVICE"
        fi
    else
        log_error "Falha na restauração!"
        exit 1
    fi
}


show_info() {
    log "Backups disponíveis para restauração:"
    echo ""
    pgbackrest --stanza=$STANZA --config=$CONFIG_FILE info
}

# Main
case "${1:-help}" in
    latest)
        check_pg_stopped
        restore_latest
        ;;
    point-in-time)
        if [ -z "$2" ]; then
            log_error "Especifique o tempo alvo!"
            log_error "Exemplo: $0 point-in-time '2025-12-12 10:30:00'"
            exit 1
        fi
        check_pg_stopped
        restore_point_in_time "$2"
        ;;
    backup-set)
        if [ -z "$2" ]; then
            log_error "Especifique o label do backup!"
            show_info
            exit 1
        fi
        check_pg_stopped
        restore_backup_set "$2"
        ;;
    delta)
        restore_delta
        ;;
    info)
        show_info
        ;;
    help|*)
        show_help
        ;;
esac
