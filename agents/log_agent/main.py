import win32evtlog
import requests
from datetime import datetime
import time

import os
print("SLACK_WEBHOOK_URL =", os.getenv("SLACK_WEBHOOK_URL"), flush=True)

MCP_URL = "http://127.0.0.1:8000/tool/new_incident"
#API_KEY = "CHANGE_ME"
API_KEY = os.getenv("INCIDENTFLOW_API_KEY")

server = "localhost"
logtype = "System"
hand = win32evtlog.OpenEventLog(server, logtype)


print("Log agent starting...")


print("Log agent starting polling loop...")



while True:
    try:
        events = win32evtlog.ReadEventLog(
            hand,
            win32evtlog.EVENTLOG_BACKWARDS_READ |
            win32evtlog.EVENTLOG_SEQUENTIAL_READ,
            0
        )
        
        if not events:
            time.sleep(5)
            continue

        for ev in events:
            if ev.EventType == win32evtlog.EVENTLOG_ERROR_TYPE:
                payload = {
                    "host": server,
                    "source": "WindowsEventLog",
                    "event_id": ev.EventID,
                    "level": "ERROR",
                    "message": str(ev.StringInserts),
                    "timestamp": datetime.utcnow().isoformat()
                }
                try:
                    resp = requests.post(
                        MCP_URL,
                        json=payload,
                        headers={"X-API-Key": API_KEY},
                        timeout=10
                    )
                    resp.raise_for_status()
                    print(f"Sent incident for EventID {ev.EventID}", flush=True)
                except requests.RequestException as e:
                    print(f"Failed to send incident: {e}", flush=True)
        
        # Sleep after processing a batch
        time.sleep(5)
        
    except Exception as e:
        print(f"Error in main loop: {e}", flush=True)
        time.sleep(10)
