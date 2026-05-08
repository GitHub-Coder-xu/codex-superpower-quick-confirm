$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$appPath = Join-Path $repoRoot 'app\CodexQuickConfirm.ps1'
$startPath = Join-Path $repoRoot 'scripts\start.ps1'
$readmePath = Join-Path $repoRoot 'README.md'
$zhReadmePath = Join-Path $repoRoot 'docs\README.zh-CN.md'
$licensePath = Join-Path $repoRoot 'LICENSE'
$changelogPath = Join-Path $repoRoot 'CHANGELOG.md'

$requiredFiles = @(
    $readmePath,
    $zhReadmePath,
    $licensePath,
    $changelogPath,
    $appPath,
    $startPath,
    $PSCommandPath
)

foreach ($path in $requiredFiles) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Required file missing: $path"
    }
}

foreach ($scriptPath in @($appPath, $startPath, $PSCommandPath)) {
    $tokens = $null
    $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($scriptPath, [ref]$tokens, [ref]$errors) | Out-Null

    if ($errors.Count -gt 0) {
        $messages = ($errors | ForEach-Object { $_.Message }) -join '; '
        throw "Parse errors in $scriptPath`: $messages"
    }
}

$expectedPhrases = @(
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

$appText = Get-Content -LiteralPath $appPath -Raw -Encoding UTF8
$readmeText = Get-Content -LiteralPath $readmePath -Raw -Encoding UTF8
$zhReadmeText = Get-Content -LiteralPath $zhReadmePath -Raw -Encoding UTF8
$phraseBlock = [regex]::Match(
    $appText,
    '(?s)# QUICK_CONFIRM_PHRASES_BEGIN\s*\$script:Phrases\s*=\s*@\((.*?)\)\s*# QUICK_CONFIRM_PHRASES_END'
)

if (-not $phraseBlock.Success) {
    throw 'Phrase block not found.'
}

$actualPhrases = [regex]::Matches($phraseBlock.Groups[1].Value, "'([^']*)'") |
    ForEach-Object { $_.Groups[1].Value }

if ($actualPhrases.Count -ne $expectedPhrases.Count) {
    throw "Phrase count mismatch. Expected $($expectedPhrases.Count), got $($actualPhrases.Count)."
}

for ($index = 0; $index -lt $expectedPhrases.Count; $index++) {
    if ($actualPhrases[$index] -ne $expectedPhrases[$index]) {
        throw "Phrase mismatch at index $index. Expected '$($expectedPhrases[$index])', got '$($actualPhrases[$index])'."
    }
}

$expectedControls = @(
    '最小化',
    '取消置顶',
    '恢复置顶'
)

foreach ($controlText in $expectedControls) {
    if (-not $appText.Contains("'$controlText'")) {
        throw "Expected UI control text missing from app script: $controlText"
    }
}

foreach ($readmeTextSnippet in @('Codex Desktop', 'Superpowers', 'English</a> | <a href="./docs/README.zh-CN.md">简体中文', 'Star History', '0.0.1')) {
    if (-not $readmeText.Contains($readmeTextSnippet)) {
        throw "Expected README content missing: $readmeTextSnippet"
    }
}

foreach ($zhReadmeTextSnippet in @('English</a> | <a href="./README.zh-CN.md">简体中文', 'Codex 桌面应用', 'Superpowers 工作流', '最小化', '取消置顶')) {
    if (-not $zhReadmeText.Contains($zhReadmeTextSnippet)) {
        throw "Expected Chinese README content missing: $zhReadmeTextSnippet"
    }
}

if (-not $appText.Contains('$form.WindowState = [System.Windows.Forms.FormWindowState]::Minimized')) {
    throw 'Minimize behavior missing from app script.'
}

if (-not $appText.Contains('$form.TopMost = $enabled')) {
    throw 'TopMost toggle behavior missing from app script.'
}

foreach ($captionSnippet in @(
    '$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None',
    '$captionBar',
    '$closeButton',
    'ReleaseCapture',
    'WM_NCLBUTTONDOWN'
)) {
    if (-not $appText.Contains($captionSnippet)) {
        throw "Expected custom title-bar implementation missing: $captionSnippet"
    }
}

if ($appText.Contains('$toolbar = New-Object System.Windows.Forms.TableLayoutPanel')) {
    throw 'Content toolbar should not be used for window controls.'
}

$forbidden = ('every' + '-' + 'tingle')
Get-ChildItem -LiteralPath $repoRoot -Recurse -File -Force |
    Where-Object { $_.FullName -notmatch '\\.git(\\|$)' } |
    ForEach-Object {
        $content = Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
        if ($content -and $content.ToLowerInvariant().Contains($forbidden)) {
            throw "Forbidden source workspace reference found in $($_.FullName)"
        }
    }

Write-Host 'Smoke checks passed.'




