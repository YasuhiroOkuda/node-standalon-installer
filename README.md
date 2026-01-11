# Express App Standalone Installer Project (Windows Server Edition)

このプロジェクトは、オフラインの Windows Server 環境へ Express アプリケーションを「Windows サービス」として一括セットアップするためのパッケージ作成キットです。

## 🌟 特徴

* **ポータブル**: Node.js 本体を同梱するため、サーバー側でのインストール作業が不要。
* **堅牢**: NSSM を採用し、スペースやカッコを含む Windows 特有のパス問題（`C:\Program Files (x86)` 等）を相対パス方式で完全回避。
* **完全自動化**: アセット取得からインストーラービルドまでスクリプトで完結。
* **運用性**: OS 再起動時の自動起動、標準/エラーログのファイル出力、ファイアウォール自動開放に対応。

---

## 📂 フォルダ構成

```text
.
├── dist/                # ビルドされたインストーラー (.exe) の出力先
├── src/
│   ├── nodejs/          # Node.js 24.x LTS バイナリ (自動取得)
│   ├── app/             # Express アプリケーション本体
│   │   ├── main.js      # 起動スクリプト
│   │   ├── package.json
│   │   └── node_modules/# 依存ライブラリ (npm install --production)
│   └── tools/           # NSSM (64bit版) バイナリ
├── mysetup.iss          # Inno Setup コンパイル設定
├── setup_assets.ps1     # Node.js/NSSM の自動ダウンロードスクリプト
├── build_installer.ps1  # インストーラー生成スクリプト
├── run_all.ps1          # 上記2つの工程を一括実行するスクリプト
└── README.md            # このファイル

```

---

## 🛠 構築手順（インターネット環境のある開発PC）

### 1. 依存バイナリとライブラリの準備

PowerShell で以下を実行します。これにより `src/` フォルダに必要な資材がすべて揃います。

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.\setup_assets.ps1

```

※ `src/app/node_modules` も自動的に作成されます。

### 2. インストーラーのビルド

以下のスクリプトを実行して、`dist/` フォルダに `ExpressApp_Setup.exe` を生成します。

```powershell
.\build_installer.ps1

```

※ 事前に **Inno Setup 6** がインストールされている必要があります。

---

## 🚀 設置・運用手順（オフラインサーバー）

### インストール

1. `ExpressApp_Setup.exe` を管理者権限で実行します。
2. デフォルトでは `C:\Program Files\ExpressApp` (64bit) または `C:\Program Files (x86)\ExpressApp` にインストールされます。

### サービス管理

アプリケーションは `ExpressService` という名前の Windows サービスとして登録されます。

* **起動/停止**: `services.msc`（サービス管理画面）から操作可能。
* **自動起動**: OS 起動時にバックグラウンドで自動実行されます。

### ログ確認

不具合時の調査は、以下のファイルを確認してください。

* `.../app/out.log`（標準出力）
* `.../app/error.log`（エラーログ）

---

## 💡 技術的なポイント

* **パス問題の回避**:
NSSM の `AppDirectory` を設定し、`AppParameters` を `main.js`（相対パス）のみにすることで、Windows のパスに含まれるスペースやカッコによる起動失敗を回避しています。
* **64bit モード**:
`ArchitecturesInstallIn64BitMode=x64` を有効にしているため、64bit Server では最適なパスに配置されます。

---

## 🗑 アンインストール

「設定」>「アプリと機能」から削除してください。以下の処理が自動で実行されます。

1. 実行中のサービスを停止。
2. Windows サービス登録を削除。
3. ファイアウォールの開放規則を削除。
4. インストールディレクトリのファイルを削除。
