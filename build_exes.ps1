# IncidentFlow Build Script
# This script generates standalone .exe files for all components.

Write-Host "Building IncidentFlow Executables..." -ForegroundColor Cyan

# 1. Build MCP Server
Write-Host "`nBuilding IncidentFlow-MCP..." -ForegroundColor Yellow
pyinstaller --noconfirm --onefile --console --name "IncidentFlow-MCP" "mcp_server/run.py"

# 2. Build Slack Agent
Write-Host "`nBuilding IncidentFlow-Slack..." -ForegroundColor Yellow
pyinstaller --noconfirm --onefile --console --name "IncidentFlow-Slack" "agents/slack_agent/run.py"

# 3. Build Log Agent
Write-Host "`nBuilding IncidentFlow-LogAgent..." -ForegroundColor Yellow
pyinstaller --noconfirm --onefile --console --name "IncidentFlow-LogAgent" "agents/log_agent/main.py"

Write-Host "`nBuild Complete! Executables are in the 'dist' folder." -ForegroundColor Green
