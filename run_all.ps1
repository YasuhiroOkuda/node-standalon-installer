Write-Host "==== フルビルドプロセス開始 ====" -ForegroundColor Magenta

# 1. アセット（Node.js, NSSM, npm install）の準備
.\setup_assets.ps1

if ($LASTEXITCODE -ne 0) {
    Write-Error "アセットの準備に失敗したため、ビルドを中止します。"
    exit
}

# 2. インストーラーのコンパイル
.\build_installer.ps1

Write-Host "==== すべての工程が完了しました ====" -ForegroundColor Magenta