# --- 設定 ---
# 2026年1月時点の最新LTS (Node.js 24.x) を指定
$NODE_VERSION = "24.2.0" 
$NODE_ZIP_URL = "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-win-x64.zip"
$NSSM_ZIP_URL = "https://nssm.cc/release/nssm-2.24.zip"

# --- フォルダ作成 ---
$baseDir = Get-Location
$srcDir = New-Item -ItemType Directory -Force -Path "$baseDir\src"
$distDir = New-Item -ItemType Directory -Force -Path "$baseDir\dist"
$nodeDest = New-Item -ItemType Directory -Force -Path "$srcDir\nodejs"
$toolsDest = New-Item -ItemType Directory -Force -Path "$srcDir\tools"
$tempDir = New-Item -ItemType Directory -Force -Path "$baseDir\temp"

Write-Host ">>> Node.js 24 LTS (Active) のセットアップを開始します..." -ForegroundColor Cyan

# --- Node.js のダウンロードと展開 ---
Write-Host "Node.js $NODE_VERSION をダウンロード中..."
Invoke-WebRequest -Uri $NODE_ZIP_URL -OutFile "$tempDir\node.zip"
Write-Host "Node.js を展開中..."
Expand-Archive -Path "$tempDir\node.zip" -DestinationPath "$tempDir\node_out" -Force
$extractedNodeDir = Get-ChildItem -Path "$tempDir\node_out" | Select-Object -First 1
Copy-Item -Path "$($extractedNodeDir.FullName)\*" -Destination $nodeDest -Recurse -Force

# --- NSSM のダウンロードと展開 ---
Write-Host "NSSM をダウンロード中..."
Invoke-WebRequest -Uri $NSSM_ZIP_URL -OutFile "$tempDir\nssm.zip"
Write-Host "NSSM を展開中..."
Expand-Archive -Path "$tempDir\nssm.zip" -DestinationPath "$tempDir\nssm_out" -Force
Copy-Item -Path "$tempDir\nssm_out\nssm-*\win64\nssm.exe" -Destination $toolsDest -Force

# --- アプリの依存関係インストール ---
if (Test-Path "$baseDir\src\app\package.json") {
    Write-Host "依存関係 (npm install) を実行中..."
    Set-Location "$baseDir\src\app"
    # クリーンなインストールを確実にするため、既存のnode_modulesがあれば削除推奨
    if (Test-Path "node_modules") { Remove-Item -Path "node_modules" -Recurse -Force }
    npm install --production
    Set-Location $baseDir
}

# --- 後片付け ---
Remove-Item -Path $tempDir -Recurse -Force
Write-Host ">>> すべての準備が完了しました！" -ForegroundColor Green
Write-Host "現在の構成: Node.js $NODE_VERSION + NSSM 2.24"