#!/bin/bash
# Script de Instalação e Configuração do pgBackRest para macOS/Linux
# Banco de dados: Star Wars

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}   Instalação do pgBackRest - Star Wars DB${NC}"
echo -e "${BLUE}============================================${NC}"


OS="$(uname -s)"
echo -e "${GREEN}Sistema detectado:${NC} $OS"


echo ""
echo -e "${YELLOW}[1/5] Instalando pgBackRest...${NC}"

if [ "$OS" = "Darwin" ]; then

    if ! command -v brew &> /dev/null; then
        echo -e "${RED}Homebrew não encontrado. Instale em: https://brew.sh${NC}"
        exit 1
    fi
    
    if ! command -v pgbackrest &> /dev/null; then
        brew install pgbackrest
    else
        echo "pgBackRest já está instalado"
    fi
elif [ "$OS" = "Linux" ]; then

    if ! command -v pgbackrest &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y pgbackrest
    else
        echo "pgBackRest já está instalado"
    fi
fi

pgbackrest version


echo ""
echo -e "${YELLOW}[2/5] Criando diretórios...${NC}"


sudo mkdir -p /var/lib/pgbackrest
sudo mkdir -p /var/log/pgbackrest
sudo mkdir -p /var/spool/pgbackrest
sudo mkdir -p /etc/pgbackrest


if [ "$OS" = "Darwin" ]; then
    PG_USER=$(whoami)
else
    PG_USER="postgres"
fi

sudo chown -R $PG_USER /var/lib/pgbackrest
sudo chown -R $PG_USER /var/log/pgbackrest
sudo chown -R $PG_USER /var/spool/pgbackrest

echo "Diretórios criados com sucesso!"

echo ""
echo -e "${YELLOW}[3/5] Configurando pgBackRest...${NC}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")/config"


sudo cp "$CONFIG_DIR/pgbackrest.conf" /etc/pgbackrest/pgbackrest.conf

echo "Configuração copiada para /etc/pgbackrest/pgbackrest.conf"


echo ""
echo -e "${YELLOW}[4/5] Configurando PostgreSQL para backup...${NC}"

echo ""
echo -e "${YELLOW}Adicione estas linhas ao seu postgresql.conf:${NC}"
echo ""
cat << 'EOF'
# ==== CONFIGURAÇÕES PARA pgBackRest ====
wal_level = replica
archive_mode = on
archive_command = 'pgbackrest --stanza=star_wars archive-push %p'
archive_timeout = 60
max_wal_senders = 3
EOF

echo ""
echo -e "${YELLOW}E reinicie o PostgreSQL:${NC}"
if [ "$OS" = "Darwin" ]; then
    echo "  brew services restart postgresql@15"
else
    echo "  sudo systemctl restart postgresql"
fi


echo ""
echo -e "${YELLOW}[5/5] Próximos passos:${NC}"
echo ""
echo "1. Edite /etc/pgbackrest/pgbackrest.conf com seu caminho do PostgreSQL"
echo ""
echo "2. Crie a stanza:"
echo "   pgbackrest --stanza=star_wars stanza-create"
echo ""
echo "3. Verifique a configuração:"
echo "   pgbackrest --stanza=star_wars check"
echo ""
echo "4. Execute o primeiro backup:"
echo "   pgbackrest --stanza=star_wars backup --type=full"
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}   Instalação concluída!${NC}"
echo -e "${GREEN}============================================${NC}"