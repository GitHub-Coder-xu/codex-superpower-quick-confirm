#requires -Version 5.1

param(
    [switch]$SelfTest
)

$ErrorActionPreference = 'Stop'

if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne [System.Threading.ApartmentState]::STA) {
    throw 'Codex Quick Confirm must run in STA mode. Start it with ..\scripts\start.ps1.'
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

if (-not ('CodexQuickConfirmWin32' -as [type])) {
    Add-Type @'
using System;
using System.Runtime.InteropServices;

public static class CodexQuickConfirmWin32
{
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool ReleaseCapture();

    [DllImport("user32.dll")]
    public static extern IntPtr SendMessage(IntPtr hWnd, int msg, int wParam, int lParam);
}
'@
}

# QUICK_CONFIRM_PHRASES_BEGIN
$script:Phrases = @(
    '确认',
    '继续',
    '是',
    '否',
    '1',
    '2',
    '3',
    '4',
    'A',
    'B',
    'C',
    'D'
)
# QUICK_CONFIRM_PHRASES_END

$script:ToolWindowHandle = [IntPtr]::Zero
$script:LastTargetWindow = [IntPtr]::Zero
$script:WM_NCLBUTTONDOWN = 0x00A1
$script:HTCAPTION = 0x0002

function Restore-ClipboardData {
    param(
        [System.Windows.Forms.IDataObject]$DataObject
    )

    if ($null -eq $DataObject) {
        return
    }

    try {
        [System.Windows.Forms.Clipboard]::SetDataObject($DataObject, $true)
    }
    catch {
        # Clipboard ownership is external and can be temporarily unavailable.
    }
}

function Invoke-QuickSend {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Phrase
    )

    if ($script:LastTargetWindow -eq [IntPtr]::Zero) {
        [System.Media.SystemSounds]::Beep.Play()
        return
    }

    $previousClipboard = $null

    try {
        $previousClipboard = [System.Windows.Forms.Clipboard]::GetDataObject()
    }
    catch {
        $previousClipboard = $null
    }

    try {
        [CodexQuickConfirmWin32]::SetForegroundWindow($script:LastTargetWindow) | Out-Null
        Start-Sleep -Milliseconds 90

        [System.Windows.Forms.Clipboard]::SetText($Phrase, [System.Windows.Forms.TextDataFormat]::UnicodeText)
        Start-Sleep -Milliseconds 40

        [System.Windows.Forms.SendKeys]::SendWait('^v')
        Start-Sleep -Milliseconds 40
        [System.Windows.Forms.SendKeys]::SendWait('{ENTER}')
    }
    finally {
        Restore-ClipboardData -DataObject $previousClipboard
    }
}

function Start-WindowDrag {
    [CodexQuickConfirmWin32]::ReleaseCapture() | Out-Null
    [CodexQuickConfirmWin32]::SendMessage($form.Handle, $script:WM_NCLBUTTONDOWN, $script:HTCAPTION, 0) | Out-Null
}

[System.Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Codex Quick Confirm'
$form.TopMost = $true
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.ShowInTaskbar = $true
$form.ClientSize = New-Object System.Drawing.Size(360, 198)
$form.Font = New-Object System.Drawing.Font('Microsoft YaHei UI', 10)
$form.BackColor = [System.Drawing.Color]::FromArgb(210, 215, 222)

function Set-TopMostState {
    param(
        [Parameter(Mandatory = $true)]
        [bool]$enabled,

        [Parameter(Mandatory = $true)]
        [System.Windows.Forms.Button]$ToggleButton
    )

    $form.TopMost = $enabled

    if ($enabled) {
        $ToggleButton.Text = '取消置顶'
    }
    else {
        $ToggleButton.Text = '恢复置顶'
    }
}

$root = New-Object System.Windows.Forms.TableLayoutPanel
$root.Dock = [System.Windows.Forms.DockStyle]::Fill
$root.ColumnCount = 1
$root.RowCount = 2
$root.Padding = New-Object System.Windows.Forms.Padding(1)
[void]$root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 34)))
[void]$root.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 100)))

$captionBar = New-Object System.Windows.Forms.TableLayoutPanel
$captionBar.Dock = [System.Windows.Forms.DockStyle]::Fill
$captionBar.ColumnCount = 4
$captionBar.RowCount = 1
$captionBar.BackColor = [System.Drawing.Color]::FromArgb(245, 247, 250)
$captionBar.Margin = New-Object System.Windows.Forms.Padding(0)
$captionBar.Padding = New-Object System.Windows.Forms.Padding(8, 0, 4, 0)
[void]$captionBar.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100)))
[void]$captionBar.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 78)))
[void]$captionBar.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 64)))
[void]$captionBar.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Absolute, 34)))
$captionBar.Add_MouseDown({
    param($sender, $eventArgs)
    if ($eventArgs.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        Start-WindowDrag
    }
})

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = 'Codex Quick Confirm'
$titleLabel.Dock = [System.Windows.Forms.DockStyle]::Fill
$titleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$titleLabel.Font = New-Object System.Drawing.Font('Microsoft YaHei UI', 9, [System.Drawing.FontStyle]::Regular)
$titleLabel.Add_MouseDown({
    param($sender, $eventArgs)
    if ($eventArgs.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        Start-WindowDrag
    }
})

$minimizeButton = New-Object System.Windows.Forms.Button
$minimizeButton.Text = '最小化'
$minimizeButton.Dock = [System.Windows.Forms.DockStyle]::Fill
$minimizeButton.Margin = New-Object System.Windows.Forms.Padding(2, 4, 2, 4)
$minimizeButton.UseVisualStyleBackColor = $true
$minimizeButton.Add_Click({
    $form.WindowState = [System.Windows.Forms.FormWindowState]::Minimized
})

$topMostButton = New-Object System.Windows.Forms.Button
$topMostButton.Text = '取消置顶'
$topMostButton.Dock = [System.Windows.Forms.DockStyle]::Fill
$topMostButton.Margin = New-Object System.Windows.Forms.Padding(2, 4, 2, 4)
$topMostButton.UseVisualStyleBackColor = $true
$topMostButton.Add_Click({
    Set-TopMostState -enabled (-not $form.TopMost) -ToggleButton $topMostButton
})

$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Text = 'X'
$closeButton.Dock = [System.Windows.Forms.DockStyle]::Fill
$closeButton.Margin = New-Object System.Windows.Forms.Padding(2, 4, 0, 4)
$closeButton.UseVisualStyleBackColor = $true
$closeButton.Add_Click({
    $form.Close()
})

[void]$captionBar.Controls.Add($titleLabel, 0, 0)
[void]$captionBar.Controls.Add($topMostButton, 1, 0)
[void]$captionBar.Controls.Add($minimizeButton, 2, 0)
[void]$captionBar.Controls.Add($closeButton, 3, 0)

$table = New-Object System.Windows.Forms.TableLayoutPanel
$table.Dock = [System.Windows.Forms.DockStyle]::Fill
$table.ColumnCount = 4
$table.RowCount = 3
$table.BackColor = [System.Drawing.SystemColors]::Control
$table.Padding = New-Object System.Windows.Forms.Padding(8)

for ($index = 0; $index -lt 4; $index++) {
    [void]$table.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 25)))
}

for ($index = 0; $index -lt 3; $index++) {
    [void]$table.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 33.3333)))
}

foreach ($phrase in $script:Phrases) {
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $phrase
    $button.Tag = $phrase
    $button.Dock = [System.Windows.Forms.DockStyle]::Fill
    $button.Margin = New-Object System.Windows.Forms.Padding(4)
    $button.Font = New-Object System.Drawing.Font('Microsoft YaHei UI', 12, [System.Drawing.FontStyle]::Regular)
    $button.UseVisualStyleBackColor = $true
    $button.Add_Click({
        param($sender, $eventArgs)
        Invoke-QuickSend -Phrase ([string]$sender.Tag)
    })

    [void]$table.Controls.Add($button)
}

[void]$root.Controls.Add($captionBar, 0, 0)
[void]$root.Controls.Add($table, 0, 1)
$form.Controls.Add($root)

$targetTracker = New-Object System.Windows.Forms.Timer
$targetTracker.Interval = 150
$targetTracker.Add_Tick({
    $foregroundWindow = [CodexQuickConfirmWin32]::GetForegroundWindow()

    if ($foregroundWindow -eq [IntPtr]::Zero) {
        return
    }

    if ($script:ToolWindowHandle -ne [IntPtr]::Zero -and $foregroundWindow -eq $script:ToolWindowHandle) {
        return
    }

    $script:LastTargetWindow = $foregroundWindow
})

$form.Add_Shown({
    $script:ToolWindowHandle = $form.Handle
    $targetTracker.Start()
})

$form.Add_FormClosed({
    $targetTracker.Stop()
    $targetTracker.Dispose()
})

if ($SelfTest) {
    $selfTestTimer = New-Object System.Windows.Forms.Timer
    $selfTestTimer.Interval = 250
    $selfTestTimer.Add_Tick({
        $selfTestTimer.Stop()
        $form.Close()
    })

    $form.Add_Shown({
        Write-Host 'Self-test window shown.'
        $selfTestTimer.Start()
    })

    $form.Add_FormClosed({
        $selfTestTimer.Dispose()
    })
}

[void][System.Windows.Forms.Application]::Run($form)




