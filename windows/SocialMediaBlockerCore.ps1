# Shared logic used by both Block-SocialMedia.ps1 (CLI) and Block-SocialMedia-GUI.ps1.
# Dot-source this file to get access to the functions below.

$Script:HostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
$Script:MarkerStart = "# >>> social-media-blocker >>>"
$Script:MarkerEnd = "# <<< social-media-blocker <<<"

$Script:DefaultDomains = @(
    "facebook.com", "www.facebook.com", "m.facebook.com", "fb.com", "www.fb.com",
    "instagram.com", "www.instagram.com",
    "twitter.com", "www.twitter.com", "x.com", "www.x.com",
    "tiktok.com", "www.tiktok.com", "m.tiktok.com",
    "reddit.com", "www.reddit.com", "old.reddit.com",
    "snapchat.com", "www.snapchat.com",
    "pinterest.com", "www.pinterest.com",
    "tumblr.com", "www.tumblr.com",
    "threads.net", "www.threads.net",
    "linkedin.com", "www.linkedin.com"
)

function Test-IsAdmin {
    $p = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-SocialMediaBlocked {
    $content = Get-Content -Path $Script:HostsPath -Raw -ErrorAction SilentlyContinue
    if ($null -eq $content) { return $false }
    return [bool]([regex]::Match($content, [regex]::Escape($Script:MarkerStart))).Success
}

function Enable-SocialMediaBlock {
    param([string[]]$Domains = $Script:DefaultDomains)

    $content = Get-Content -Path $Script:HostsPath -Raw
    if ($null -eq $content) { $content = "" }
    $pattern = "(?s)\r?\n?" + [regex]::Escape($Script:MarkerStart) + ".*?" + [regex]::Escape($Script:MarkerEnd) + "\r?\n?"
    $cleaned = [regex]::Replace($content, $pattern, "`r`n")

    $backupPath = "$Script:HostsPath.bak"
    if (-not (Test-Path $backupPath)) {
        Copy-Item -Path $Script:HostsPath -Destination $backupPath
    }

    $blockLines = $Domains | ForEach-Object { "0.0.0.0`t$_", "::1`t$_" }
    $blockText = "$Script:MarkerStart`r`n" + ($blockLines -join "`r`n") + "`r`n$Script:MarkerEnd"
    $newContent = $cleaned.TrimEnd() + "`r`n`r`n" + $blockText + "`r`n"

    Set-Content -Path $Script:HostsPath -Value $newContent -Encoding ASCII
    ipconfig /flushdns | Out-Null
}

function Disable-SocialMediaBlock {
    $content = Get-Content -Path $Script:HostsPath -Raw
    if ($null -eq $content) { $content = "" }
    $pattern = "(?s)\r?\n?" + [regex]::Escape($Script:MarkerStart) + ".*?" + [regex]::Escape($Script:MarkerEnd) + "\r?\n?"
    $cleaned = [regex]::Replace($content, $pattern, "`r`n")

    Set-Content -Path $Script:HostsPath -Value $cleaned.TrimEnd() -Encoding ASCII
    ipconfig /flushdns | Out-Null
}
