# antigravity-auto-retry

Antigravity (Windows) のエラー時に表示される **Retry ボタン**を自動でクリックするスクリプト。  
アプリ更新後も自動で再適用されます。

## セットアップ

```powershell
git clone https://github.com/Nekunegi/antigravity-auto-retry.git
cd antigravity-auto-retry
# setup.ps1 を右クリック →「PowerShell で実行」
```

または：

```powershell
powershell -ExecutionPolicy Bypass -File setup.ps1
```

これだけで：
1. Antigravity の HTML に自動リトライスクリプトを注入
2. ログイン時に自動復旧するスケジュールタスクを登録

**セットアップ後、Antigravity を再起動してください。**

## 仕組み

- テキストが完全に `"retry"` と一致するボタンのみをクリック対象とする（部分一致ではないため誤検出しない）
- 500ms 間隔のポーリング + MutationObserver でボタン出現を即検知
- 同一ボタンへの連打を防ぐ 1.5 秒クールダウン付き

## ファイル構成

| ファイル | 役割 |
|---|---|
| `auto-retry.js` | ワークベンチ（メインUI）内の Retry ボタンを検出・自動クリック |
| `auto-retry-panel.js` | AI チャットパネル内の Retry ボタンを検出・自動クリック |
| `auto-retry-guard.ps1` | ログイン時に注入が消えていないかチェック＆自動復旧 |
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
- リトライ失敗もトークンを消費します（無限リトライではなく 1.5 秒クールダウンあり）

## Credits

Based on [mewmewwow/auto_retry_antigravity](https://github.com/mewmewwow/auto_retry_antigravity) (macOS version)

## バージョン

**v1.1.5** - 2026-05-18
