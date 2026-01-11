[Setup]
AppName=ExpressApp
AppVersion=1.0
; 64bit OSに正しくインストールするための設定
ArchitecturesInstallIn64BitMode=x64
DefaultDirName={commonpf}\ExpressApp
DefaultGroupName=ExpressApp
PrivilegesRequired=admin
OutputDir=dist
OutputBaseFilename=ExpressApp_Setup

[Files]
Source: "src\nodejs\*"; DestDir: "{app}\nodejs"; Flags: recursesubdirs
Source: "src\app\*"; DestDir: "{app}\app"; Flags: recursesubdirs
Source: "src\tools\nssm.exe"; DestDir: "{app}\tools"

[Run]
; --- サービスの登録 ---
; 1. node.exe のパスのみを指定してインストール
Filename: "{app}\tools\nssm.exe"; Parameters: "install ExpressService ""{app}\nodejs\node.exe"""; Flags: runhidden

; 2. 作業ディレクトリをアプリフォルダ (C:\Program Files (x86)\ExpressApp\app) に固定
; これにより、Node.js はこのフォルダの中で起動します
Filename: "{app}\tools\nssm.exe"; Parameters: "set ExpressService AppDirectory ""{app}\app"""; Flags: runhidden

; 3. 【最重要】実行引数を「ファイル名のみ」にする
; フルパスを指定しないため、スペースやカッコによるエラーが絶対に起きません
Filename: "{app}\tools\nssm.exe"; Parameters: "set ExpressService AppParameters main.js"; Flags: runhidden

; 4. ログ出力設定
Filename: "{app}\tools\nssm.exe"; Parameters: "set ExpressService AppStdout ""{app}\app\out.log"""; Flags: runhidden
Filename: "{app}\tools\nssm.exe"; Parameters: "set ExpressService AppStderr ""{app}\app\error.log"""; Flags: runhidden

; 5. サービスの開始
Filename: "{app}\tools\nssm.exe"; Parameters: "start ExpressService"; Flags: runhidden

[UninstallRun]
; 1. サービスの停止
Filename: "{app}\tools\nssm.exe"; Parameters: "stop ExpressService"; Flags: runhidden

; 2. サービスの削除 (confirm を付けることで確認ダイアログを出さずに削除)
Filename: "{app}\tools\nssm.exe"; Parameters: "remove ExpressService confirm"; Flags: runhidden

; 3. Windows Firewall の規則を削除
Filename: "netsh"; Parameters: "advfirewall firewall delete rule name=""ExpressApp"""; Flags: runhidden