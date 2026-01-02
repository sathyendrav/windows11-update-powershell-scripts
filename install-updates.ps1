<#
.SYNOPSIS
    Automated Windows Update Installer - Updates Microsoft Store, Winget, and Chocolatey packages.

.DESCRIPTION
    This script automatically checks for and installs updates across three package management platforms:
    - Microsoft Store apps (via CIM/WMI)
    - Winget packages (Windows Package Manager)
    - Chocolatey packages (Community Package Manager)
    
    All updates are performed in silent/non-interactive mode where possible.

.PARAMETER DisableStoreUpdates
    Skip Microsoft Store app updates.

.PARAMETER DisableWingetUpdates
    Skip Winget package updates.

.PARAMETER DisableChocolateyUpdates
    Skip Chocolatey package updates.

.PARAMETER Verbose
    Display detailed output during execution.

.NOTES
    File Name      : install-updates.ps1
    Author         : Sathyendra Vemulapalli
    Prerequisite   : PowerShell 5.1 or later, Administrator privileges recommended
    Required Tools : Winget (App Installer), Chocolatey (optional)
    
.EXAMPLE
    .\install-updates.ps1
    Runs all update checks and installations automatically.

.EXAMPLE
    .\install-updates.ps1 -DisableStoreUpdates
    Runs updates for Winget and Chocolatey only, skipping Store apps.

.EXAMPLE
    .\install-updates.ps1 -DisableChocolateyUpdates -Verbose
    Updates Store and Winget packages with verbose output.
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Skip Microsoft Store app updates")]
    [switch]$DisableStoreUpdates,
    
    [Parameter(HelpMessage = "Skip Winget package updates")]
    [switch]$DisableWingetUpdates,
    
    [Parameter(HelpMessage = "Skip Chocolatey package updates")]
    [switch]$DisableChocolateyUpdates
)

# Import shared utilities when available (best-effort)
try {
    Import-Module "$PSScriptRoot\UpdateUtilities.psm1" -Force -ErrorAction Stop
} catch {
    # Keep script functional even if module import fails
}

# ============================================================================
# Microsoft Store Updates
# ============================================================================
if (-not $DisableStoreUpdates) {
    Write-Host "Checking for Microsoft Store app updates..." -ForegroundColor Yellow
    
    try {
        # Prefer per-app Store updates via winget msstore when available.
        if ((Get-Command winget -ErrorAction SilentlyContinue) -and (Get-Command Get-WingetUpgradeablePackages -ErrorAction SilentlyContinue)) {
            $storeUpgrades = Get-WingetUpgradeablePackages -Source "msstore"

            if (-not $storeUpgrades -or $storeUpgrades.Count -eq 0) {
                Write-Host "No Microsoft Store (msstore) updates available via winget." -ForegroundColor Gray
            } else {
                Write-Host "Found $($storeUpgrades.Count) Microsoft Store app(s) with updates:" -ForegroundColor Cyan
                foreach ($pkg in $storeUpgrades) {
                    $fromVer = if ($pkg.Version) { $pkg.Version } else { 'Unknown' }
                    $toVer = if ($pkg.AvailableVersion) { $pkg.AvailableVersion } else { 'Latest' }
                    Write-Host "  - $($pkg.Name) ($($pkg.Id)) $fromVer -> $toVer" -ForegroundColor Gray
                }

                $successCount = 0
                $failCount = 0

                foreach ($pkg in $storeUpgrades) {
                    $pkgId = $pkg.Id
                    $pkgName = if ($pkg.Name) { $pkg.Name } else { $pkgId }
                    $fromVer = if ($pkg.Version) { $pkg.Version } else { 'Unknown' }
                    $toVer = if ($pkg.AvailableVersion) { $pkg.AvailableVersion } else { 'Latest' }

                    Write-Host "Updating Store app: $pkgName ($pkgId) $fromVer -> $toVer" -ForegroundColor Yellow
                    $startTime = Get-Date

                    winget upgrade --id $pkgId --exact --source msstore --silent --accept-source-agreements --accept-package-agreements | Out-Null
                    $exitCode = $LASTEXITCODE
                    $duration = (Get-Date) - $startTime

                    if ($exitCode -eq 0) {
                        $successCount++
                        Write-Host "SUCCESS: $pkgId in $([math]::Round($duration.TotalSeconds, 1))s" -ForegroundColor Green
                    } else {
                        $failCount++
                        Write-Host "FAILED:  $pkgId (exit code $exitCode)" -ForegroundColor Red
                    }
                }

                if ($failCount -eq 0) {
                    Write-Host "Microsoft Store apps updated successfully ($successCount updated)." -ForegroundColor Green
                } elseif ($successCount -gt 0) {
                    Write-Host "Microsoft Store updates completed with errors ($successCount succeeded, $failCount failed)." -ForegroundColor Yellow
                } else {
                    Write-Host "Microsoft Store updates failed ($failCount failed)." -ForegroundColor Red
                }
            }
        } else {
            # Fallback: Trigger Store update scan via CIM/MDM (does not provide per-app details)
            Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" `
                            -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | `
                Invoke-CimMethod -MethodName UpdateScanMethod

            Write-Host "Microsoft Store update scan initiated successfully." -ForegroundColor Green
            Write-Host "Note: per-app details require winget msstore support." -ForegroundColor DarkYellow
        }
    } catch {
        # Handle errors if Store updates fail (e.g., insufficient permissions, namespace unavailable)
        Write-Host "Failed to check Microsoft Store updates: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Microsoft Store updates disabled (skipped)." -ForegroundColor Gray
}

# ============================================================================
# Winget (Windows Package Manager) Updates
# ============================================================================

if (-not $DisableWingetUpdates) {
    # Check if winget is installed and available in PATH
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "`nChecking for Winget package updates..." -ForegroundColor Yellow

        # Prefer per-package upgrades so we can log each package result
        if (Get-Command Get-WingetUpgradeablePackages -ErrorAction SilentlyContinue) {
            $upgrades = Get-WingetUpgradeablePackages
            if (-not $upgrades -or $upgrades.Count -eq 0) {
                Write-Host "No Winget package upgrades available." -ForegroundColor Gray
            } else {
                Write-Host "Found $($upgrades.Count) Winget package(s) with upgrades:" -ForegroundColor Cyan
                foreach ($pkg in $upgrades) {
                    $fromVer = if ($pkg.Version) { $pkg.Version } else { 'Unknown' }
                    $toVer = if ($pkg.AvailableVersion) { $pkg.AvailableVersion } else { 'Latest' }
                    Write-Host "  - $($pkg.Name) ($($pkg.Id)) $fromVer -> $toVer" -ForegroundColor Gray
                }

                $successCount = 0
                $failCount = 0

                foreach ($pkg in $upgrades) {
                    $pkgId = $pkg.Id
                    $pkgName = if ($pkg.Name) { $pkg.Name } else { $pkgId }
                    $fromVer = if ($pkg.Version) { $pkg.Version } else { 'Unknown' }
                    $toVer = if ($pkg.AvailableVersion) { $pkg.AvailableVersion } else { 'Latest' }

                    Write-Host "Upgrading: $pkgName ($pkgId) $fromVer -> $toVer" -ForegroundColor Yellow
                    $startTime = Get-Date

                    winget upgrade --id $pkgId --exact --silent --accept-source-agreements --accept-package-agreements | Out-Null
                    $exitCode = $LASTEXITCODE
                    $duration = (Get-Date) - $startTime

                    if ($exitCode -eq 0) {
                        $successCount++
                        Write-Host "SUCCESS: $pkgId in $([math]::Round($duration.TotalSeconds, 1))s" -ForegroundColor Green
                    } else {
                        $failCount++
                        Write-Host "FAILED:  $pkgId (exit code $exitCode)" -ForegroundColor Red
                    }
                }

                if ($failCount -eq 0) {
                    Write-Host "Winget packages updated successfully ($successCount upgraded)." -ForegroundColor Green
                } elseif ($successCount -gt 0) {
                    Write-Host "Winget upgrades completed with errors ($successCount succeeded, $failCount failed)." -ForegroundColor Yellow
                } else {
                    Write-Host "Winget upgrades failed ($failCount failed)." -ForegroundColor Red
                }
            }
        } else {
            # Fallback: Upgrade all packages silently without per-package enumeration
            winget upgrade --all --silent
            Write-Host "Winget packages updated (batch mode)." -ForegroundColor Green
        }
    } else {
        # Winget not found - inform user to install App Installer from Microsoft Store
        Write-Host "Winget is not available on this system" -ForegroundColor Red
        Write-Host "Install 'App Installer' from Microsoft Store to enable Winget" -ForegroundColor Yellow
    }
} else {
    Write-Host "`nWinget updates disabled (skipped)." -ForegroundColor Gray
}

# ============================================================================
# Chocolatey Package Manager Updates
# ============================================================================

if (-not $DisableChocolateyUpdates) {
    # Check if Chocolatey is installed and available in PATH
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "`nChecking for Chocolatey package updates..." -ForegroundColor Yellow

        # Enumerate outdated packages so we can log each one
        $outdatedRaw = choco outdated -r 2>&1 | Out-String
        $outdatedLines = $outdatedRaw -split "`r?`n" | Where-Object { $_ -match '\S' }

        $outdated = @()
        foreach ($line in $outdatedLines) {
            if ($line -notmatch '\|') { continue }
            $parts = $line.Split('|')
            if ($parts.Count -lt 3) { continue }

            $name = $parts[0].Trim()
            $current = $parts[1].Trim()
            $available = $parts[2].Trim()
            $pinned = $false
            if ($parts.Count -ge 4) {
                $pinned = ($parts[3].Trim().ToLowerInvariant() -eq 'true')
            }

            if (-not $name) { continue }

            $outdated += [PSCustomObject]@{
                Name = $name
                CurrentVersion = $current
                AvailableVersion = $available
                Pinned = $pinned
            }
        }

        if (-not $outdated -or $outdated.Count -eq 0) {
            Write-Host "No Chocolatey package upgrades available." -ForegroundColor Gray
        } else {
            Write-Host "Found $($outdated.Count) Chocolatey package(s) with upgrades:" -ForegroundColor Cyan
            foreach ($pkg in $outdated) {
                $fromVer = if ($pkg.CurrentVersion) { $pkg.CurrentVersion } else { 'Unknown' }
                $toVer = if ($pkg.AvailableVersion) { $pkg.AvailableVersion } else { 'Latest' }
                $pinNote = if ($pkg.Pinned) { ' (pinned)' } else { '' }
                Write-Host "  - $($pkg.Name) $fromVer -> $toVer$pinNote" -ForegroundColor Gray
            }

            $successCount = 0
            $failCount = 0

            foreach ($pkg in $outdated) {
                if ($pkg.Pinned) {
                    Write-Host "Skipping pinned package: $($pkg.Name)" -ForegroundColor Yellow
                    continue
                }

                $fromVer = if ($pkg.CurrentVersion) { $pkg.CurrentVersion } else { 'Unknown' }
                $toVer = if ($pkg.AvailableVersion) { $pkg.AvailableVersion } else { 'Latest' }
                Write-Host "Upgrading: $($pkg.Name) $fromVer -> $toVer" -ForegroundColor Yellow
                $startTime = Get-Date

                choco upgrade $($pkg.Name) -y | Out-Null
                $exitCode = $LASTEXITCODE
                $duration = (Get-Date) - $startTime

                if ($exitCode -eq 0) {
                    $successCount++
                    Write-Host "SUCCESS: $($pkg.Name) in $([math]::Round($duration.TotalSeconds, 1))s" -ForegroundColor Green
                } else {
                    $failCount++
                    Write-Host "FAILED:  $($pkg.Name) (exit code $exitCode)" -ForegroundColor Red
                }
            }

            if ($failCount -eq 0) {
                Write-Host "Chocolatey packages updated successfully ($successCount upgraded)." -ForegroundColor Green
            } elseif ($successCount -gt 0) {
                Write-Host "Chocolatey upgrades completed with errors ($successCount succeeded, $failCount failed)." -ForegroundColor Yellow
            } else {
                Write-Host "Chocolatey upgrades failed ($failCount failed)." -ForegroundColor Red
            }
        }
    } else {
        # Chocolatey not found - inform user how to install it
        Write-Host "Chocolatey is not available on this system" -ForegroundColor Red
        Write-Host "Visit https://chocolatey.org/install for installation instructions" -ForegroundColor Yellow
    }
} else {
    Write-Host "`nChocolatey updates disabled (skipped)." -ForegroundColor Gray
}

# ============================================================================
# Completion Message
# ============================================================================
Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
Write-Host "Update check and installation completed!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Cyan

