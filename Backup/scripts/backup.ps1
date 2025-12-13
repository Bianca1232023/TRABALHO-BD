# Script de Backup com pgBackRest para Windows (PowerShell)
# Banco: Star Wars

param(
    [Parameter(Position=0)]
    [ValidateSet("full", "diff", "incr", "info", "check", "list", "expire", "init", "help")]
    [string]$Action = "help"
)

$ErrorActionPreference = "Stop"

$Stanza = "star_wars"
$ConfigFile = "C:\pgbackrest\config\pgbackrest.conf"

# Verificar se pgBackRest está disponível
function Test-PgBackRest {
    if (Get-Command pgbackrest -ErrorAction SilentlyContinue) {
        return "pgbackrest"
    } elseif (Test-Path "C:\pgbackrest\pgbackrest.exe") {
        return "C:\pgbackrest\pgbackrest.exe"
    } else {
        Write-Host "ERRO: pgBackRest não encontrado!" -ForegroundColor Red
        Write-Host "Execute install.ps1 primeiro" -ForegroundColor Yellow
        exit 1
    }
}

$PgBackRest = Test-PgBackRest

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor Green
}

function Write-LogError {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] ERRO: $Message" -ForegroundColor Red
}

function Write-LogWarn {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] AVISO: $Message" -ForegroundColor Yellow
}

function Show-Help {
    Write-Host "==========================================" -ForegroundColor Blue
    Write-Host "   pgBackRest Backup Script - Star Wars DB" -ForegroundColor Blue
    Write-Host "==========================================" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Uso: .\backup.ps1 [ACAO]"
    Write-Host ""
    Write-Host "Acoes:"
    Write-Host "  init     Inicializa o pgBackRest (criar stanza) - EXECUTAR PRIMEIRO!"
    Write-Host "  full     Executa backup completo"
    Write-Host "  diff     Executa backup diferencial"
    Write-Host "  incr     Executa backup incremental"
    Write-Host "  info     Exibe informacoes dos backups"
    Write-Host "  check    Verifica integridade do backup"
    Write-Host "  list     Lista todos os backups disponiveis"
    Write-Host "  expire   Remove backups antigos"
    Write-Host "  help     Exibe esta mensagem"
    Write-Host ""
    Write-Host "Exemplos:"
    Write-Host "  .\backup.ps1 init    # Primeira vez"
    Write-Host "  .\backup.ps1 full    # Backup completo"
    Write-Host "  .\backup.ps1 info    # Ver status"
    Write-Host ""
}

function New-Stanza {
    Write-Log "Criando stanza $Stanza..."
    & $PgBackRest --stanza=$Stanza --config=$ConfigFile stanza-create
    if ($LASTEXITCODE -eq 0) {
        Write-Log "Stanza criada com sucesso!"
    } else {
        Write-LogError "Falha ao criar stanza!"
        exit 1
    }
}

function Invoke-Backup {
    param([string]$Type)
    
    Write-Log "Iniciando backup $Type..."
    & $PgBackRest --stanza=$Stanza --config=$ConfigFile backup --type=$Type
    
    if ($LASTEXITCODE -eq 0) {
        Write-Log "Backup $Type concluido com sucesso!"
        Show-Info
    } else {
        Write-LogError "Falha no backup $Type!"
        exit 1
    }
}

function Show-Info {
    Write-Log "Informacoes dos backups:"
    Write-Host ""
    & $PgBackRest --stanza=$Stanza --config=$ConfigFile info
}

function Test-Backup {
    Write-Log "Verificando integridade dos backups..."
    & $PgBackRest --stanza=$Stanza --config=$ConfigFile check
    
    if ($LASTEXITCODE -eq 0) {
        Write-Log "Verificacao concluida - Tudo OK!"
    } else {
        Write-LogError "Problemas encontrados na verificacao!"
        exit 1
    }
}

function Get-BackupList {
    Write-Log "Lista de backups disponiveis:"
    Write-Host ""
    & $PgBackRest --stanza=$Stanza --config=$ConfigFile info
}

function Remove-OldBackups {
    Write-Log "Removendo backups antigos conforme politica de retencao..."
    & $PgBackRest --stanza=$Stanza --config=$ConfigFile expire
    Write-Log "Limpeza concluida!"
}

switch ($Action) {
    "init"   { New-Stanza }
    "full"   { Invoke-Backup -Type "full" }
    "diff"   { Invoke-Backup -Type "diff" }
    "incr"   { Invoke-Backup -Type "incr" }
    "info"   { Show-Info }
    "check"  { Test-Backup }
    "list"   { Get-BackupList }
    "expire" { Remove-OldBackups }
    default  { Show-Help }
}