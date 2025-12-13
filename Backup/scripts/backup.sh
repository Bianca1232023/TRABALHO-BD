#!/bin/bash

# Script para execução manual de backup com pgBackRest (Local - sem Docker)
# Banco: Star Wars

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

STANZA="star_wars"
CONFIG_FILE="/etc/pgbackrest/pgbackrest.conf"

show_help() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}   pgBackRest Backup Script - Star Wars DB${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
    echo "Uso: $0 [OPÇÃO]"
    echo ""
    echo "Opções:"
    echo "  init        Inicializa o pgBackRest (criar stanza) - EXECUTAR PRIMEIRO!"
    echo "  full        Executa backup completo"
    echo "  diff        Executa backup diferencial"
    echo "  incr        Executa backup incremental"
    echo "  info        Exibe informações dos backups"
    echo "  check       Verifica integridade do backup"
    echo "  list        Lista todos os backups disponíveis"
    echo "  expire      Remove backups antigos conforme política de retenção"
    echo "  help        Exibe esta mensagem de ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 full     # Backup completo"
    echo "  $0 info     # Ver status dos backups"
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

run_backup() {
    local type=$1
    log "Iniciando backup ${type}..."
    
    if pgbackrest --stanza=$STANZA --config=$CONFIG_FILE backup --type=$type; then
        log "Backup ${type} concluído com sucesso!"
        show_info
    else
        log_error "Falha no backup ${type}!"
        exit 1
    fi
}

show_info() {
    log "Informações dos backups:"
    echo ""
    pgbackrest --stanza=$STANZA --config=$CONFIG_FILE info
}

check_backup() {
    log "Verificando integridade dos backups..."
    if pgbackrest --stanza=$STANZA --config=$CONFIG_FILE check; then
        log "Verificação concluída - Tudo OK!"
    else
        log_error "Problemas encontrados na verificação!"
        exit 1
    fi
}

list_backups() {
    log "Lista de backups disponíveis:"
    echo ""
    pgbackrest --stanza=$STANZA --config=$CONFIG_FILE info --output=json | python3 -m json.tool 2>/dev/null || \
    pgbackrest --stanza=$STANZA --config=$CONFIG_FILE info
}

expire_backups() {
    log "Removendo backups antigos conforme política de retenção..."
    pgbackrest --stanza=$STANZA --config=$CONFIG_FILE expire
    log "Limpeza concluída!"
}

create_stanza() {
    log "Criando stanza ${STANZA}..."
    if pgbackrest --stanza=$STANZA --config=$CONFIG_FILE stanza-create; then
        log "Stanza criada com sucesso!"
    else
        log_error "Falha ao criar stanza!"
        exit 1
    fi
}

# Main
case "${1:-help}" in
    full)
        run_backup "full"
        ;;
    diff)
        run_backup "diff"
        ;;
    incr)
        run_backup "incr"
        ;;
    info)
        show_info
        ;;
    check)
        check_backup
        ;;
    list)
        list_backups
        ;;
    expire)
        expire_backups
        ;;
    init)
        create_stanza
        ;;
    help|*)
        show_help
        ;;
esac