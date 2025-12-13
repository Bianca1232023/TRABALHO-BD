# Script de Instalação do pgBackRest para Windows (PowerShell)
# Banco de dados: Star Wars
# Execute como Administrador!

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Blue
Write-Host "   Instalação do pgBackRest - Star Wars DB" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Blue


Write-Host ""
Write-Host "[1/5] Verificando pré-requisitos..." -ForegroundColor Yellow


$pgPath = "C:\Program Files\PostgreSQL\15"
if (-not (Test-Path $pgPath)) {
    Write-Host "AVISO: PostgreSQL 15 não encontrado em $pgPath" -ForegroundColor Red
    Write-Host "Ajuste os caminhos conforme sua instalação" -ForegroundColor Red
}

Write-Host ""
Write-Host "[2/5] Criando diretórios..." -ForegroundColor Yellow

$directories = @(
    "C:\pgbackrest\repo",
    "C:\pgbackrest\log",
    "C:\pgbackrest\spool",
    "C:\pgbackrest\config"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Host "  Criado: $dir" -ForegroundColor Green
    } else {
        Write-Host "  Já existe: $dir" -ForegroundColor Gray
    }
}


Write-Host ""
Write-Host "[3/5] Verificando pgBackRest..." -ForegroundColor Yellow

$pgbackrestExe = "C:\pgbackrest\pgbackrest.exe"

if (Get-Command pgbackrest -ErrorAction SilentlyContinue) {
    Write-Host "  pgBackRest já está instalado e no PATH" -ForegroundColor Green
    pgbackrest version
} elseif (Test-Path $pgbackrestExe) {
    Write-Host "  pgBackRest encontrado em $pgbackrestExe" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "  pgBackRest não encontrado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Para instalar, escolha uma opção:" -ForegroundColor Yellow
    Write-Host "  1. Chocolatey: choco install pgbackrest" -ForegroundColor Cyan
    Write-Host "  2. Download manual: https://github.com/pgbackrest/pgbackrest/releases" -ForegroundColor Cyan
    Write-Host "     Baixe o .exe e copie para C:\pgbackrest\" -ForegroundColor Cyan
    Write-Host "  3. Adicione ao PATH do sistema" -ForegroundColor Cyan
    Write-Host ""
}

# =============================================================================
# 4. COPIAR CONFIGURAÇÃO
# =============================================================================
Write-Host ""
Write-Host "[4/5] Copiando configuração..." -ForegroundColor Yellow

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configSource = Join-Path (Split-Path -Parent $scriptDir) "config\pgbackrest-windows.conf"
$configDest = "C:\pgbackrest\config\pgbackrest.conf"

if (Test-Path $configSource) {
    Copy-Item $configSource $configDest -Force
    Write-Host "  Configuração copiada para $configDest" -ForegroundColor Green
} else {
    Write-Host "  Arquivo de configuração não encontrado: $configSource" -ForegroundColor Red
}


Write-Host ""
Write-Host "[5/5] Próximos passos:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Edite C:\pgbackrest\config\pgbackrest.conf" -ForegroundColor White
Write-Host "   Ajuste o caminho pg1-path para sua instalação do PostgreSQL" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Adicione ao postgresql.conf:" -ForegroundColor White
Write-Host "   wal_level = replica" -ForegroundColor Cyan
Write-Host "   archive_mode = on" -ForegroundColor Cyan
Write-Host "   archive_command = 'pgbackrest --stanza=star_wars archive-push %p'" -ForegroundColor Cyan
Write-Host "   archive_timeout = 60" -ForegroundColor Cyan
Write-Host "   max_wal_senders = 3" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Reinicie o PostgreSQL:" -ForegroundColor White
Write-Host "   net stop postgresql-x64-15" -ForegroundColor Cyan
Write-Host "   net start postgresql-x64-15" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Inicialize o pgBackRest:" -ForegroundColor White
Write-Host "   .\backup.ps1 init" -ForegroundColor Cyan
Write-Host "   .\backup.ps1 full" -ForegroundColor Cyan
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "   Instalação concluída!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green