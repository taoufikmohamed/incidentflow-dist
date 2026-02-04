from pydantic import BaseModel
from datetime import datetime

class Incident(BaseModel):
    host: str
    source: str
    event_id: int
    level: str
    message: str
    timestamp: datetime
    severity: str | None = None
