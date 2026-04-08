# Auto-Retry Guard: checks and re-injects auto-retry scripts if missing
# Runs silently at logon via scheduled task

$AG_BASE = Join-Path $env:LOCALAPPDATA "Programs\Antigravity\resources\app"
$AG_WB_DIR = Join-Path $AG_BASE "out\vs\code\electron-browser\workbench"
$AG_PANEL_DIR = Join-Path $AG_BASE "extensions\antigravity"
$SRC_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

$WB_HTML = Join-Path $AG_WB_DIR "workbench.html"
$PANEL_HTML = Join-Path $AG_PANEL_DIR "cascade-panel.html"
$SRC_WB = Join-Path $SRC_DIR "auto-retry.js"
$SRC_PANEL = Join-Path $SRC_DIR "auto-retry-panel.js"

$logFile = Join-Path $SRC_DIR "auto-retry-guard.log"

function Log($msg) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts  $msg" | Out-File -Append -FilePath $logFile -Encoding utf8
}

if ((-not (Test-Path $SRC_WB)) -or (-not (Test-Path $SRC_PANEL))) { exit 0 }
if (-not (Test-Path $AG_WB_DIR)) { exit 0 }

$changed = $false

# Check workbench
if (Test-Path $WB_HTML) {
    $content = [System.IO.File]::ReadAllText($WB_HTML)
    if ($content.IndexOf("auto-retry.js") -eq -1) {
        Copy-Item $SRC_WB (Join-Path $AG_WB_DIR "auto-retry.js") -Force
        $tag = '  <script src="auto-retry.js"></script>'
        $content = $content.Replace("</body>", "$tag`n</body>")
        [System.IO.File]::WriteAllText($WB_HTML, $content)
        Log "Re-injected auto-retry.js into workbench.html"
        $changed = $true
    }
}

# Check panel
if (Test-Path $PANEL_HTML) {
    $content = [System.IO.File]::ReadAllText($PANEL_HTML)
    if ($content.IndexOf("auto-retry-panel.js") -eq -1) {
        Copy-Item $SRC_PANEL (Join-Path $AG_PANEL_DIR "auto-retry-panel.js") -Force
        $tag = '  <script src="auto-retry-panel.js"></script>'
        $content = $content.Replace("</body>", "$tag`n</body>")
        [System.IO.File]::WriteAllText($PANEL_HTML, $content)
        Log "Re-injected auto-retry-panel.js into cascade-panel.html"
        $changed = $true
    }
}

# Also ensure JS files exist even if tags are present
if (Test-Path $WB_HTML) {
    $dest = Join-Path $AG_WB_DIR "auto-retry.js"
    if (-not (Test-Path $dest)) {
        Copy-Item $SRC_WB $dest -Force
        Log "Restored missing auto-retry.js file"
        $changed = $true
    }
}
if (Test-Path $PANEL_HTML) {
    $dest = Join-Path $AG_PANEL_DIR "auto-retry-panel.js"
    if (-not (Test-Path $dest)) {
        Copy-Item $SRC_PANEL $dest -Force
        Log "Restored missing auto-retry-panel.js file"
        $changed = $true
    }
}

if (-not $changed) {
    Log "Check OK - no re-injection needed"
}
