<#
.SYNOPSIS
    Advanced Update Reporter with Detailed Diagnostics and Optional Automation.

.DESCRIPTION
    This script provides comprehensive update checking and reporting across multiple platforms:
    - Microsoft Store apps (via CIM/WMI)
    - Winget packages (Windows Package Manager)
    - Chocolatey packages (Community Package Manager)
    
    Features:
    - Colorized console output for better readability
    - Optional automatic update installation
    - List-only mode for auditing
    - Installed software inventory from Windows Registry
    - System information display (OS, version, last boot time)
    - Recently installed applications report

.PARAMETER AutoUpdate
    When set, prompts the user to perform updates automatically.
    Applies to Winget packages with user confirmation.

.PARAMETER ListOnly
    When set, only lists available updates without offering installation.
    Useful for auditing and reporting purposes.

.NOTES
    File Name      : update-checker2.ps1
    Author         : sathyendrav
    Prerequisite   : PowerShell 5.1 or later, Administrator privileges recommended
    Required Tools : Winget (App Installer), Chocolatey (optional)
    
.EXAMPLE
    .\update-checker2.ps1
    Runs in default mode - lists updates and installed software.

.EXAMPLE
    .\update-checker2.ps1 -ListOnly
    Explicitly lists updates only, no installation prompts.

.EXAMPLE
    .\update-checker2.ps1 -AutoUpdate
    Lists updates and prompts for automatic installation where supported.
#>

# ============================================================================
# Script Parameters
# ============================================================================
param(
    [switch]$AutoUpdate,  # Enable automatic update prompts
    [switch]$ListOnly     # List updates only, no installations
)

# ============================================================================
# Helper Functions
# ============================================================================

<#
.SYNOPSIS
    Writes colored output to the console for better visual organization.
.PARAMETER Message
    The text message to display.
.PARAMETER Color
    The foreground color for the text (default: White).
#>
function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

# ============================================================================
# Winget Update Checker Function
# ============================================================================

<#
.SYNOPSIS
    Checks for available Winget package updates and optionally installs them.
.DESCRIPTION
    Lists all packages with available upgrades using winget.
    If -AutoUpdate is enabled and -ListOnly is not set, prompts user to install updates.
#>
function Check-WingetUpdates {
    # Verify winget is installed and accessible
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-ColorOutput "`n=== Winget Packages ===" "Cyan"
        
        try {
            # Query winget for available updates
            # --include-unknown: Shows packages even if their upgrade availability is uncertain
            $updates = winget upgrade --include-unknown | Out-String
            
            # Parse the output to determine if updates are available
            if ($updates -like "*No installed package*" -or $updates -like "*No applicable updates*") {
                Write-ColorOutput "All Winget packages are up to date" "Green"
            } else {
                Write-ColorOutput "Available updates found:" "Yellow"
                # Display the list of available updates
                winget upgrade --include-unknown
                
                # If AutoUpdate is enabled and we're not in ListOnly mode, offer to install
                if ($AutoUpdate -and -not $ListOnly) {
                    $choice = Read-Host "`nDo you want to update all Winget packages? (Y/N)"
                    if ($choice -eq 'Y' -or $choice -eq 'y') {
                        # Upgrade all packages silently
                        winget upgrade --all --silent
                        Write-ColorOutput "Winget packages updated successfully" "Green"
                    }
                }
            }
        } catch {
            # Handle any errors during winget operations
            Write-ColorOutput "Error checking Winget updates: $($_.Exception.Message)" "Red"
        }
    } else {
        # Winget not found on the system
        Write-ColorOutput "Winget is not available" "Red"
    }
}

# ============================================================================
# Microsoft Store Update Checker Function
# ============================================================================

<#
.SYNOPSIS
    Triggers a Microsoft Store update scan.
.DESCRIPTION
    Uses CIM (Common Information Model) to access the MDM namespace and
    initiate a Store app update scan. Actual updates must be viewed/installed
    through the Microsoft Store app.
#>
function Check-StoreUpdates {
    Write-ColorOutput "`n=== Microsoft Store Apps ===" "Cyan"
    
    try {
        # Access MDM (Mobile Device Management) namespace to scan for Store updates
        # This triggers the update check but doesn't automatically install
        $result = Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" `
                                  -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | `
                  Invoke-CimMethod -MethodName UpdateScanMethod
        
        Write-ColorOutput "Microsoft Store update scan initiated" "Green"
        
        # Note: Store apps require the Microsoft Store app for viewing/installing updates
        Write-ColorOutput "Check the Microsoft Store app for available updates" "Yellow"
    } catch {
        # Handle errors (typically permission issues or namespace unavailability)
        Write-ColorOutput "Error checking Store updates: $($_.Exception.Message)" "Red"
    }
}

# ============================================================================
# Chocolatey Update Checker Function
# ============================================================================

<#
.SYNOPSIS
    Checks for outdated Chocolatey packages.
.DESCRIPTION
    Uses 'choco outdated' to list packages that have newer versions available.
#>
function Check-ChocolateyUpdates {
    # Verify Chocolatey is installed and accessible
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-ColorOutput "`n=== Chocolatey Packages ===" "Cyan"
        
        try {
            # List all outdated Chocolatey packages
            # This command shows package name, current version, and available version
            choco outdated
        } catch {
            # Handle any errors during Chocolatey operations
            Write-ColorOutput "Error checking Chocolatey updates: $($_.Exception.Message)" "Red"
        }
    }
}

# ============================================================================
# Installed Software Inventory Function
# ============================================================================

<#
.SYNOPSIS
    Retrieves and displays installed software from the Windows Registry.
.DESCRIPTION
    Reads the Uninstall registry keys to build a comprehensive list of
    installed applications. Shows total count and recently installed apps.
#>
function Get-InstalledSoftware {
    Write-ColorOutput "`n=== Installed Software Overview ===" "Cyan"
    
    # Registry paths where installed software information is stored
    # Both native (64-bit) and WOW6432Node (32-bit on 64-bit systems) paths
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    
    # Query registry for installed applications
    # Filter out entries without DisplayName (incomplete/invalid entries)
    $installed = Get-ItemProperty $paths | 
                 Where-Object { $_.DisplayName } | 
                 Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
    
    # Display total count of installed applications
    Write-ColorOutput "Total installed applications: $($installed.Count)" "White"
    
    # Show the 5 most recently installed applications
    $recent = $installed | Sort-Object InstallDate -Descending | Select-Object -First 5
    Write-ColorOutput "`nRecently installed applications:" "Yellow"
    # Format output as a table for readability
    $recent | Format-Table DisplayName, DisplayVersion, InstallDate -AutoSize
}

# ============================================================================
# Main Execution
# ============================================================================

Write-ColorOutput "Windows 11 Application Update Checker" "Magenta"
Write-ColorOutput "=====================================" "Magenta"

# Display system information
$os = Get-CimInstance Win32_OperatingSystem
Write-ColorOutput "System: $($os.Caption)" "White"
Write-ColorOutput "Version: $($os.Version)" "White"
Write-ColorOutput "Last Boot: $($os.LastBootUpTime)" "White"

# Execute all update checks in sequence
Check-WingetUpdates
Check-StoreUpdates
Check-ChocolateyUpdates
Get-InstalledSoftware

# Display completion message
Write-ColorOutput "`n" + ("=" * 60) "Magenta"
Write-ColorOutput "Update check completed!" "Green"

# Indicate mode of operation
if ($AutoUpdate) {
    Write-ColorOutput "Auto-update mode was enabled" "Yellow"
}
if ($ListOnly) {
    Write-ColorOutput "List-only mode - no updates were installed" "Cyan"
}
Write-ColorOutput ("=" * 60) "Magenta"