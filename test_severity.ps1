# Test Severity Classification
$ErrorActionPreference = "Stop"
$ApiKey = [Environment]::GetEnvironmentVariable("INCIDENTFLOW_API_KEY", "Machine")
$Uri = "http://127.0.0.1:8000/tool/new_incident"

function Send-Incident {
    param($Level, $Message)
    $Body = @{
        host      = "TEST-PC"
        source    = "SeverityTest"
        event_id  = 999
        level     = $Level
        message   = $Message
        timestamp = (Get-Date).ToString("o")
    } | ConvertTo-Json
    
    try {
        $Response = Invoke-RestMethod -Uri $Uri -Method POST -Headers @{ "X-API-Key" = $ApiKey } -Body $Body -ContentType "application/json"
        Write-Host "Level: $Level | Message: $Message -> Severity: $($Response.severity) | Status: $($Response.status)" -ForegroundColor Yellow
    }
    catch {
        Write-Error "Failed: $_"
    }
}

Write-Host "Testing various incident types..." -ForegroundColor Cyan
Send-Incident "INFO" "Daily backup completed successfully."
Send-Incident "WARNING" "Disk usage is at 85%."
Send-Incident "ERROR" "Database connection timeout."
Send-Incident "ERROR" "System critical failure! Data loss imminent."
