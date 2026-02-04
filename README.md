# IncidentFlow

**Automated Incident Response Platform for Windows**

IncidentFlow monitors Windows Event Logs, uses AI to classify the severity of incidents, and automatically reports them to Slack. It runs as a set of background Windows Services for continuous operation.

## 🚀 Features

- **Real-time Monitoring**: Detects errors from Windows Event Logs instantly.
- **AI-Powered Severity**: Uses DeepSeek AI to intelligently classify incidents as `CRITICAL`, `HIGH`, `MEDIUM`, or `LOW`.
- **Slack Integration**: Sends formatted alerts directly to your Slack workspace.
- **Resilient Architecture**: Runs as three decoupled microservices (Log Agent, MCP Server, Slack Agent) managed by NSSM.

---

## 🛠️ Installation

### Prerequisites
- **Python 3.11+** installed and added to PATH.
- **NSSM** (included or installed via Chocolatey/Scoop).
- **Administrator Privileges** (required to install services).

### Quick Start
We provide an automated PowerShell installer to set up everything for you.

1.  **Clone the repository**:
    ```powershell
    git clone https://github.com/taoufikmohamed/incidentflow-dist.git
    cd incidentflow-dist
    ```

2.  **Run the Installer (as Administrator)**:
    ```powershell
    .\install\install_exes.ps1
    ```
    - The script will ask for your API keys (`INCIDENTFLOW_API_KEY`, `DEESEEK_API_KEY`, `SLACK_WEBHOOK_URL`) if they are not already set.
    - It will install and start all three standardized services automatically.

---

## ⚙️ Configuration

The system uses the following environment variables (set automatically by the installer):

| Variable | Description |
| :--- | :--- |
| `INCIDENTFLOW_API_KEY` | Secure key for internal API communication. |
| `DEESEEK_API_KEY` | API Key for DeepSeek AI (for severity classification). |
| `SLACK_WEBHOOK_URL` | Webhook URL for your Slack channel. |

---

## 🧪 Testing

You can verify the system is working by sending a manual test incident.

### Run the Test Script
```powershell
.\test_flow.ps1
```
This script sends a simulated "CRITICAL" incident to the MCP server, which should then appear in your Slack.

### Test Severity Classification
To test how the AI classifies different types of incidents:
```powershell
.\test_severity.ps1
```

---

## 🔍 Troubleshooting

### Check Service Status
```powershell
nssm status IncidentFlow-MCP
nssm status IncidentFlow-Slack
nssm status IncidentFlow-LogAgent
```

### View Logs
Logs are located in the `logs/` directory.
- **MCP Server Errors**: `logs/IncidentFlow-MCP.err`
- **Slack Agent Errors**: `logs/IncidentFlow-Slack.err`

To tail the logs in real-time:
```powershell
Get-Content logs\IncidentFlow-MCP.err -Wait
```

### Restart Services
If you need to apply changes or restart the system:
```powershell
nssm restart IncidentFlow-MCP
nssm restart IncidentFlow-Slack
nssm restart IncidentFlow-LogAgent
```

---

## 🗑️ Uninstallation

To completely remove IncidentFlow services and built executables:

1.  **Open PowerShell as Administrator**.
2.  **Run the Uninstaller**:
    ```powershell
    .\install\uninstall_exes.ps1
    ```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
