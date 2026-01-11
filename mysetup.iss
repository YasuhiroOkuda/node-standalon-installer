[Setup]
AppName=ExpressApp-Server
AppVersion=1.0
DefaultDirName={commonpf}\ExpressApp
DefaultGroupName=ExpressApp
PrivilegesRequired=admin

; 出力先を dist フォルダに設定
OutputDir=dist
OutputBaseFilename=ExpressApp_Setup

[Files]
; src フォルダから必要な資材をすべてコピー
Source: "src\nodejs\*"; DestDir: "{app}\nodejs"; Flags: recursesubdirs
Source: "src\app\*"; DestDir: "{app}\app"; Flags: recursesubdirs
Source: "src\tools\nssm.exe"; DestDir: "{app}\tools"

[Run]
; 1. サービスを登録
Filename: "{app}\tools\nssm.exe"; Parameters: "install ExpressService ""{app}\nodejs\node.exe"""; Flags: runhidden

; 2. 引数（main.js）を設定 (パスを "" で囲む)
Filename: "{app}\tools\nssm.exe"; Parameters: "set ExpressService AppParameters ""{app}\app\main.js"""; Flags: runhidden

; 3. 作業ディレクトリを設定
Filename: "{app}\tools\nssm.exe"; Parameters: "set ExpressService AppDirectory ""{app}\app"""; Flags: runhidden

; 4. ログ出力設定
Filename: "{app}\tools\nssm.exe"; Parameters: "set ExpressService AppStdout ""{app}\app\out.log"""; Flags: runhidden
Filename: "{app}\tools\nssm.exe"; Parameters: "set ExpressService AppStderr ""{app}\app\error.log"""; Flags: runhidden

; 5. ファイアウォール開放
Filename: "netsh"; Parameters: "advfirewall firewall add rule name=""ExpressApp"" dir=in action=allow protocol=TCP localport=3000"; Flags: runhidden

; 6. サービスの開始
Filename: "{app}\tools\nssm.exe"; Parameters: "start ExpressService"; Flags: runhidden

[UninstallRun]
; アンインストール時にサービスとファイアウォール設定をクリーンアップ
Filename: "{app}\tools\nssm.exe"; Parameters: "stop ExpressService"; Flags: runhidden
Filename: "{app}\tools\nssm.exe"; Parameters: "remove ExpressService confirm"; Flags: runhidden
Filename: "netsh"; Parameters: "advfirewall firewall delete rule name=""ExpressApp"""; Flags: runhidden