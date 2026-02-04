# IncidentFlow Uninstaller (Executables)
# This script stops all services, removes them, and deletes built artifacts.

$ErrorActionPreference = "Continue"

Write-Host "Uninstalling IncidentFlow..." -ForegroundColor Cyan

# Check NSSM
$NssmPath = Get-Command nssm -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (!$NssmPath) {
    Write-Error "NSSM not found in PATH. Please install it to use this uninstaller."
    Exit
}

$Services = @("IncidentFlow-Slack", "IncidentFlow-MCP", "IncidentFlow-LogAgent")

foreach ($Service in $Services) {
    Write-Host "`n[!] Removing $Service..." -ForegroundColor Yellow
    
    # 1. Stop service
    Write-Host "    Stopping service..."
    & $NssmPath stop $Service *>$null
    Start-Sleep -Seconds 1

    # 2. Remove service
    Write-Host "    Removing service from system..."
    & $NssmPath remove $Service confirm *>$null
    
    Write-Host "    $Service removed." -ForegroundColor Green
}

# Cleanup files
Write-Host "`n[!] Cleaning up files..." -ForegroundColor Yellow

$RootPath = (Get-Item $PSScriptRoot).Parent.FullName
$DistPath = Join-Path $RootPath "dist"
$LogPath = Join-Path $RootPath "logs"

if (Test-Path $DistPath) {
    Write-Host "    Deleting executables (dist/)..."
    Remove-Item -Path $DistPath -Recurse -Force
}

if (Test-Path $LogPath) {
    Write-Host "    Clearing logs..."
    Remove-Item -Path $LogPath\*.log -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $LogPath\*.err -Force -ErrorAction SilentlyContinue
}

Write-Host "`nUninstallation Complete!" -ForegroundColor Green
