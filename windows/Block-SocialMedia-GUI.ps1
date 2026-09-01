# GUI for Ficus (Windows).
# Double-click Launch-GUI.bat to run this (it will prompt for admin rights via UAC).

param()

. "$PSScriptRoot\SocialMediaBlockerCore.ps1"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Self-elevate if not running as admin ---
if (-not (Test-IsAdmin)) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell.exe"
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $psi.Verb = "runas"
    try {
        [System.Diagnostics.Process]::Start($psi) | Out-Null
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Administrator rights are required to edit the hosts file. The app will now close.", "Ficus") | Out-Null
    }
    exit
}

$configPath = "$PSScriptRoot\config.json"

function Get-DomainConfig {
    if (Test-Path $configPath) {
        try {
            $raw = Get-Content -Path $configPath -Raw | ConvertFrom-Json
            $list = @($raw | ForEach-Object { [PSCustomObject]@{ Domain = [string]$_.Domain; Checked = [bool]$_.Checked } })
            if ($list.Count -gt 0) { return $list }
        } catch {
            # fall through to defaults on any parse error
        }
    }
    return @($Script:DefaultDomains | ForEach-Object { [PSCustomObject]@{ Domain = $_; Checked = $true } })
}

function Save-DomainConfig {
    param([object[]]$Config)
    $Config | ConvertTo-Json | Set-Content -Path $configPath -Encoding UTF8
}

$script:domainConfig = Get-DomainConfig

# --- Form ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Ficus"
$form.Size = New-Object System.Drawing.Size(400, 520)
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.StartPosition = "CenterScreen"

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Location = New-Object System.Drawing.Point(15, 15)
$lblStatus.Size = New-Object System.Drawing.Size(355, 30)
$lblStatus.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$lblStatus.TextAlign = "MiddleCenter"
$form.Controls.Add($lblStatus)

$lblList = New-Object System.Windows.Forms.Label
$lblList.Location = New-Object System.Drawing.Point(15, 55)
$lblList.Size = New-Object System.Drawing.Size(355, 20)
$lblList.Text = "Sites to block (unchecked = allowed):"
$form.Controls.Add($lblList)

$clbDomains = New-Object System.Windows.Forms.CheckedListBox
$clbDomains.Location = New-Object System.Drawing.Point(15, 78)
$clbDomains.Size = New-Object System.Drawing.Size(355, 260)
$clbDomains.CheckOnClick = $true
foreach ($entry in $script:domainConfig) {
    [void]$clbDomains.Items.Add($entry.Domain, $entry.Checked)
}
$form.Controls.Add($clbDomains)

$clbDomains.add_ItemCheck({
    param($s, $e)
    $domain = $clbDomains.Items[$e.Index].ToString()
    $isChecked = ($e.NewValue -eq [System.Windows.Forms.CheckState]::Checked)
    $entry = $script:domainConfig | Where-Object { $_.Domain -eq $domain }
    if ($entry) { $entry.Checked = $isChecked }
    Save-DomainConfig -Config $script:domainConfig
}.GetNewClosure())

$txtAdd = New-Object System.Windows.Forms.TextBox
$txtAdd.Location = New-Object System.Drawing.Point(15, 348)
$txtAdd.Size = New-Object System.Drawing.Size(260, 24)
$form.Controls.Add($txtAdd)

$btnAdd = New-Object System.Windows.Forms.Button
$btnAdd.Location = New-Object System.Drawing.Point(280, 347)
$btnAdd.Size = New-Object System.Drawing.Size(90, 26)
$btnAdd.Text = "Add site"
$form.Controls.Add($btnAdd)

$btnAdd.add_Click({
    $domain = $txtAdd.Text.Trim().ToLowerInvariant()
    if ($domain -notmatch '^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$') {
        [System.Windows.Forms.MessageBox]::Show("Enter a valid domain, e.g. example.com", "Ficus") | Out-Null
        return
    }
    if ($script:domainConfig.Domain -contains $domain) {
        [System.Windows.Forms.MessageBox]::Show("$domain is already in the list.", "Ficus") | Out-Null
        return
    }
    $script:domainConfig += [PSCustomObject]@{ Domain = $domain; Checked = $true }
    Save-DomainConfig -Config $script:domainConfig
    [void]$clbDomains.Items.Add($domain, $true)
    $txtAdd.Clear()
}.GetNewClosure())

$btnToggle = New-Object System.Windows.Forms.Button
$btnToggle.Location = New-Object System.Drawing.Point(15, 390)
$btnToggle.Size = New-Object System.Drawing.Size(355, 45)
$btnToggle.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btnToggle)

$lblFooter = New-Object System.Windows.Forms.Label
$lblFooter.Location = New-Object System.Drawing.Point(15, 445)
$lblFooter.Size = New-Object System.Drawing.Size(355, 55)
$lblFooter.ForeColor = [System.Drawing.Color]::DimGray
$lblFooter.Text = "Note: if a browser has 'Secure DNS' / DNS-over-HTTPS enabled, it can bypass this block. Turn it off in browser settings if a blocked site still loads."
$form.Controls.Add($lblFooter)

function Refresh-Status {
    if (Test-SocialMediaBlocked) {
        $lblStatus.Text = "STATUS: BLOCKED"
        $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(180, 0, 0)
        $btnToggle.Text = "Unblock Now"
        $btnToggle.BackColor = [System.Drawing.Color]::FromArgb(220, 220, 220)
    } else {
        $lblStatus.Text = "STATUS: NOT BLOCKED"
        $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(0, 130, 0)
        $btnToggle.Text = "Block Now"
        $btnToggle.BackColor = [System.Drawing.Color]::FromArgb(200, 230, 200)
    }
}

$btnToggle.add_Click({
    if (Test-SocialMediaBlocked) {
        Disable-SocialMediaBlock
    } else {
        $checked = @($script:domainConfig | Where-Object { $_.Checked } | ForEach-Object { $_.Domain })
        if ($checked.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Check at least one site to block.", "Ficus") | Out-Null
            return
        }
        Enable-SocialMediaBlock -Domains $checked
    }
    Refresh-Status
}.GetNewClosure())

Refresh-Status
[void]$form.ShowDialog()
