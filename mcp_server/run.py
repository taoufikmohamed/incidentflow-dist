import uvicorn
import os
import sys

print(f"DEBUG: Starting MCP Server run.py", flush=True)
print(f"DEBUG: Python version: {sys.version}", flush=True)

try:
    from mcp_server.server import app
    print("DEBUG: App imported successfully", flush=True)
except Exception as e:
    print(f"DEBUG: Failed to import app: {e}", flush=True)
    sys.exit(1)

if __name__ == "__main__":
    print("DEBUG: Entering main block", flush=True)
    try:
        print("DEBUG: Calling uvicorn.run", flush=True)
        uvicorn.run(app, host="127.0.0.1", port=8000, log_level="debug")
        print("DEBUG: uvicorn.run returned normally", flush=True)
    except Exception as e:
        print(f"DEBUG: uvicorn.run crashed: {e}", flush=True)
        sys.exit(1)
