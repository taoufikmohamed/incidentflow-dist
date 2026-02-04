# IncidentFlow - AI-Powered Incident Response Platform

**Tagline:** Automating Windows Incident Response with Local AI Agents.

## 📌 Project Overview
IncidentFlow is a resilient, microservice-based automation platform designed to monitor Windows server infrastructure. It intercepts critical system events in real-time, uses a local Large Language Model (DeepSeek via MCP) to analyze severity, and instantly dispatches structured alerts to Slack.

## 🚀 The Problem
Sysadmins often miss critical Windows Event Logs buried in noise. Manual monitoring is slow, and generic alerts lack context.

## 💡 The Solution
A "set-and-forget" background system that filters noise and provides actionable, AI-classified intelligence.

## 🛠️ Tech Stack
- **Languages**: Python 3.11, PowerShell
- **Core Framework**: FastAPI (MCP Server), Uvicorn
- **AI/ML**: DeepSeek API (Severity Classification)
- **Infrastructure**: Native Windows Services (NSSM), Win32 API
- **Protocols**: Model Context Protocol (MCP), HTTP/REST

## 🏗️ System Architecture
The system runs as three decoupled Windows Services:
1.  **Log Agent**: Tails Windows Event Logs via Win32 API.
2.  **MCP Server**: The "Brain". Receives events, queries AI for severity, and decides action.
3.  **Slack Agent**: Handles external communication APIs.

## 🔗 Key Features
- **Zero-Downtime**: Auto-restart capabilities via NSSM.
- **Privacy-First**: Local log processing; only filtered data hits the AI.
- **Extensible**: Built on the Model Context Protocol (MCP) for future tool integration.
