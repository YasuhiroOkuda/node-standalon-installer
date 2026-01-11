const express = require('express');
const path = require('path');
const app = express();

// ポート番号の設定（環境変数から取得、または3000を使用）
const PORT = process.env.PORT || 3000;

// 1. ミドルウェアの設定
app.use(express.json());

// 2. 静的ファイルの配信設定（必要に応じて）
// インストール先フォルダ内の 'public' ディレクトリを参照する場合
app.use(express.static(path.join(__dirname, 'public')));

// 3. ルートハンドラー
app.get('/', (req, res) => {
    res.json({
        status: 'OK',
        message: 'Express server is running as a Windows Service.',
        timestamp: new Date().toISOString()
    });
});

// 4. ヘルスチェック用エンドポイント
app.get('/health', (req, res) => {
    res.status(200).send('Healthy');
});

// 5. サーバーの起動
const server = app.listen(PORT, () => {
    // これらのログは NSSM によって out.log に書き出されます
    console.log('==================================================');
    console.log(`Server started at: ${new Date().toLocaleString()}`);
    console.log(`Application Dir: ${__dirname}`);
    console.log(`Listening on port: ${PORT}`);
    console.log('==================================================');
});

// Windowsサービス停止時のクリーンアップ処理
process.on('SIGTERM', () => {
    console.log('SIGTERM signal received. Closing HTTP server...');
    server.close(() => {
        console.log('HTTP server closed.');
        process.exit(0);
    });
});