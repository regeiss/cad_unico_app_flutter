#Requires -Version 5.1

<#
.SYNOPSIS
    Flutter Web Runner - Solução completa para problemas de proxy
.DESCRIPTION
    Script avançado para executar Flutter Web ignorando configurações de proxy corporativo
.PARAMETER Port
    Porta para executar o servidor web (padrão: 8080)
.PARAMETER BuildOnly
    Apenas fazer build sem executar servidor de desenvolvimento
.PARAMETER Browser
    Navegador a usar (chrome, edge, firefox)
.EXAMPLE
    .\run_flutter.ps1
    .\run_flutter.ps1 -Port 3000 -Browser edge
    .\run_flutter.ps1 -BuildOnly
#>

param(
    [int]$Port = 8080,
    [switch]$BuildOnly = $false,
    [ValidateSet('chrome', 'edge', 'firefox', 'auto')]
    [string]$Browser = 'chrome'
)

# Configurações globais
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

# Cores para output
$Colors = @{
    Header = 'Cyan'
    Success = 'Green' 
    Warning = 'Yellow'
    Error = 'Red'
    Info = 'White'
    Highlight = 'Magenta'
}

function Write-ColorText {
    param([string]$Text, [string]$Color = 'White')
    Write-Host $Text -ForegroundColor $Colors[$Color]
}

function Write-Header {
    param([string]$Title)
    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor $Colors.Header
    Write-Host "  $Title" -ForegroundColor $Colors.Header
    Write-Host "=" * 60 -ForegroundColor $Colors.Header
    Write-Host ""
}

function Test-PortAvailable {
    param([int]$TestPort)
    try {
        $connection = Test-NetConnection -ComputerName "localhost" -Port $TestPort -InformationLevel Quiet -WarningAction SilentlyContinue
        return -not $connection
    } catch {
        return $true
    }
}

function Find-AvailablePort {
    param([int]$StartPort = 8080)
    
    for ($i = $StartPort; $i -lt ($StartPort + 100); $i++) {
        if (Test-PortAvailable -TestPort $i) {
            return $i
        }
    }
    throw "Nenhuma porta disponível encontrada entre $StartPort e $($StartPort + 100)"
}

function Stop-BrowserProcesses {
    Write-ColorText "🔄 Finalizando processos de navegador..." "Info"
    
    $processes = @('chrome', 'msedge', 'firefox', 'dart', 'flutter')
    
    foreach ($proc in $processes) {
        Get-Process -Name $proc -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    }
    
    Start-Sleep -Seconds 2
    Write-ColorText "✅ Processos finalizados" "Success"
}

function Set-ProxyEnvironment {
    Write-ColorText "🔧 Configurando ambiente sem proxy..." "Info"
    
    # Variáveis de ambiente de proxy
    $proxyVars = @(
        'HTTP_PROXY', 'HTTPS_PROXY', 'FTP_PROXY', 'SOCKS_PROXY',
        'http_proxy', 'https_proxy', 'ftp_proxy', 'socks_proxy'
    )
    
    foreach ($var in $proxyVars) {
        [Environment]::SetEnvironmentVariable($var, '', 'Process')
    }
    
    # Configurar NO_PROXY para incluir tudo
    [Environment]::SetEnvironmentVariable('NO_PROXY', '*', 'Process')
    [Environment]::SetEnvironmentVariable('no_proxy', '*', 'Process')
    
    # Configurações específicas do Flutter
    [Environment]::SetEnvironmentVariable('FLUTTER_WEB_USE_SKIA', 'false', 'Process')
    [Environment]::SetEnvironmentVariable('FLUTTER_WEB_AUTO_DETECT', 'false', 'Process')
    
    Write-ColorText "✅ Ambiente configurado" "Success"
}

function Backup-ProxySettings {
    Write-ColorText "💾 Fazendo backup das configurações de proxy..." "Info"
    
    try {
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
        $proxyEnable = Get-ItemProperty -Path $regPath -Name "ProxyEnable" -ErrorAction SilentlyContinue
        
        if ($proxyEnable -and $proxyEnable.ProxyEnable -eq 1) {
            Write-ColorText "⚠️  Proxy do sistema detectado - será desabilitado temporariamente" "Warning"
            Set-ItemProperty -Path $regPath -Name "ProxyEnable" -Value 0
            return $true
        }
        
        Write-ColorText "✅ Proxy do sistema já estava desabilitado" "Success"
        return $false
    } catch {
        Write-ColorText "⚠️  Não foi possível verificar configurações de proxy: $($_.Exception.Message)" "Warning"
        return $false
    }
}

function Restore-ProxySettings {
    param([bool]$WasEnabled)
    
    if ($WasEnabled) {
        Write-ColorText "🔄 Restaurando configurações de proxy..." "Info"
        try {
            $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
            Set-ItemProperty -Path $regPath -Name "ProxyEnable" -Value 1
            Write-ColorText "✅ Configurações de proxy restauradas" "Success"
        } catch {
            Write-ColorText "⚠️  Erro ao restaurar proxy: $($_.Exception.Message)" "Warning"
        }
    }
}

function Test-FlutterProject {
    if (-not (Test-Path "pubspec.yaml")) {
        Write-ColorText "❌ ERRO: pubspec.yaml não encontrado!" "Error"
        Write-ColorText "❌ Execute este script na raiz do projeto Flutter" "Error"
        return $false
    }
    
    Write-ColorText "✅ Projeto Flutter encontrado" "Success"
    return $true
}

function Invoke-FlutterClean {
    Write-ColorText "🧹 Limpando cache do Flutter..." "Info"
    
    try {
        & flutter clean | Out-Null
        & flutter pub get | Out-Null
        Write-ColorText "✅ Cache limpo e dependências atualizadas" "Success"
    } catch {
        Write-ColorText "⚠️  Erro na limpeza: $($_.Exception.Message)" "Warning"
    }
}

function Get-BrowserFlags {
    return @(
        '--no-proxy-server',
        '--disable-web-security',
        '--disable-features=VizDisplayCompositor',
        '--user-data-dir=' + (Join-Path $env:TEMP 'chrome_flutter_debug'),
        '--disable-extensions',
        '--disable-plugins',
        '--disable-default-apps',
        '--disable-background-timer-throttling',
        '--disable-renderer-backgrounding',
        '--disable-backgrounding-occluded-windows',
        '--allow-running-insecure-content',
        '--ignore-certificate-errors',
        '--ignore-ssl-errors',
        '--ignore-certificate-errors-spki-list',
        '--allow-insecure-localhost',
        '--disable-dev-shm-usage',
        '--no-sandbox',
        '--remote-debugging-port=0'
    )
}

function Start-FlutterWeb {
    param([int]$WebPort, [string]$SelectedBrowser)
    
    Write-Header "INICIANDO FLUTTER WEB"
    
    Write-ColorText "🌐 Aplicação será iniciada em:" "Highlight"
    Write-ColorText "   http://localhost:$WebPort" "Info"
    Write-ColorText "   http://127.0.0.1:$WebPort" "Info"
    Write-Host ""
    
    Write-ColorText "⚠️  IMPORTANTE:" "Warning"
    Write-ColorText "   - Aguarde 10-15 segundos se aparecer erro de proxy" "Info"
    Write-ColorText "   - O navegador pode demorar para abrir na primeira vez" "Info"
    Write-ColorText "   - Pressione Ctrl+C para parar o servidor" "Info"
    Write-Host ""
    
    # Preparar argumentos do Flutter
    $browserFlags = Get-BrowserFlags
    $flutterArgs = @(
        'run',
        '-d', $SelectedBrowser,
        '--web-port=' + $WebPort,
        '--web-hostname=localhost',
        '--no-web-security',
        '--verbose'
    )
    
    # Adicionar flags do navegador
    foreach ($flag in $browserFlags) {
        $flutterArgs += '--web-browser-flag=' + $flag
    }
    
    Write-ColorText "🚀 Executando: flutter $($flutterArgs -join ' ')" "Info"
    Write-Host ""
    
    try {
        & flutter $flutterArgs
    } catch {
        Write-ColorText "❌ Erro ao executar Flutter: $($_.Exception.Message)" "Error"
        throw
    }
}

function Start-FlutterBuild {
    Write-Header "FAZENDO BUILD ESTÁTICO"
    
    Write-ColorText "🔨 Gerando build para web..." "Info"
    
    try {
        & flutter build web --web-renderer html --source-maps
        Write-ColorText "✅ Build concluído com sucesso!" "Success"
        
        $buildPath = Join-Path (Get-Location) "build\web"
        Write-ColorText "📁 Arquivos gerados em: $buildPath" "Info"
        
        Write-Host ""
        Write-ColorText "🌐 Para servir os arquivos:" "Highlight"
        Write-ColorText "   cd build\web" "Info"
        Write-ColorText "   python -m http.server $Port" "Info"
        Write-ColorText "   # ou" "Info" 
        Write-ColorText "   npx http-server -p $Port" "Info"
        
    } catch {
        Write-ColorText "❌ Erro no build: $($_.Exception.Message)" "Error"
        throw
    }
}

function Test-SystemRequirements {
    Write-ColorText "🔍 Verificando requisitos do sistema..." "Info"
    
    # Verificar Flutter
    try {
        $flutterVersion = & flutter --version 2>$null
        Write-ColorText "✅ Flutter encontrado" "Success"
    } catch {
        Write-ColorText "❌ Flutter não encontrado no PATH" "Error"
        return $false
    }
    
    # Verificar dispositivos
    try {
        $devices = & flutter devices 2>$null
        if ($devices -match 'Chrome') {
            Write-ColorText "✅ Chrome disponível para Flutter" "Success"
        } else {
            Write-ColorText "⚠️  Chrome pode não estar disponível" "Warning"
        }
    } catch {
        Write-ColorText "⚠️  Erro ao verificar dispositivos" "Warning"
    }
    
    return $true
}

# === FUNÇÃO PRINCIPAL ===
function Main {
    Write-Header "FLUTTER WEB - SOLUÇÃO COMPLETA PARA PROXY"
    
    try {
        # Verificações iniciais
        if (-not (Test-SystemRequirements)) {
            throw "Requisitos do sistema não atendidos"
        }
        
        if (-not (Test-FlutterProject)) {
            throw "Projeto Flutter inválido"
        }
        
        # Configurar ambiente
        Stop-BrowserProcesses
        Set-ProxyEnvironment
        $proxyBackup = Backup-ProxySettings
        
        # Encontrar porta disponível
        if (-not (Test-PortAvailable -TestPort $Port)) {
            $Port = Find-AvailablePort -StartPort $Port
            Write-ColorText "⚠️  Porta original ocupada, usando porta $Port" "Warning"
        }
        
        # Limpar projeto
        Invoke-FlutterClean
        
        # Executar conforme modo selecionado
        if ($BuildOnly) {
            Start-FlutterBuild
        } else {
            Start-FlutterWeb -WebPort $Port -SelectedBrowser $Browser
        }
        
    } catch {
        Write-ColorText "❌ ERRO CRÍTICO: $($_.Exception.Message)" "Error"
        exit 1
    } finally {
        # Sempre tentar restaurar configurações
        if ($proxyBackup) {
            Restore-ProxySettings -WasEnabled $proxyBackup
        }
        
        Write-Header "FINALIZADO"
    }
}

# Executar apenas se chamado diretamente
if ($MyInvocation.InvocationName -ne '.') {
    Main
}