# Express App Standalone Installer Project

このプロジェクトは、**インターネット接続のない（オフライン）Windows Server** に、Node.js アプリケーションを Windows サービスとして一括セットアップするためのインストーラー作成キットです。

## 概要

* **Node.js**: v24.2.0 LTS (手動インストールの必要なし)
* **Service Manager**: NSSM (Non-Sucking Service Manager)
* **Installer**: Inno Setup
* **Framework**: Express

---

## フォルダ構成

```text
.
├── src/
│   ├── nodejs/       # Node.js バイナリ (setup_assets.ps1 で取得)
│   ├── app/          # Express アプリケーション本体
│   │   ├── main.js
│   │   ├── package.json
│   │   └── node_modules/
│   └── tools/        # nssm.exe (setup_assets.ps1 で取得)
├── dist/             # 生成されたインストーラー (.exe) の出力先
├── mysetup.iss       # Inno Setup 設定ファイル
├── setup_assets.ps1  # 必要なバイナリの自動取得スクリプト
└── README.md         # このファイル

```

---

## セットアップ手順（開発用PC / インターネットあり）

### 1. 依存バイナリの取得

PowerShell を管理者権限で開き、以下のスクリプトを実行して Node.js と NSSM を準備します。

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.\setup_assets.ps1

```

※ `nssm.cc` がダウンしている場合、スクリプト内の指示に従って手動で `src/tools/nssm.exe` を配置してください。

### 2. アプリケーションの準備

`src/app/` ディレクトリに必要なソースコードを配置し、依存関係をインストールします。

```bash
cd src/app
npm install --production

```

### 3. インストーラーの作成

1. **Inno Setup** を起動します。
2. `mysetup.iss` を読み込みます。
3. `Build` > `Compile` (Ctrl+F9) を実行します。
4. `dist/ExpressApp_Setup.exe` が生成されます。

---

## インストール手順（本番サーバー / オフライン）

1. 生成された `ExpressApp_Setup.exe` を対象サーバーに持ち込みます。
2. **管理者権限**で実行します。
3. インストール完了後、以下の処理が自動で行われます：
* `C:\Program Files\ExpressApp` へのファイルコピー
* Windows サービス `ExpressService` の登録と開始
* Windows ファイアウォールのポート開放（デフォルト: 3000）



---

## 運用・メンテナンス

### ログの確認

アプリケーションの標準出力およびエラーログは、以下のパスに出力されます。

* `C:\Program Files\ExpressApp\app\out.log`
* `C:\Program Files\ExpressApp\app\error.log`

### サービスの管理

Windows の「サービス」管理画面（`services.msc`）から、`ExpressService` という名前で開始・停止・再起動が可能です。

### アンインストール

「設定」>「アプリと機能」からアンインストールしてください。サービスおよびファイアウォールの規則も自動的に削除されます。

---

## トラブルシューティング

* **サービスが起動しない**:
* `error.log` を確認してください。
* サーバーに `Visual C++ 再頒布可能パッケージ` がインストールされているか確認してください。


* **ポート競合**:
* `netstat -ano | findstr :3000` で、他のプロセスがポートを使用していないか確認してください。


