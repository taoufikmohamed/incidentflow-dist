import os
import requests
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

SLACK_WEBHOOK_URL = os.getenv("SLACK_WEBHOOK_URL")

if not SLACK_WEBHOOK_URL:
    raise RuntimeError("SLACK_WEBHOOK_URL is not set")

app = FastAPI()

class SlackIncident(BaseModel):
    host: str
    level: str
    message: str
    severity: str | None = "UNKNOWN"

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/incident")
def send_incident(incident: SlackIncident):
    payload = {
        "text": (
            f"*🚨 IncidentFlow Alert*\n"
            f"*Host:* {incident.host}\n"
            f"*Level:* {incident.level}\n"
            f"*Severity:* {incident.severity}\n"
            f"*Message:* {incident.message}"
        )
    }

    r = requests.post(SLACK_WEBHOOK_URL, json=payload)

    if r.status_code != 200:
        raise HTTPException(status_code=500, detail="Slack delivery failed")

    return {"status": "sent"}
