import os
import secrets
from fastapi import Header, HTTPException, status

API_KEY_NAME = "X-API-Key"
ENV_VAR_NAME = "INCIDENTFLOW_API_KEY"

def verify_api_key(x_api_key: str = Header(..., alias=API_KEY_NAME)):
    """
    Validates the API Key provided in the header against the environment variable.
    Uses constant-time comparison to prevent timing attacks.
    """
    expected_key = os.getenv(ENV_VAR_NAME)
    
    if not expected_key:
        # Log critical error but don't expose details to client
        print("CRITICAL SECURITY ERROR: INCIDENTFLOW_API_KEY not set on server!", flush=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Server security configuration error"
        )

    if not secrets.compare_digest(x_api_key, expected_key):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing API Key"
        )
        
    return x_api_key
