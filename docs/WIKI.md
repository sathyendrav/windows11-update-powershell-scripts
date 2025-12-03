# Windows 11 Update PowerShell Scripts

This repository provides PowerShell scripts to help manage Windows Update tasks on Windows 11 systems. The scripts are intended to automate common update operations such as checking for available updates, installing updates, and troubleshooting Update issues.

> NOTE: These scripts are provided as-is. Run only on systems you control and test in a safe environment before production use. Always review scripts before executing them.

---

## Contents of this Wiki
- Overview
- Prerequisites
- Included scripts (how to discover them)
- Installation and quick start
- Usage examples
- Configuration and customization
- Troubleshooting
- Contributing
- License and contact

---

## Overview
This collection focuses on automating Windows Update tasks on Windows 11 using PowerShell. Depending on the script set included in the repository, you can:
- Check Windows Update status
- Scan for available updates
- Download and install updates
- Reboot handling after updates
- Collect logs for troubleshooting

These scripts aim to be lightweight, transparent, and easy to modify.

## Prerequisites
- Windows 11 (supported builds as documented in each script)
- PowerShell 5.1 or PowerShell 7+ (some scripts may work only on built-in Windows PowerShell)
- Administrator privileges to run update and service-related commands
- ExecutionPolicy set to allow script execution for the session, for example: `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`

## Included scripts
This repo may contain multiple .ps1 scripts. To list available scripts locally, run in a PowerShell prompt from the repository root:

```powershell
Get-ChildItem -Path . -Filter *.ps1 -Recurse | Select-Object FullName
```

Each script should contain a header comment describing its purpose, parameters, and examples. Please read the top of the script file before running it.

## Installation and quick start
1. Clone the repository:

```powershell
git clone https://github.com/sathyendrav/windows11-update-powershell-scripts.git
cd windows11-update-powershell-scripts
```

2. Open an elevated PowerShell session (Run as Administrator).

3. Allow script execution for the session if needed:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

4. Run a script (example):

```powershell
# Inspect the script first
Get-Content .\scripts\YourScript.ps1 -Head 50

# Run the script (example)
.\scripts\YourScript.ps1 -Verbose
```

Replace `.\