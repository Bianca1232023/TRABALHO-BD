# Script de Restauração com pgBackRest para Windows (PowerShell)
# Banco: Star Wars
# Execute como Administrador!

param(
    [Parameter(Position=0)]
    [ValidateSet("latest", "delta", "point-in-time", "backup-set", "info", "help")]
    [string]$Action = "help",
    
    [Parameter(Position=1)]
    [string]$Target = ""
)

$ErrorActionPreference = "Stop"


$Stanza = "star_wars"
$ConfigFile = "C:\pgbackrest\config\pgbackrest.conf"
$PgData = "C:\Program Files\PostgreSQL\15\data"
$PgService = "postgresql-x64-15"


function Test-PgBackRest {
    if (Get-Command pgbackrest -ErrorAction SilentlyContinue) {
        return "pgbackrest"
    } elseif (Test-Path "C:\pgbackrest\pgbackrest.exe") {
        return "C:\pgbackrest\pgbackrest.exe"
    } else {
        Write-Host "ERRO: pgBackRest não encontrado!" -ForegroundColor Red
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
    Write-Host "   pgBackRest Restore Script - Star Wars DB" -ForegroundColor Blue
    Write-Host "==========================================" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Uso: .\restore.ps1 [ACAO] [PARAMETRO]"
    Write-Host ""
    Write-Host "Acoes:"
    Write-Host "  latest                    Restaura o backup mais recente"
    Write-Host "  delta                     Restauracao rapida (delta)"
    Write-Host "  point-in-time <DATA>      Restaura para ponto no tempo"
    Write-Host "                            Formato: 'yyyy-MM-dd HH:mm:ss'"
    Write-Host "  backup-set <LABEL>        Restaura backup especifico"
    Write-Host "  info                      Mostra backups disponiveis"
    Write-Host "  help                      Exibe esta mensagem"
    Write-Host ""
    Write-Host "Exemplos:"
    Write-Host "  .\restore.ps1 latest"
    Write-Host "  .\restore.ps1 point-in-time '2025-12-12 10:30:00'"
    Write-Host "  .\restore.ps1 info"
    Write-Host ""
    Write-Host "ATENCAO: O PostgreSQL deve estar PARADO antes da restauracao!" -ForegroundColor Yellow
    Write-Host "  net stop $PgService" -ForegroundColor Yellow
    Write-Host ""
}


function Test-PgStopped {
    $service = Get-Service -Name $PgService -ErrorAction SilentlyContinue
    
    if ($null -eq $service) {
        Write-LogWarn "Servico $PgService nao encontrado. Verifique o nome do servico."
        return $true
    }
    
    if ($service.Status -eq "Running") {
        Write-LogError "PostgreSQL ainda esta rodando!"
        Write-LogError "Pare o PostgreSQL antes de restaurar:"
        Write-LogError "  net stop $PgService"
        exit 1
    }
    
    Write-Log "PostgreSQL esta parado - OK para restaurar"
    return $true
}


function Backup-CurrentData {
    if (Test-Path $PgData) {
        $backupName = "data.old.$(Get-Date -Format 'yyyyMMddHHmmss')"
        $backupPath = Join-Path (Split-Path $PgData -Parent) $backupName
        
        Write-LogWarn "Fazendo backup do diretorio de dados atual..."
        Write-LogWarn "Movendo para: $backupPath"
        
        Rename-Item -Path $PgData -NewName $backupName
        New-Item -ItemType Directory -Path $PgData -Force | Out-Null
    }
}


function Restore-Latest {
    Test-PgStopped
    Backup-CurrentData
    
    Write-Log "Iniciando restauracao do backup mais recente..."
    & $PgBackRest --stanza=$Stanza --config=$ConfigFile restore
    
    if ($LASTEXITCODE -eq 0) {
        Write-Log "Restauracao concluida com sucesso!"
        Write-Log "Inicie o PostgreSQL: net start $PgService"
    } else {
        Write-LogError "Falha na restauracao!"
        exit 1
    }
}


function Restore-Delta {
    Write-Log "Iniciando restauracao delta..."
    & $PgBackRest --stanza=$Stanza --config=$ConfigFile restore --delta
    
    if ($LASTEXITCODE -eq 0) {
        Write-Log "Restauracao delta concluida com sucesso!"
        Write-Log "Inicie o PostgreSQL: net start $PgService"
    } else {
        Write-LogError "Falha na restauracao delta!"
        exit 1
    }
}

# Restaurar para ponto no tempo
function Restore-PointInTime {
    param([string]$TargetTime)
    
    if ([string]::IsNullOrEmpty($TargetTime)) {
        Write-LogError "Especifique o tempo alvo!"
        Write-LogError "Exemplo: .\restore.ps1 point-in-time '2025-12-12 10:30:00'"
        exit 1
    }
    
    Test-PgStopped
    Backup-CurrentData
    
    Write-Log "Iniciando restauracao para: $TargetTime"
    & $PgBackRest --stanza=$Stanza --config=$ConfigFile restore `
        --type=time `
        --target="$TargetTime" `
        --target-action=promote
    
    if ($LASTEXITCODE -eq 0) {
        Write-Log "Restauracao PITR concluida com sucesso!"
        Write-Log "Inicie o PostgreSQL: net start $PgService"
    } else {
        Write-LogError "Falha na restauracao PITR!"
        exit 1
    }
}


function Restore-BackupSet {
    param([string]$Label)
    
    if ([string]::IsNullOrEmpty($Label)) {
        Write-LogError "Especifique o label do backup!"
        Show-Info
        exit 1
    }
    
    Test-PgStopped
    Backup-CurrentData
    
    Write-Log "Iniciando restauracao do backup: $Label"
    & $PgBackRest --stanza=$Stanza --config=$ConfigFile restore --set=$Label
    
    if ($LASTEXITCODE -eq 0) {
        Write-Log "Restauracao concluida com sucesso!"
        Write-Log "Inicie o PostgreSQL: net start $PgService"
    } else {
        Write-LogError "Falha na restauracao!"
        exit 1
    }
}


function Show-Info {
    Write-Log "Backups disponiveis para restauracao:"
    Write-Host ""
    & $PgBackRest --stanza=$Stanza --config=$ConfigFile info
}

# Main
switch ($Action) {
    "latest"        { Restore-Latest }
    "delta"         { Restore-Delta }
    "point-in-time" { Restore-PointInTime -TargetTime $Target }
    "backup-set"    { Restore-BackupSet -Label $Target }
    "info"          { Show-Info }
    default         { Show-Help }
}
