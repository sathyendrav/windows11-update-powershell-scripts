<#
.SYNOPSIS
    Quick Update Scanner - Lists available updates without installing them.

.DESCRIPTION
    This script scans for available updates across three package management platforms:
    - Microsoft Store apps (via CIM/WMI)
    - Winget packages (Windows Package Manager)
    - Chocolatey packages (Community Package Manager)
    
    This is a READ-ONLY preview mode - no updates are installed.
    Perfect for a quick overview of what needs updating.

.NOTES
    File Name      : update-checker1.ps1
    Author         : sathyendrav
    Prerequisite   : PowerShell 5.1 or later, Administrator privileges recommended
    Required Tools : Winget (App Installer), Chocolatey (optional)
    
.EXAMPLE
    .\update-checker1.ps1
    Displays all available updates without installing them.
#>

# ============================================================================
# Microsoft Store Updates Check
# ============================================================================
Write-Host "Checking for Microsoft Store app updates..." -ForegroundColor Yellow

# Access the MDM (Mobile Device Management) namespace to scan for Store app updates
# This triggers an update check but does NOT automatically install updates
# Note: Requires administrator privileges to access the MDM namespace
Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" `
                -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | `
    Invoke-CimMethod -MethodName UpdateScanMethod

# ============================================================================
# Winget (Windows Package Manager) Updates Check
# ============================================================================

# Verify that winget is installed and available in PATH
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "`nChecking for Winget package updates..." -ForegroundColor Yellow
    
    # List all packages with available upgrades
    # This command only displays what CAN be updated - it does NOT install anything
    winget upgrade
} else {
    # Winget not found - notify user
    Write-Host "Winget is not available on this system" -ForegroundColor Red
    Write-Host "Install 'App Installer' from Microsoft Store to enable Winget" -ForegroundColor Yellow
}

# ============================================================================
# Chocolatey Package Manager Updates Check
# ============================================================================

# Verify that Chocolatey is installed and available in PATH
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "`nChecking for Chocolatey package updates..." -ForegroundColor Yellow
    
    # Dry-run mode: Shows what WOULD be upgraded without actually upgrading
    # --whatif: Simulates the upgrade operation without making any changes
    choco upgrade all --whatif
} else {
    # Chocolatey not found - notify user (silently skip if not installed)
    # Note: No error message displayed since Chocolatey is optional
}

# ============================================================================
# Completion Message
# ============================================================================
Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
Write-Host "Update check completed!" -ForegroundColor Green
Write-Host "No packages were installed - this was a preview only." -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Cyan