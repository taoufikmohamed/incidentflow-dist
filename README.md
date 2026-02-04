# IncidentFlow

**AI-Powered Multi-Agent MCP Server for Automated Slack Alerts**

---

### 💼 The Business Case
In modern infrastructure, **downtime is measured in dollars.** IncidentFlow bridges the gap between raw system errors and human action:
- **Reduce MTTR (Mean Time to Repair)**: AI immediately classifies severity, allowing teams to prioritize critical failures.
- **24/7 Monitoring**: Automated service-based detection ensures no system error goes unnoticed, even at 3 AM.
- **Noise Reduction**: Context-aware AI filtering prevents notification fatigue by focusing only on what matters.

[**Live Demo (Landing Page)**](https://taoufikmohamed.github.io/incidentflow-dist/website/)

---

## 🚀 Features

- **Real-time Monitoring**: Detects errors from Windows Event Logs instantly.
- **AI-Powered Severity**: Uses DeepSeek AI to intelligently classify incidents as `CRITICAL`, `HIGH`, `MEDIUM`, or `LOW`.
- **Slack Integration**: Sends formatted alerts directly to your Slack workspace.
- **Resilient Architecture**: Runs as three decoupled microservices (Log Agent, MCP Server, Slack Agent) managed by NSSM.

---

### 📥 For Non-Technical Users (Quick Start)

If you are not a developer and just want to run the system, follow these simple steps:

1.  **Download the latest version**: 
    Go to the [Latest Release](https://github.com/taoufikmohamed/incidentflow-dist/releases/latest) and download the file named **`IncidentFlow-v1.0.0.zip`**.
2.  **Extract the Files**: 
    Right-click the downloaded ZIP file and select "Extract All...".
3.  **Run the Installer**:
    - Open the extracted folder, then open the `install` folder.
    - Right-click `install_exes.ps1` and select **"Run with PowerShell"**.
    - If prompted for Administrator access, click **Yes**.
    - Follow any on-screen prompts to enter your API keys.

---

## 🛠️ Installation (For Developers)

### Prerequisites
- **Python 3.11+** installed and added to PATH.
- **NSSM** (included or installed via Chocolatey/Scoop).
- **Administrator Privileges** (required to install services).

### Quick Start
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
