<#
.SYNOPSIS
    Automated Windows Update Installer - Updates Microsoft Store, Winget, and Chocolatey packages.

.DESCRIPTION
    This script automatically checks for and installs updates across three package management platforms:
    - Microsoft Store apps (via CIM/WMI)
    - Winget packages (Windows Package Manager)
    - Chocolatey packages (Community Package Manager)
    
    All updates are performed in silent/non-interactive mode where possible.

.NOTES
    File Name      : install-updates.ps1
    Author         : sathyendrav
    Prerequisite   : PowerShell 5.1 or later, Administrator privileges recommended
    Required Tools : Winget (App Installer), Chocolatey (optional)
    
.EXAMPLE
    .\install-updates.ps1
    Runs all update checks and installations automatically.
#>

# ============================================================================
# Microsoft Store Updates
# ============================================================================
Write-Host "Checking for Microsoft Store app updates..." -ForegroundColor Yellow

try {
    # Access the MDM (Mobile Device Management) namespace to trigger Store app updates
    # This uses the Enterprise Modern App Management class to scan for available updates
    Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" `
                    -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | `
        Invoke-CimMethod -MethodName UpdateScanMethod
    
    Write-Host "Microsoft Store update scan initiated successfully." -ForegroundColor Green
} catch {
    # Handle errors if Store updates fail (e.g., insufficient permissions, namespace unavailable)
    Write-Host "Failed to check Microsoft Store updates: $_" -ForegroundColor Red
}

# ============================================================================
# Winget (Windows Package Manager) Updates
# ============================================================================

# Check if winget is installed and available in PATH
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "`nChecking for Winget package updates..." -ForegroundColor Yellow
    
    # Upgrade all packages silently without user interaction
    # --all: Updates all packages with available upgrades
    # --silent: Suppresses prompts and runs in non-interactive mode
    winget upgrade --all --silent
    
    Write-Host "Winget packages updated successfully." -ForegroundColor Green
} else {
    # Winget not found - inform user to install App Installer from Microsoft Store
    Write-Host "Winget is not available on this system" -ForegroundColor Red
    Write-Host "Install 'App Installer' from Microsoft Store to enable Winget" -ForegroundColor Yellow
}

# ============================================================================
# Chocolatey Package Manager Updates
# ============================================================================

# Check if Chocolatey is installed and available in PATH
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "`nChecking for Chocolatey package updates..." -ForegroundColor Yellow
    
    # Upgrade all Chocolatey packages
    # upgrade all: Updates all installed packages
    # -y: Auto-confirms all prompts (yes to all)
    choco upgrade all -y
    
    Write-Host "Chocolatey packages updated successfully." -ForegroundColor Green
} else {
    # Chocolatey not found - inform user how to install it
    Write-Host "Chocolatey is not available on this system" -ForegroundColor Red
    Write-Host "Visit https://chocolatey.org/install for installation instructions" -ForegroundColor Yellow
}

# ============================================================================
# Completion Message
# ============================================================================
Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
Write-Host "Update check and installation completed!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan

