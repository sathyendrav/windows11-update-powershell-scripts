<#
.SYNOPSIS
    Core utility module providing logging, configuration, and pre-flight checks.

.DESCRIPTION
    This module provides shared functionality for all update scripts including:
    - Configuration management
    - Logging and transcript management
    - Pre-flight system checks
    - Report generation
    - Notification handling
#>

# ============================================================================
# Configuration Management
# ============================================================================

function Get-UpdateConfig {
    <#
    .SYNOPSIS
        Loads configuration from config.json file.
    #>
    param(
        [string]$ConfigPath = "$PSScriptRoot\..\config.json"
    )
    
    if (Test-Path $ConfigPath) {
        try {
            $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
            return $config
        } catch {
            Write-Warning "Failed to load config.json. Using defaults. Error: $_"
            return $null
        }
    } else {
        Write-Warning "config.json not found at $ConfigPath. Using defaults."
        return $null
    }
}

# ============================================================================
# Logging Functions
# ============================================================================

function Initialize-Logging {
    <#
    .SYNOPSIS
        Initializes logging for the update session.
    #>
    param(
        [string]$LogDirectory = ".\logs",
        [string]$ScriptName = "update-script"
    )
    
    # Create logs directory if it doesn't exist
    if (-not (Test-Path $LogDirectory)) {
        New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
    }
    
    # Generate log filename with timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
    $logFile = Join-Path $LogDirectory "$ScriptName-$timestamp.log"
    
    # Start transcript
    try {
        Start-Transcript -Path $logFile -Append -ErrorAction Stop
        Write-Log "=== Update Session Started ===" -Level "Info"
        Write-Log "Script: $ScriptName" -Level "Info"
        Write-Log "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -Level "Info"
        return $logFile
    } catch {
        Write-Warning "Failed to start transcript: $_"
        return $null
    }
}

function Write-Log {
    <#
    .SYNOPSIS
        Writes a log message with timestamp and level.
    #>
    param(
        [string]$Message,
        [ValidateSet("Info", "Warning", "Error", "Success")]
        [string]$Level = "Info",
        [switch]$NoConsole
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Write to console with color unless suppressed
    if (-not $NoConsole) {
        $color = switch ($Level) {
            "Info"    { "White" }
            "Warning" { "Yellow" }
            "Error"   { "Red" }
            "Success" { "Green" }
        }
        Write-Host $logMessage -ForegroundColor $color
    }
    
    # Write to transcript (automatically logged when transcript is active)
    Write-Verbose $logMessage
}

function Stop-Logging {
    <#
    .SYNOPSIS
        Stops the transcript logging session.
    #>
    param(
        [string]$LogFile
    )
    
    Write-Log "=== Update Session Completed ===" -Level "Info"
    Write-Log "Log file: $LogFile" -Level "Info"
    
    try {
        Stop-Transcript -ErrorAction SilentlyContinue
    } catch {
        # Transcript may not be running
    }
}

# ============================================================================
# Pre-flight Checks
# ============================================================================

function Test-Prerequisites {
    <#
    .SYNOPSIS
        Performs pre-flight checks before running updates.
    #>
    param(
        [switch]$CheckInternet,
        [switch]$CheckDiskSpace,
        [switch]$CheckAdmin,
        [int]$MinFreeSpaceGB = 10
    )
    
    $allChecksPassed = $true
    
    Write-Log "Running pre-flight checks..." -Level "Info"
    
    # Check Administrator privileges
    if ($CheckAdmin) {
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $isAdmin) {
            Write-Log "NOT running as Administrator. Some features may not work." -Level "Warning"
        } else {
            Write-Log "Running with Administrator privileges." -Level "Success"
        }
    }
    
    # Check internet connectivity
    if ($CheckInternet) {
        try {
            $testConnection = Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction Stop
            if ($testConnection) {
                Write-Log "Internet connectivity: OK" -Level "Success"
            } else {
                Write-Log "No internet connectivity detected." -Level "Error"
                $allChecksPassed = $false
            }
        } catch {
            Write-Log "Could not verify internet connectivity: $_" -Level "Warning"
        }
    }
    
    # Check disk space
    if ($CheckDiskSpace) {
        $systemDrive = Get-PSDrive -Name ($env:SystemDrive -replace ':', '') -ErrorAction SilentlyContinue
        if ($systemDrive) {
            $freeSpaceGB = [math]::Round($systemDrive.Free / 1GB, 2)
            if ($freeSpaceGB -lt $MinFreeSpaceGB) {
                Write-Log "Low disk space: ${freeSpaceGB}GB free (minimum ${MinFreeSpaceGB}GB recommended)" -Level "Warning"
                $allChecksPassed = $false
            } else {
                Write-Log "Disk space: ${freeSpaceGB}GB free" -Level "Success"
            }
        }
    }
    
    Write-Log "Pre-flight checks completed." -Level "Info"
    return $allChecksPassed
}

function Test-UpdateSource {
    <#
    .SYNOPSIS
        Tests if an update source (Winget, Chocolatey, Store) is available.
    #>
    param(
        [ValidateSet("Winget", "Chocolatey", "Store")]
        [string]$Source
    )
    
    switch ($Source) {
        "Winget" {
            return (Get-Command winget -ErrorAction SilentlyContinue) -ne $null
        }
        "Chocolatey" {
            return (Get-Command choco -ErrorAction SilentlyContinue) -ne $null
        }
        "Store" {
            # Check if MDM namespace is accessible
            try {
                $null = Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" -ErrorAction Stop
                return $true
            } catch {
                return $false
            }
        }
    }
}

# ============================================================================
# System Restore Point
# ============================================================================

function New-UpdateRestorePoint {
    <#
    .SYNOPSIS
        Creates a system restore point before updates.
    #>
    param(
        [string]$Description = "Windows Update Helper - Before Updates"
    )
    
    try {
        Write-Log "Creating system restore point..." -Level "Info"
        
        # Enable system restore if not enabled
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        
        # Create restore point
        Checkpoint-Computer -Description $Description -RestorePointType "MODIFY_SETTINGS"
        Write-Log "System restore point created successfully." -Level "Success"
        return $true
    } catch {
        Write-Log "Failed to create restore point: $_" -Level "Warning"
        return $false
    }
}

# ============================================================================
# Report Generation
# ============================================================================

function Export-UpdateReport {
    <#
    .SYNOPSIS
        Exports update results to HTML or CSV format.
    #>
    param(
        [Parameter(Mandatory)]
        [hashtable]$ReportData,
        
        [ValidateSet("HTML", "CSV", "JSON")]
        [string]$Format = "HTML",
        
        [string]$OutputPath = ".\reports"
    )
    
    # Create reports directory
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
    $fileName = "update-report-$timestamp"
    
    switch ($Format) {
        "HTML" {
            $filePath = Join-Path $OutputPath "$fileName.html"
            $html = ConvertTo-HtmlReport -Data $ReportData
            $html | Out-File -FilePath $filePath -Encoding UTF8
        }
        "CSV" {
            $filePath = Join-Path $OutputPath "$fileName.csv"
            $ReportData.Updates | Export-Csv -Path $filePath -NoTypeInformation
        }
        "JSON" {
            $filePath = Join-Path $OutputPath "$fileName.json"
            $ReportData | ConvertTo-Json -Depth 10 | Out-File -FilePath $filePath -Encoding UTF8
        }
    }
    
    Write-Log "Report saved to: $filePath" -Level "Success"
    return $filePath
}

function ConvertTo-HtmlReport {
    <#
    .SYNOPSIS
        Converts report data to HTML format.
    #>
    param(
        [hashtable]$Data
    )
    
    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Windows Update Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background-color: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #0078D4; border-bottom: 2px solid #0078D4; padding-bottom: 10px; }
        h2 { color: #333; margin-top: 20px; }
        .info { background-color: #E8F4FD; padding: 10px; border-left: 4px solid #0078D4; margin: 10px 0; }
        .success { color: #107C10; font-weight: bold; }
        .warning { color: #FF8C00; font-weight: bold; }
        .error { color: #D13438; font-weight: bold; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th { background-color: #0078D4; color: white; padding: 12px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #ddd; }
        tr:hover { background-color: #f5f5f5; }
        .timestamp { color: #666; font-size: 0.9em; }
        .footer { margin-top: 20px; text-align: center; color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Windows Update Report</h1>
        <div class="info">
            <p><strong>Generated:</strong> <span class="timestamp">$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</span></p>
            <p><strong>System:</strong> $($Data.SystemInfo.OS)</p>
            <p><strong>Version:</strong> $($Data.SystemInfo.Version)</p>
        </div>
        
        <h2>Update Summary</h2>
        <table>
            <tr><th>Source</th><th>Status</th><th>Updates Found</th></tr>
            <tr><td>Microsoft Store</td><td class="$($Data.Store.Status.ToLower())">$($Data.Store.Status)</td><td>$($Data.Store.Count)</td></tr>
            <tr><td>Winget</td><td class="$($Data.Winget.Status.ToLower())">$($Data.Winget.Status)</td><td>$($Data.Winget.Count)</td></tr>
            <tr><td>Chocolatey</td><td class="$($Data.Chocolatey.Status.ToLower())">$($Data.Chocolatey.Status)</td><td>$($Data.Chocolatey.Count)</td></tr>
        </table>
        
        <div class="footer">
            <p>Generated by Windows Update Helper Scripts</p>
        </div>
    </div>
</body>
</html>
"@
    
    return $html
}

# ============================================================================
# Rollback Functions
# ============================================================================

function Get-SystemRestorePoints {
    <#
    .SYNOPSIS
        Lists all available system restore points.
    .DESCRIPTION
        Retrieves system restore points created by Windows and this script.
    .EXAMPLE
        Get-SystemRestorePoints | Format-Table
    #>
    try {
        $restorePoints = Get-ComputerRestorePoint | Select-Object -Property `
            SequenceNumber,
            CreationTime,
            Description,
            RestorePointType,
            @{Name='Size';Expression={[math]::Round($_.Size/1GB, 2)}}
        
        return $restorePoints
    } catch {
        Write-Warning "Failed to retrieve restore points: $_"
        return $null
    }
}

function Invoke-SystemRestore {
    <#
    .SYNOPSIS
        Restores system to a previous restore point.
    .DESCRIPTION
        Initiates system restore to a specified restore point sequence number.
        Requires administrator privileges and will restart the computer.
    .PARAMETER SequenceNumber
        The sequence number of the restore point to restore to.
    .PARAMETER Confirm
        If specified, prompts for confirmation before restoring.
    .EXAMPLE
        Invoke-SystemRestore -SequenceNumber 123 -Confirm
    #>
    param(
        [Parameter(Mandatory = $true)]
        [int]$SequenceNumber,
        
        [switch]$Confirm
    )
    
    # Check admin privileges
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Warning "System restore requires Administrator privileges"
        return $false
    }
    
    try {
        # Verify restore point exists
        $restorePoint = Get-ComputerRestorePoint | Where-Object { $_.SequenceNumber -eq $SequenceNumber }
        
        if (-not $restorePoint) {
            Write-Warning "Restore point with sequence number $SequenceNumber not found"
            return $false
        }
        
        Write-Host "Restore Point Details:" -ForegroundColor Cyan
        Write-Host "  Sequence Number: $($restorePoint.SequenceNumber)" -ForegroundColor White
        Write-Host "  Created: $($restorePoint.CreationTime)" -ForegroundColor White
        Write-Host "  Description: $($restorePoint.Description)" -ForegroundColor White
        Write-Host ""
        
        if ($Confirm) {
            $response = Read-Host "This will restart your computer. Continue? (Y/N)"
            if ($response -ne 'Y' -and $response -ne 'y') {
                Write-Host "System restore cancelled" -ForegroundColor Yellow
                return $false
            }
        }
        
        Write-Host "Initiating system restore..." -ForegroundColor Yellow
        Write-Host "Your computer will restart and restore to the selected point" -ForegroundColor Yellow
        
        # Restore using rstrui.exe with /offline parameter for automated restore
        Restore-Computer -RestorePoint $SequenceNumber -Confirm:$false
        
        return $true
    } catch {
        Write-Warning "Failed to initiate system restore: $_"
        return $false
    }
}

function Get-PackageHistory {
    <#
    .SYNOPSIS
        Retrieves package installation/update history.
    .DESCRIPTION
        Gets history of package operations from Winget and Chocolatey.
    .PARAMETER Source
        The package source: Winget, Chocolatey, or All.
    .PARAMETER Days
        Number of days of history to retrieve (default: 30).
    .EXAMPLE
        Get-PackageHistory -Source All -Days 7
    #>
    param(
        [ValidateSet("Winget", "Chocolatey", "All")]
        [string]$Source = "All",
        
        [int]$Days = 30
    )
    
    $history = @()
    $startDate = (Get-Date).AddDays(-$Days)
    
    # Winget history (from logs)
    if ($Source -in @("Winget", "All")) {
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            try {
                # Winget doesn't have built-in history command, check logs
                $wingetLogPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\DiagOutputDir"
                if (Test-Path $wingetLogPath) {
                    $logFiles = Get-ChildItem -Path $wingetLogPath -Filter "*.log" | 
                                Where-Object { $_.LastWriteTime -gt $startDate }
                    
                    Write-Host "Note: Winget history available in logs at: $wingetLogPath" -ForegroundColor Gray
                }
            } catch {
                Write-Verbose "Could not access Winget history: $_"
            }
        }
    }
    
    # Chocolatey history
    if ($Source -in @("Chocolatey", "All")) {
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            try {
                $chocoLogPath = "$env:ChocolateyInstall\logs\chocolatey.log"
                if (Test-Path $chocoLogPath) {
                    $logContent = Get-Content $chocoLogPath | Select-Object -Last 1000
                    $recentOps = $logContent | Where-Object { 
                        $_ -match "installed|upgraded|uninstalled" 
                    }
                    
                    foreach ($op in $recentOps) {
                        if ($op -match "\[.*?\] (.+?) v([\d\.]+)") {
                            $history += [PSCustomObject]@{
                                Source = "Chocolatey"
                                Package = $matches[1]
                                Version = $matches[2]
                                Operation = if ($op -match "installed") { "Install" } 
                                           elseif ($op -match "upgraded") { "Upgrade" } 
                                           else { "Uninstall" }
                                Timestamp = "See log file"
                            }
                        }
                    }
                }
            } catch {
                Write-Verbose "Could not access Chocolatey history: $_"
            }
        }
    }
    
    return $history
}

function Invoke-PackageRollback {
    <#
    .SYNOPSIS
        Rolls back a package to a previous version.
    .DESCRIPTION
        Attempts to downgrade a package using Winget or Chocolatey.
    .PARAMETER PackageName
        The name/ID of the package to rollback.
    .PARAMETER Version
        The target version to rollback to.
    .PARAMETER Source
        The package source: Winget or Chocolatey.
    .EXAMPLE
        Invoke-PackageRollback -PackageName "7zip.7zip" -Version "21.07" -Source Winget
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName,
        
        [Parameter(Mandatory = $true)]
        [string]$Version,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet("Winget", "Chocolatey")]
        [string]$Source
    )
    
    Write-Host "Attempting to rollback $PackageName to version $Version..." -ForegroundColor Yellow
    
    try {
        switch ($Source) {
            "Winget" {
                if (Get-Command winget -ErrorAction SilentlyContinue) {
                    # Winget doesn't support direct downgrade, need to uninstall and install specific version
                    Write-Host "Uninstalling current version..." -ForegroundColor Yellow
                    $uninstallResult = winget uninstall $PackageName --silent --accept-source-agreements
                    
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "Installing version $Version..." -ForegroundColor Yellow
                        $installResult = winget install $PackageName --version $Version --silent --accept-source-agreements --accept-package-agreements
                        
                        if ($LASTEXITCODE -eq 0) {
                            Write-Host "Successfully rolled back $PackageName to version $Version" -ForegroundColor Green
                            return $true
                        }
                    }
                    
                    Write-Warning "Rollback failed. Check if version $Version is available."
                    return $false
                } else {
                    Write-Warning "Winget is not available"
                    return $false
                }
            }
            
            "Chocolatey" {
                if (Get-Command choco -ErrorAction SilentlyContinue) {
                    # Chocolatey supports version pinning
                    Write-Host "Installing specific version using Chocolatey..." -ForegroundColor Yellow
                    $result = choco install $PackageName --version $Version --allow-downgrade --yes --force
                    
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "Successfully rolled back $PackageName to version $Version" -ForegroundColor Green
                        return $true
                    } else {
                        Write-Warning "Rollback failed. Check if version $Version is available."
                        return $false
                    }
                } else {
                    Write-Warning "Chocolatey is not available"
                    return $false
                }
            }
        }
    } catch {
        Write-Warning "Error during rollback: $_"
        return $false
    }
}

# ============================================================================
# Notification Functions
# ============================================================================

function Send-ToastNotification {
    <#
    .SYNOPSIS
        Sends a Windows toast notification.
    .DESCRIPTION
        Creates and displays a native Windows 10/11 toast notification using
        the Windows.UI.Notifications API.
    .PARAMETER Title
        The title/heading of the notification.
    .PARAMETER Message
        The main message body of the notification.
    .PARAMETER AppId
        The application identifier (default: Windows PowerShell).
    .PARAMETER Icon
        The type of icon to display: Info, Success, Warning, Error.
    .EXAMPLE
        Send-ToastNotification -Title "Updates Available" -Message "5 packages can be updated" -Icon Info
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,
        
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [string]$AppId = "Windows.PowerShell.UpdateHelper",
        
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Icon = "Info"
    )
    
    try {
        # Load required Windows Runtime assemblies
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        [Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null
        
        # Map icon types to scenario strings
        $scenarioMap = @{
            "Info"    = "reminder"
            "Success" = "reminder"
            "Warning" = "alarm"
            "Error"   = "alarm"
        }
        $scenario = $scenarioMap[$Icon]
        
        # Create toast XML template
        $toastXml = @"
<toast scenario="$scenario">
    <visual>
        <binding template="ToastGeneric">
            <text>$([System.Security.SecurityElement]::Escape($Title))</text>
            <text>$([System.Security.SecurityElement]::Escape($Message))</text>
        </binding>
    </visual>
    <audio src="ms-winsoundevent:Notification.Default" />
</toast>
"@
        
        # Create XML document
        $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
        $xml.LoadXml($toastXml)
        
        # Create and show toast notification
        $toast = New-Object Windows.UI.Notifications.ToastNotification($xml)
        $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppId)
        $notifier.Show($toast)
        
        return $true
    } catch {
        Write-Warning "Failed to send toast notification: $_"
        return $false
    }
}

function Send-UpdateNotification {
    <#
    .SYNOPSIS
        Sends update-specific notifications based on configuration.
    .DESCRIPTION
        Helper function that checks notification settings and sends appropriate
        toast notifications for update operations.
    .PARAMETER Type
        The type of notification: Start, Complete, Error, UpdatesFound, NoUpdates.
    .PARAMETER Details
        Additional details to include in the notification message.
    .PARAMETER Config
        Configuration object containing notification settings.
    .EXAMPLE
        Send-UpdateNotification -Type "Complete" -Details "15 packages updated successfully" -Config $config
    #>
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Start", "Complete", "Error", "UpdatesFound", "NoUpdates")]
        [string]$Type,
        
        [string]$Details = "",
        
        [object]$Config = $null
    )
    
    # Check if notifications are enabled
    if (-not $Config -or -not $Config.Notifications -or -not $Config.Notifications.EnableToastNotifications) {
        return $false
    }
    
    # Define notification templates
    $templates = @{
        "Start" = @{
            Title = "Update Check Started"
            Message = "Scanning for available updates..."
            Icon = "Info"
        }
        "Complete" = @{
            Title = "Updates Complete"
            Message = if ($Details) { $Details } else { "Update process completed successfully" }
            Icon = "Success"
        }
        "Error" = @{
            Title = "Update Error"
            Message = if ($Details) { $Details } else { "An error occurred during the update process" }
            Icon = "Error"
        }
        "UpdatesFound" = @{
            Title = "Updates Available"
            Message = if ($Details) { $Details } else { "Updates are available for installation" }
            Icon = "Warning"
        }
        "NoUpdates" = @{
            Title = "System Up to Date"
            Message = "All packages are up to date"
            Icon = "Success"
        }
    }
    
    $template = $templates[$Type]
    
    # Send the notification
    return Send-ToastNotification -Title $template.Title -Message $template.Message -Icon $template.Icon
}

# Export module members
Export-ModuleMember -Function @(
    'Get-UpdateConfig',
    'Initialize-Logging',
    'Write-Log',
    'Stop-Logging',
    'Test-Prerequisites',
    'Test-UpdateSource',
    'New-UpdateRestorePoint',
    'Export-UpdateReport',
    'Send-ToastNotification',
    'Send-UpdateNotification',
    'Get-SystemRestorePoints',
    'Invoke-SystemRestore',
    'Get-PackageHistory',
    'Invoke-PackageRollback'
)
