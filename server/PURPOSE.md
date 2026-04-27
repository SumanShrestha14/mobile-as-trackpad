# Desktop Server Scaffold

This folder will contain the Python desktop server for Phone-as-Trackpad.

## Planned structure
- app/network
- app/protocol
- app/os_control
- tests
- scripts

## Python environment
- Local virtual environment: `.venv`
- Interpreter used: Python 3.13.x
- Activate in PowerShell: `.\\.venv\\Scripts\\Activate.ps1`

## Purpose
- Accept WiFi connections
- Parse control messages
- Inject mouse and keyboard actions into the operating system

## Start points
- Main module: `app/main.py`
- Run script: `scripts/run_server.ps1`
