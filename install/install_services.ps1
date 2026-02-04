# Check for Administrator privileges
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You must run this script as Administrator!"
    Exit
}

$ErrorActionPreference = "Stop"
$ScriptPath = $PSScriptRoot
$RootPath = (Get-Item $ScriptPath).Parent.FullName

Write-Host "IncidentFlow Installer" -ForegroundColor Cyan
Write-Host "Root Path: $RootPath"

# 1. Check Prerequisites
Write-Host "`nchecking prerequisites..." -ForegroundColor Yellow

# Check Python
$PythonExe = Get-Command python -ErrorAction SilentlyContinue
if (!$PythonExe) {
    # Try common paths
    if (Test-Path "C:\Python311\python.exe") {
        $PythonPath = "C:\Python311\python.exe"
    }
    else {
        Write-Error "Python not found in PATH or C:\Python311. Please install Python 3.11+ and add to PATH."
        Exit
    }
}
else {
    $PythonPath = $PythonExe.Source
}
Write-Host "  Found Python: $PythonPath" -ForegroundColor Green

# Check NSSM
$NSSM = Get-Command nssm -ErrorAction SilentlyContinue
if (!$NSSM) {
    if (Test-Path "C:\nssm\nssm.exe") {
        $NssmPath = "C:\nssm\nssm.exe"
    }
    elseif (Test-Path "$RootPath\nssm.exe") {
        $NssmPath = "$RootPath\nssm.exe"
    }
    else {
        Write-Error "NSSM not found. Please install NSSM and add to PATH or place in C:\nssm."
        Exit
    }
}
else {
    $NssmPath = $NSSM.Source
}
Write-Host "  Found NSSM: $NssmPath" -ForegroundColor Green


# 2. Configure Environment Variables
Write-Host "`nConfiguration..." -ForegroundColor Yellow

function Get-EnvVar {
    param($Name, $Prompt)
    $Val = [Environment]::GetEnvironmentVariable($Name, "Machine")
    if ([string]::IsNullOrWhiteSpace($Val)) {
        $Ans = Read-Host "$Prompt"
        if ([string]::IsNullOrWhiteSpace($Ans)) {
            Write-Error "$Name is required!"
            Exit
        }
        return $Ans
    }
    Write-Host "  $Name already set."
    return $Val
}

$ApiKey = Get-EnvVar "INCIDENTFLOW_API_KEY" "Enter a secure API Key for IncidentFlow MCP Server"
$SlackUrl = Get-EnvVar "SLACK_WEBHOOK_URL" "Enter your Slack Webhook URL"
$DeepSeekKey = Get-EnvVar "DEESEEK_API_KEY" "Enter your DeepSeek API Key"

# Set persistently if not set (or just to be sure)
[Environment]::SetEnvironmentVariable("INCIDENTFLOW_API_KEY", $ApiKey, "Machine")
[Environment]::SetEnvironmentVariable("SLACK_WEBHOOK_URL", $SlackUrl, "Machine")
[Environment]::SetEnvironmentVariable("DEESEEK_API_KEY", $DeepSeekKey, "Machine")


# 3. Install Services
Write-Host "`nInstalling Services..." -ForegroundColor Yellow

function Install-Service {
    param($Name, $Script, $ArgsStr)
    Write-Host "  Installing $Name..."
    
    # Stop and remove if exists (ignore errors if service doesn't exist/started)
    try {
        & $NssmPath stop $Name *>$null
    }
    catch {}
    
    try {
        & $NssmPath remove $Name confirm *>$null
    }
    catch {}

    # Install
    # We use python as the executable and the script as argument
    # NSSM 'AppDirectory' should be the root
    
    & $NssmPath install $Name "$PythonPath"
    & $NssmPath set $Name AppDirectory "$RootPath"
    
    # Construct complete arguments
    # If it's a module run (uvicorn), pass it as is. If it's a script, pass full path.
    & $NssmPath set $Name AppParameters "$ArgsStr"
    
    # Set Environment Variables for the service specifically (redundant but safe)
    # NSSM requires newline separated Key=Value
    $EnvVars = "INCIDENTFLOW_API_KEY=$ApiKey`nSLACK_WEBHOOK_URL=$SlackUrl`nDEESEEK_API_KEY=$DeepSeekKey`nPYTHONUNBUFFERED=1"
    & $NssmPath set $Name AppEnvironmentExtra $EnvVars
    
    & $NssmPath set $Name AppStdout "$RootPath\logs\$Name.log"
    & $NssmPath set $Name AppStderr "$RootPath\logs\$Name.err"
}

# Ensure logs dir
New-Item -ItemType Directory -Force -Path "$RootPath\logs" | Out-Null

# Install Slack Agent
Install-Service "IncidentFlow-Slack" "" "-m uvicorn agents.slack_agent.main:app --host 127.0.0.1 --port 9001"

# Install MCP Server
Install-Service "IncidentFlow-MCP" "" "-m uvicorn mcp_server.server:app --host 127.0.0.1 --port 8000"

# Install Log Agent
Install-Service "IncidentFlow-LogAgent" "" "$RootPath\agents\log_agent\main.py"


# 4. Start Services
Write-Host "`nStarting Services..." -ForegroundColor Yellow

& $NssmPath start IncidentFlow-Slack
Start-Sleep -Seconds 2
& $NssmPath start IncidentFlow-MCP
Start-Sleep -Seconds 2
& $NssmPath start IncidentFlow-LogAgent

Write-Host "`nDone! All services should be running." -ForegroundColor Green
Write-Host "Check status with: nssm status IncidentFlow-MCP"
