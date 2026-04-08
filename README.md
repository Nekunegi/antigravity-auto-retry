# antigravity-auto-retry

Antigravity (Windows) のエラー時に表示される **Retry ボタン**を自動でクリックするスクリプト。  
アプリ更新後も自動で再適用されます。

## セットアップ（ワンクリック）

```powershell
git clone https://github.com/<your-username>/antigravity-auto-retry.git
cd antigravity-auto-retry
# setup.ps1 を右クリック →「PowerShell で実行」
```

または：

```powershell
powershell -ExecutionPolicy Bypass -File setup.ps1
```

これだけで：
1. Antigravity に自動リトライスクリプトを注入
2. ログイン時に自動復旧するスケジュールタスクを登録

**セットアップ後、Antigravity を再起動してください。**

## ファイル構成

| ファイル | 役割 |
|---|---|
| `auto-retry.js` | メインUI内のRetryボタンを500ms間隔で検出・自動クリック |
| `auto-retry-panel.js` | AIチャットパネル内のRetryボタンを検出・自動クリック |
| `auto-retry-guard.ps1` | ログイン時に注入が消えてないかチェック＆自動復旧 |
| `setup.ps1` | ワンクリックセットアップ（注入＋タスク登録） |

## アンインストール

```powershell
# スケジュールタスクを削除
Unregister-ScheduledTask -TaskName "AntigravityAutoRetryGuard" -Confirm:$false

# バックアップからHTMLを復元
$base = "$env:LOCALAPPDATA\Programs\Antigravity\resources\app"
Copy-Item "$base\out\vs\code\electron-browser\workbench\workbench.html.bak" "$base\out\vs\code\electron-browser\workbench\workbench.html" -Force
Copy-Item "$base\extensions\antigravity\cascade-panel.html.bak" "$base\extensions\antigravity\cascade-panel.html" -Force
```

## 注意事項

- アプリ内ファイルを変更するため、起動時に「installation has been modified」の警告が出ることがあります
- リトライ失敗もトークンを消費します（無限リトライではなく1.5秒クールダウンあり）

## Credits

Based on [mewmewwow/auto_retry_antigravity](https://github.com/mewmewwow/auto_retry_antigravity) (macOS version)
