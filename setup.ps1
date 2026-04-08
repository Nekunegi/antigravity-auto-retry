# Antigravity 自動リトライ: ワンクリックセットアップ
# 使い方: git clone → このファイルを右クリック →「PowerShell で実行」

$ErrorActionPreference = "Stop"
$SRC_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

# --- ステップ1: Antigravity にスクリプトを注入 ---
$AG_BASE = Join-Path $env:LOCALAPPDATA "Programs\Antigravity\resources\app"
$AG_WB_DIR = Join-Path $AG_BASE "out\vs\code\electron-browser\workbench"
$AG_PANEL_DIR = Join-Path $AG_BASE "extensions\antigravity"

$SRC_WB = Join-Path $SRC_DIR "auto-retry.js"
$SRC_PANEL = Join-Path $SRC_DIR "auto-retry-panel.js"

if ((-not (Test-Path $SRC_WB)) -or (-not (Test-Path $SRC_PANEL))) {
    Write-Host "エラー: auto-retry.js / auto-retry-panel.js が見つかりません" -ForegroundColor Red
    pause; exit 1
}
if (-not (Test-Path $AG_WB_DIR)) {
    Write-Host "エラー: Antigravity が見つかりません: $AG_BASE" -ForegroundColor Red
    pause; exit 1
}

# オリジナルをバックアップ（初回のみ）
$WB_HTML = Join-Path $AG_WB_DIR "workbench.html"
$PANEL_HTML = Join-Path $AG_PANEL_DIR "cascade-panel.html"

if ((Test-Path $WB_HTML) -and (-not (Test-Path "$WB_HTML.bak"))) {
    Copy-Item $WB_HTML "$WB_HTML.bak"
}
if ((Test-Path $PANEL_HTML) -and (-not (Test-Path "$PANEL_HTML.bak"))) {
    Copy-Item $PANEL_HTML "$PANEL_HTML.bak"
}

# JSファイルをコピー
Copy-Item $SRC_WB (Join-Path $AG_WB_DIR "auto-retry.js") -Force
Copy-Item $SRC_PANEL (Join-Path $AG_PANEL_DIR "auto-retry-panel.js") -Force

# scriptタグを注入
$closingBody = '</body>'

if (Test-Path $WB_HTML) {
    $content = [System.IO.File]::ReadAllText($WB_HTML)
    if ($content.IndexOf("auto-retry.js") -eq -1) {
        $tag = '  <script src="auto-retry.js"></script>'
        $content = $content.Replace($closingBody, "$tag`n$closingBody")
        [System.IO.File]::WriteAllText($WB_HTML, $content)
    }
}
if (Test-Path $PANEL_HTML) {
    $content = [System.IO.File]::ReadAllText($PANEL_HTML)
    if ($content.IndexOf("auto-retry-panel.js") -eq -1) {
        $tag = '  <script src="auto-retry-panel.js"></script>'
        $content = $content.Replace($closingBody, "$tag`n$closingBody")
        [System.IO.File]::WriteAllText($PANEL_HTML, $content)
    }
}

Write-Host "[1/2] スクリプト注入完了" -ForegroundColor Green

# --- ステップ2: アプリ更新後の自動復旧用スケジュールタスクを登録 ---
$guardScript = Join-Path $SRC_DIR "auto-retry-guard.ps1"
if (Test-Path $guardScript) {
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$guardScript`""
    $trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    Register-ScheduledTask -TaskName "AntigravityAutoRetryGuard" -Action $action -Trigger $trigger -Settings $settings -Description "Antigravity更新後に自動リトライスクリプトを再注入する" -Force | Out-Null
    Write-Host "[2/2] スケジュールタスク登録完了" -ForegroundColor Green
} else {
    Write-Host "[2/2] スキップ: auto-retry-guard.ps1 が見つかりません" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host " セットアップ完了!" -ForegroundColor Cyan
Write-Host " Antigravity を再起動してください。" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
pause
