$nssm = "C:\nssm\nssm.exe"
$python = "C:\Python311\python.exe"

& $nssm install IncidentFlow-MCP `
  $python "C:\incidentflow-mcpserver\mcp_server\server.py"

& $nssm install IncidentFlow-LogAgent `
  $python "C:\incidentflow-mcpserver\agents\log_agent\main.py"

& $nssm install IncidentFlow-SlackAgent `
  $python "-m uvicorn agents.slack_agent.main:app --port 9001"
# NSSM install script placeholder
