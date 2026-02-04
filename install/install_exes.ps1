# IncidentFlow Pro Installer (Executables)
# Check for Administrator privileges
<#
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You must run this script as Administrator!"
    Exit
}
#>

$ErrorActionPreference = "Continue" # Don't stop on non-critical nssm errors

$RootPath = (Get-Item $PSScriptRoot).Parent.FullName
$DistPath = Join-Path $RootPath "dist"

# Check NSSM
$NssmPath = Get-Command nssm -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (!$NssmPath) {
    Write-Error "NSSM not found in PATH. Please install it."
    Exit
}

Write-Host "Installing IncidentFlow (EXE version)..." -ForegroundColor Cyan

function Install-Exe-Service {
    param($Name, $ExeName, $ArgsStr)
    $ExePath = Join-Path $DistPath $ExeName
    
    if (!(Test-Path $ExePath)) {
        Write-Error "Executable not found: $ExePath"
        return
    }

    Write-Host "`n[+] Installing $Name..." -ForegroundColor Magenta
    
    # 1. Stop if running
    Write-Host "    Stopping service..."
    & $NssmPath stop $Name *>$null
    Start-Sleep -Seconds 1

    # 2. Remove if exists
    Write-Host "    Removing old service..."
    & $NssmPath remove $Name confirm *>$null
    Start-Sleep -Seconds 1

    # 3. Fresh Install
    Write-Host "    Registering executable..."
    & $NssmPath install $Name "$ExePath"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install $Name with nssm!"
        return
    }

    # 4. Configure
    & $NssmPath set $Name AppDirectory "$RootPath"
    & $NssmPath set $Name AppParameters "$ArgsStr"
    & $NssmPath set $Name AppStdout "$RootPath\logs\$Name.log"
    & $NssmPath set $Name AppStderr "$RootPath\logs\$Name.err"
    
    Write-Host "    Successfully configured $Name" -ForegroundColor Green
}

# Ensure logs dir
if (!(Test-Path "$RootPath\logs")) {
    New-Item -ItemType Directory -Force -Path "$RootPath\logs" | Out-Null
}

# Install Services
Install-Exe-Service "IncidentFlow-Slack" "IncidentFlow-Slack.exe" ""
Install-Exe-Service "IncidentFlow-MCP" "IncidentFlow-MCP.exe" ""
Install-Exe-Service "IncidentFlow-LogAgent" "IncidentFlow-LogAgent.exe" ""

# Start
Write-Host "`n[!] Starting Services..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

Write-Host "Starting Slack Agent..."
& $NssmPath start IncidentFlow-Slack
Start-Sleep -Seconds 2

Write-Host "Starting MCP Server..."
& $NssmPath start IncidentFlow-MCP
Start-Sleep -Seconds 2

Write-Host "Starting Log Agent..."
& $NssmPath start IncidentFlow-LogAgent

Write-Host "`nDone! Deployment verified." -ForegroundColor Green

