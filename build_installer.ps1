# --- 設定 ---
$issFile = "mysetup.iss"
$isccPath = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" # デフォルトのパス

# --- ISCC.exe の存在確認 ---
if (-not (Test-Path $isccPath)) {
    # パスが見つからない場合、環境変数や他の場所を探す
    $isccPath = Get-Command iscc.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
    if (-not $isccPath) {
        Write-Error "Inno Setup (ISCC.exe) が見つかりません。インストールされているか確認してください。"
        Write-Host "DL先: https://jrsoftware.org/isdl.php" -ForegroundColor Cyan
        exit
    }
}

Write-Host ">>> インストーラーのビルドを開始します..." -ForegroundColor Cyan

# --- コンパイル実行 ---
& $isccPath $issFile

# --- 結果確認 ---
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n>>> [成功] インストーラーが dist フォルダに生成されました！" -ForegroundColor Green
    Get-ChildItem -Path ".\dist" | Select-Object Name, Length, LastWriteTime
} else {
    Write-Host "`n>>> [失敗] ビルド中にエラーが発生しました。" -ForegroundColor Red
}