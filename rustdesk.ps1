# Script: Install-RustDesk.ps1
# Descripción: Instala la última versión de RustDesk en Windows
# Uso: powershell -ExecutionPolicy Bypass -File Install-RustDesk.ps1

$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

# Colores para output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

Write-ColorOutput "=== RustDesk Installer ===" "Cyan"
Write-ColorOutput "Iniciando instalación de la última versión..." "Yellow"

try {
    # Obtener la última versión desde GitHub API
    Write-ColorOutput "Obteniendo información de la última versión..." "Yellow"
    $apiUrl = "https://api.github.com/repos/rustdesk/rustdesk/releases/latest"
    $latestRelease = Invoke-RestMethod -Uri $apiUrl -Headers @{"User-Agent"="PowerShell-Script"}
    
    $version = $latestRelease.tag_name
    Write-ColorOutput "Última versión disponible: $version" "Green"
    
    # Buscar el archivo x64 MSI en los assets
    $asset = $latestRelease.assets | Where-Object { 
        $_.name -match "x86_64\.msi$" -and $_.name -notmatch "portable|linux|mac"
    }
    
    if (-not $asset) {
        throw "No se encontró el instalador MSI para Windows x64"
    }
    
    $downloadUrl = $asset.browser_download_url
    $filename = $asset.name
    $tempPath = Join-Path $env:TEMP $filename
    
    # Descargar el instalador
    Write-ColorOutput "Descargando $filename..." "Yellow"
    Write-ColorOutput "Tamaño: $([math]::Round($asset.size/1MB, 2)) MB" "Gray"
    
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UserAgent "PowerShell-Script"
    
    # Verificar descarga
    if ((Get-Item $tempPath).Length -eq 0) {
        throw "Error: El archivo descargado está vacío"
    }
    
    Write-ColorOutput "Descarga completada!" "Green"
    
    # Cerrar RustDesk si está ejecutándose
    $rustdeskProcess = Get-Process -Name "rustdesk" -ErrorAction SilentlyContinue
    if ($rustdeskProcess) {
        Write-ColorOutput "Cerrando RustDesk en ejecución..." "Yellow"
        Stop-Process -Name "rustdesk" -Force
        Start-Sleep -Seconds 2
    }
    
    # Instalar MSI silenciosamente
    Write-ColorOutput "Instalando RustDesk $version..." "Yellow"
    $installArgs = "/i `"$tempPath`" /quiet /norestart"
    $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -eq 0) {
        Write-ColorOutput "¡RustDesk $version instalado exitosamente!" "Green"
    } elseif ($process.ExitCode -eq 3010) {
        Write-ColorOutput "Instalación completada. Se requiere reinicio." "Yellow"
        $restart = Read-Host "¿Deseas reiniciar ahora? (S/N)"
        if ($restart -eq 'S') {
            Restart-Computer -Force
        }
    } else {
        throw "Error en la instalación. Código: $($process.ExitCode)"
    }
    
    # Limpiar archivo temporal
    Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
    
    # Crear acceso directo en escritorio si no existe
    $shortcutPath = [Environment]::GetFolderPath("Desktop") + "\RustDesk.lnk"
    if (-not (Test-Path $shortcutPath)) {
        $installPath = "${env:ProgramFiles}\RustDesk\rustdesk.exe"
        if (Test-Path $installPath) {
            $WScriptShell = New-Object -ComObject WScript.Shell
            $Shortcut = $WScriptShell.CreateShortcut($shortcutPath)
            $Shortcut.TargetPath = $installPath
            $Shortcut.Save()
            Write-ColorOutput "Acceso directo creado en el escritorio" "Green"
        }
    }
    
} catch {
    Write-ColorOutput "ERROR: $_" "Red"
    Write-ColorOutput "Detalles del error:" "Red"
    Write-ColorOutput $_.Exception.Message "Red"
    exit 1
}

Write-ColorOutput "`nInstalación finalizada!" "Cyan"