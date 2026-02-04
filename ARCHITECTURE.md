# System Architecture

## 📂 Project Structure

```bash
incidentflow/
├── agents/                 # Microservices (Agents)
│   ├── log_agent/          # Monitors Windows Event Logs
│   │   └── main.py
│   └── slack_agent/        # Handles Slack API communication
│       └── main.py
├── install/                # Installation & Setup Scripts
│   └── install_services.ps1
├── mcp_server/             # Core Logic (The "Brain")
│   ├── server.py           # FastAPI entry point
│   ├── security.py         # Authentication logic
│   └── severity_ai.py      # AI Severity Classification (DeepSeek)
├── shared/                 # Shared logic & schemas
│   └── incident_schema.py  # Pydantic models
├── website/                # Project Showcase / Landing Page
└── verify_flow.ps1         # Testing scripts
```

## 🧩 Component Diagram

The system consists of three decoupled Windows Services communicating via HTTP/REST.

```mermaid
graph TD
    subgraph "Windows Host"
        EL[Windows Event Logs]
        
        subgraph "IncidentFlow System"
            LA[Log Agent Service]
            MCP[MCP Server Service]
            SA[Slack Agent Service]
        end
        
        LA -->|Tail Events| EL
        LA -->|POST /new_incident| MCP
        
        MCP -->|Classify Severity| AI[DeepSeek API]
        MCP --"Critical/High"--> SA
        
        SA -->|Webhook| Slack[Slack Workspace]
    end
    
    style MCP fill:#f9f,stroke:#333
```

## 🔄 Sequence Diagram (Incident Lifecycle)

How a single incident flows through the system:

```mermaid
sequenceDiagram
    participant OS as Windows OS
    participant LA as Log Agent
    participant MCP as MCP Server
    participant AI as DeepSeek AI
    participant SA as Slack Agent
    participant Slack as Slack API

    OS->>LA: New Event Log Entry (Error)
    LA->>LA: Filter (Is relevant?)
    LA->>MCP: POST /tool/new_incident
    
    MCP->>MCP: Authenticate Request
    MCP->>AI: Classify Severity (Message + Level)
    AI-->>MCP: "CRITICAL"
    
    MCP->>MCP: Update Severity
    
    alt Severity >= HIGH
        MCP->>SA: Forward Incident
        SA->>Slack: Send Formatted Alert
    else Severity < HIGH
        MCP-->>LA: 202 Accepted (No Alert)
    end
```

## 🔐 Security Architecture

1.  **Service Isolation**: Each component runs as a separate Windows Service.
2.  **Internal Auth**: Services communicate using `X-API-Key` headers.
3.  **Local Processing**: Logs are filtered locally; only potential incidents are sent to the AI.
