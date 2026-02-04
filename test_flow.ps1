# Test IncidentFlow
# Triggers a manual incident to test the full flow (MCP -> Slack)

$ErrorActionPreference = "Stop"

# Get API Key
$ApiKey = [Environment]::GetEnvironmentVariable("INCIDENTFLOW_API_KEY", "Machine")
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    Write-Error "INCIDENTFLOW_API_KEY environment variable is not set."
    Exit
}

$Body = @{
    host      = $env:COMPUTERNAME
    source    = "ManualTest"
    event_id  = 1001
    level     = "ERROR"
    message   = "This is a test incident from the manual verification script."
    timestamp = (Get-Date).ToString("o")
} | ConvertTo-Json

Write-Host "Sending test incident to MCP Server..." -ForegroundColor Cyan

try {
    $Response = Invoke-RestMethod `
        -Uri "http://127.0.0.1:8000/tool/new_incident" `
        -Method POST `
        -Headers @{ "X-API-Key" = $ApiKey } `
        -Body $Body `
        -ContentType "application/json"
    
    Write-Host "Success!" -ForegroundColor Green
    Write-Host "Response:"
    $Response | Format-List
}
catch {
    Write-Error "Failed to send incident: $_"
    if ($_.Exception.Response) {
        $Stream = $_.Exception.Response.GetResponseStream()
        $Reader = [System.IO.StreamReader]::new($Stream)
        $Body = $Reader.ReadToEnd()
        Write-Error "Server Response: $Body"
    }
}
