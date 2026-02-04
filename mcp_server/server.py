# MCP server placeholder
from fastapi import FastAPI, Depends, Header, HTTPException
from shared.incident_schema import Incident
from mcp_server.security import verify_api_key
from mcp_server.severity_ai import classify_severity
import requests
import os

print("API KEY configured.", flush=True)

app = FastAPI()
SLACK_AGENT_URL = "http://127.0.0.1:9001/incident"

@app.post("/tool/new_incident", dependencies=[Depends(verify_api_key)])
def new_incident(incident: Incident):
    incident.severity = classify_severity(incident)
    
    # Filter: Only alert on HIGH or CRITICAL
    if incident.severity in ["HIGH", "CRITICAL"]:
        requests.post(SLACK_AGENT_URL, json=incident.model_dump(mode='json'))
        return {"status": "alert_sent", "severity": incident.severity}
    
    return {"status": "filtered", "severity": incident.severity}
