# DeepSeek severity placeholder
import os
import requests

DEESEEK_API_KEY = os.getenv("DEESEEK_API_KEY")

def classify_severity(incident):
    if not DEESEEK_API_KEY:
        print("Warning: DEESEEK_API_KEY not found. Defaulting to MEDIUM severity.", flush=True)
        return "MEDIUM"

    prompt = f"""
Classify the severity of the following incident.
Return ONLY one of these words: CRITICAL, HIGH, MEDIUM, LOW.

Definitions:
- CRITICAL: System is down, data loss imminent, or security breach. Immediate action required.
- HIGH: Major functionality impaired, significant performance degradation, or critical resource shortage.
- MEDIUM: Partial failure, non-critical error, or warning threshold exceeded (e.g. disk > 90%).
- LOW: Informational, successful operation, or minor warning (e.g. disk > 80%).

Incident Details:
Level: {incident.level}
Message: {incident.message}
"""
    try:
        res = requests.post(
            "https://api.deepseek.com/v1/chat/completions",
            headers={
                "Authorization": f"Bearer {DEESEEK_API_KEY}",
                "Content-Type": "application/json"
            },
            json={
                "model": "deepseek-chat",
                "messages": [{"role": "user", "content": prompt}],
                "temperature": 0,
                "max_tokens": 5
            },
            timeout=5
        )
        res.raise_for_status()
        return res.json()["choices"][0]["message"]["content"].strip()
    except Exception as e:
        print(f"Error classifying severity: {e}", flush=True)
        return "MEDIUM"
