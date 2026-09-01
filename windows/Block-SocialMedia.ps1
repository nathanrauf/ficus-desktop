# Blocks or unblocks social media domains device-wide via the Windows hosts file.
# Must be run as Administrator.
#
# Usage:
#   .\Block-SocialMedia.ps1            # enable the block
#   .\Block-SocialMedia.ps1 -Disable   # remove the block
#
# To customize which domains are blocked, edit $DefaultDomains in
# SocialMediaBlockerCore.ps1 (or use the GUI, which lets you pick per-domain).

param(
    [switch]$Disable
)

. "$PSScriptRoot\SocialMediaBlockerCore.ps1"

if (-not (Test-IsAdmin)) {
    Write-Error "This script must be run as Administrator. Right-click PowerShell and choose 'Run as Administrator', then re-run this script."
    exit 1
}

if ($Disable) {
    Disable-SocialMediaBlock
    Write-Host "Social media block removed."
} else {
    Enable-SocialMediaBlock
    Write-Host "Social media domains blocked ($($Script:DefaultDomains.Count) entries)."
}

Write-Host "DNS cache flushed. Restart open browsers for the change to take full effect."
