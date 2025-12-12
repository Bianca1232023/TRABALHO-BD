# 🗄️ Sistema de Backup - PostgreSQL com pgBackRest (Local)

Sistema de backup para o banco de dados **Star Wars** usando **pgBackRest** 
## 📋 Índice

- [Requisitos](#requisitos)
- [Instalação Rápida](#instalação-rápida)
- [Instalação Manual](#instalação-manual)
- [Comandos de Backup](#comandos-de-backup)
- [Comandos de Restauração](#comandos-de-restauração)
- [Agendamento Automático](#agendamento-automático)
- [Troubleshooting](#troubleshooting)

## 📦 Requisitos

- PostgreSQL 15+ instalado
- Sistema Operacional: **Windows**, **macOS** ou **Linux**
- Homebrew (para macOS)
- WSL ou Git Bash (para Windows - opcional)

## 🚀 Instalação Rápida

### macOS / Linux
```bash
# 1. Executar script de instalação
cd Backup/scripts
chmod +x install.sh
./install.sh

# 2. Configurar PostgreSQL (editar postgresql.conf)
# Adicionar as linhas indicadas pelo script

# 3. Reiniciar PostgreSQL
brew services restart postgresql@15   # macOS
# ou
sudo systemctl restart postgresql     # Linux

# 4. Inicializar e fazer primeiro backup
./backup.sh init
./backup.sh full
```

### Windows
```powershell
# 1. Executar script de instalação (PowerShell como Administrador)
cd Backup\scripts
.\install.ps1

# 2. Configurar PostgreSQL (editar postgresql.conf)
# Adicionar as linhas indicadas pelo script

# 3. Reiniciar PostgreSQL
net stop postgresql-x64-15
net start postgresql-x64-15

# 4. Inicializar e fazer primeiro backup
.\backup.ps1 init
.\backup.ps1 full
```

## 🔧 Instalação Manual

### 1. Instalar pgBackRest

**macOS:**
```bash
brew install pgbackrest
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt-get update
sudo apt-get install -y pgbackrest
```

**Windows:**
```powershell
# Opção 1: Baixar binário oficial
# Acesse: https://github.com/pgbackrest/pgbackrest/releases
# Baixe o arquivo .exe e adicione ao PATH

# Opção 2: Usando Chocolatey
choco install pgbackrest

# Opção 3: Usando WSL (Windows Subsystem for Linux)
wsl sudo apt-get install pgbackrest
```

### 2. Criar diretórios

**macOS / Linux:**
```bash
sudo mkdir -p /var/lib/pgbackrest
sudo mkdir -p /var/log/pgbackrest
sudo mkdir -p /var/spool/pgbackrest
sudo mkdir -p /etc/pgbackrest

# Ajustar permissões
sudo chown -R $(whoami) /var/lib/pgbackrest
sudo chown -R $(whoami) /var/log/pgbackrest
sudo chown -R $(whoami) /var/spool/pgbackrest
```

**Windows (PowerShell como Administrador):**
```powershell
# Criar diretórios
New-Item -ItemType Directory -Force -Path "C:\pgbackrest\repo"
New-Item -ItemType Directory -Force -Path "C:\pgbackrest\log"
New-Item -ItemType Directory -Force -Path "C:\pgbackrest\spool"
New-Item -ItemType Directory -Force -Path "C:\pgbackrest\config"
```

### 3. Copiar configuração

**macOS / Linux:**
```bash
sudo cp config/pgbackrest.conf /etc/pgbackrest/pgbackrest.conf
```

**Windows:**
```powershell
Copy-Item config\pgbackrest-windows.conf C:\pgbackrest\config\pgbackrest.conf
```

### 4. Editar configuração

Edite o arquivo de configuração e ajuste o caminho do PostgreSQL:

**macOS / Linux** (`/etc/pgbackrest/pgbackrest.conf`):
```ini
# macOS (Apple Silicon):
pg1-path=/opt/homebrew/var/postgresql@15

# macOS (Intel):
pg1-path=/usr/local/var/postgresql@15

# Linux:
pg1-path=/var/lib/postgresql/15/main
```

**Windows** (`C:\pgbackrest\config\pgbackrest.conf`):
```ini
# Windows (instalação padrão):
pg1-path=C:/Program Files/PostgreSQL/15/data
```

### 5. Configurar PostgreSQL

Adicione ao seu `postgresql.conf`:

```ini
# ==== CONFIGURAÇÕES PARA pgBackRest ====
wal_level = replica
archive_mode = on
archive_command = 'pgbackrest --stanza=star_wars archive-push %p'
archive_timeout = 60
max_wal_senders = 3
```

**Localização do postgresql.conf:**
- macOS: `/opt/homebrew/var/postgresql@15/postgresql.conf`
- Linux: `/etc/postgresql/15/main/postgresql.conf`
- Windows: `C:\Program Files\PostgreSQL\15\data\postgresql.conf`

### 6. Reiniciar PostgreSQL

```bash
# macOS
brew services restart postgresql@15

# Linux
sudo systemctl restart postgresql
```

```powershell
# Windows (PowerShell como Administrador)
net stop postgresql-x64-15
net start postgresql-x64-15

# Ou pelo pgAdmin / Serviços do Windows
```

### 7. Inicializar pgBackRest

```bash
# Criar stanza
pgbackrest --stanza=star_wars stanza-create

# Verificar configuração
pgbackrest --stanza=star_wars check

# Primeiro backup
pgbackrest --stanza=star_wars backup --type=full
```

## 📦 Comandos de Backup

### Usando os Scripts (macOS / Linux)

```bash
cd Backup/scripts
chmod +x backup.sh restore.sh

# Inicializar (primeira vez)
./backup.sh init

# Backup completo
./backup.sh full

# Backup diferencial
./backup.sh diff

# Backup incremental
./backup.sh incr

# Ver informações dos backups
./backup.sh info

# Verificar integridade
./backup.sh check

# Limpar backups antigos
./backup.sh expire
```

### Usando os Scripts (Windows - PowerShell)

```powershell
cd Backup\scripts

# Inicializar (primeira vez)
.\backup.ps1 init

# Backup completo
.\backup.ps1 full

# Backup diferencial
.\backup.ps1 diff

# Backup incremental
.\backup.ps1 incr

# Ver informações dos backups
.\backup.ps1 info

# Verificar integridade
.\backup.ps1 check
```

### Comandos Diretos do pgBackRest

```bash
# Backup completo
pgbackrest --stanza=star_wars backup --type=full

# Backup diferencial
pgbackrest --stanza=star_wars backup --type=diff

# Backup incremental
pgbackrest --stanza=star_wars backup --type=incr

# Ver informações
pgbackrest --stanza=star_wars info
```

## 🔄 Comandos de Restauração

> ⚠️ **IMPORTANTE**: Pare o PostgreSQL antes de restaurar!

### macOS / Linux
```bash
# 1. Parar PostgreSQL
brew services stop postgresql@15  # macOS
# ou
sudo systemctl stop postgresql    # Linux

# 2. Restaurar
./restore.sh latest              # Backup mais recente
./restore.sh delta               # Restauração rápida (delta)
./restore.sh point-in-time '2025-12-12 10:30:00'  # PITR
./restore.sh info                # Ver backups disponíveis

# 3. Iniciar PostgreSQL
brew services start postgresql@15  # macOS
```

### Windows (PowerShell como Administrador)
```powershell
# 1. Parar PostgreSQL
net stop postgresql-x64-15

# 2. Restaurar
.\restore.ps1 latest              # Backup mais recente
.\restore.ps1 delta               # Restauração rápida
.\restore.ps1 info                # Ver backups disponíveis

# 3. Iniciar PostgreSQL
net start postgresql-x64-15
```

## ⏰ Agendamento Automático

### macOS / Linux (crontab)

Para backups automáticos, adicione ao crontab:

```bash
crontab -e
```

Adicione:

```cron
# Backup FULL - Domingos às 02:00
0 2 * * 0 /path/to/Backup/scripts/backup.sh full >> /var/log/pgbackrest/cron.log 2>&1

# Backup DIFERENCIAL - Quartas às 02:00
0 2 * * 3 /path/to/Backup/scripts/backup.sh diff >> /var/log/pgbackrest/cron.log 2>&1

# Backup INCREMENTAL - Outros dias às 03:00
0 3 * * 1,2,4,5,6 /path/to/Backup/scripts/backup.sh incr >> /var/log/pgbackrest/cron.log 2>&1

# Verificação - Sábados às 04:00
0 4 * * 6 /path/to/Backup/scripts/backup.sh check >> /var/log/pgbackrest/cron.log 2>&1
```

### Windows (Agendador de Tarefas)

1. Abra o **Agendador de Tarefas** (Task Scheduler)
2. Clique em **Criar Tarefa Básica**
3. Configure:
   - **Nome**: Backup PostgreSQL - Full
   - **Gatilho**: Semanalmente, Domingo às 02:00
   - **Ação**: Iniciar programa
   - **Programa**: `powershell.exe`
   - **Argumentos**: `-ExecutionPolicy Bypass -File "C:\path\to\Backup\scripts\backup.ps1" full`

Repita para criar tarefas de backup diferencial e incremental.

## 📊 Política de Retenção

| Tipo | Retenção |
|------|----------|
| Full | 2 backups |
| Diferencial | 7 backups |
| WAL Archives | 14 dias |

## 🔧 Troubleshooting

### Erro: "stanza not found"
```bash
pgbackrest --stanza=star_wars stanza-create
```

### Erro: "archive_command failed"
Verifique se o pgBackRest está instalado e acessível:
```bash
which pgbackrest
pgbackrest version
```

### Erro: "unable to find primary"
Verifique o caminho do PostgreSQL em `/etc/pgbackrest/pgbackrest.conf`:
```bash
# Verificar onde está o PostgreSQL
brew info postgresql@15  # macOS
```

### Ver logs
```bash
# macOS / Linux
cat /var/log/pgbackrest/star_wars-backup.log
tail -f /var/log/pgbackrest/pgbackrest.log
```

```powershell
# Windows
Get-Content C:\pgbackrest\log\star_wars-backup.log
Get-Content C:\pgbackrest\log\pgbackrest.log -Wait
```

## 📁 Estrutura de Arquivos

```
Backup/
├── README.md                      # Esta documentação
├── config/
│   ├── pgbackrest.conf           # Config para macOS/Linux
│   ├── pgbackrest-windows.conf   # Config para Windows
│   ├── postgresql.conf           # Exemplo para PostgreSQL
│   ├── pg_hba.conf              # Exemplo de autenticação
│   └── backup-cron              # Exemplo de agendamento
└── scripts/
    ├── install.sh               # Instalação (macOS/Linux)
    ├── install.ps1              # Instalação (Windows)
    ├── backup.sh                # Backup (macOS/Linux)
    ├── backup.ps1               # Backup (Windows)
    ├── restore.sh               # Restauração (macOS/Linux)
    └── restore.ps1              # Restauração (Windows)
```

## 🎓 Tipos de Backup

| Tipo | Descrição | Uso |
|------|-----------|-----|
| **Full** | Copia todos os dados | Base para outros backups |
| **Diferencial** | Mudanças desde o último full | Semanal |
| **Incremental** | Mudanças desde qualquer backup | Diário |

---

📚 **Referência**: [pgBackRest Documentation](https://pgbackrest.org/)
