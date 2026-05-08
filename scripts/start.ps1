param(
    [switch]$SelfTest
)

$ErrorActionPreference = 'Stop'

$ideaRoot = Split-Path -Parent $PSScriptRoot
$appPath = Join-Path $ideaRoot 'app\CodexQuickConfirm.ps1'

if (-not (Test-Path -LiteralPath $appPath)) {
    throw "App script not found: $appPath"
}

if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne [System.Threading.ApartmentState]::STA) {
    if ($SelfTest) {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File $appPath -SelfTest
    }
    else {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File $appPath
    }

    exit $LASTEXITCODE
}

if ($SelfTest) {
    & $appPath -SelfTest
}
else {
    & $appPath
}
