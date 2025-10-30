# ベースイメージとして軽量なAlpine Linuxを使用
FROM alpine:3.15

# 必要なパッケージをインストール
RUN apk add --no-cache python3 curl

# 作業ディレクトリを設定
WORKDIR /app

# 簡単なPythonスクリプトを作成
COPY <<EOF /app/server.py
from http.server import HTTPServer, SimpleHTTPRequestHandler
import socket

class MyHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(f"Hello from {socket.gethostname()}!".encode())

httpd = HTTPServer(("0.0.0.0", 80), MyHandler)
print("Server running on port 80!!")
httpd.serve_forever()
EOF

# 80番ポートを公開
EXPOSE 80

# コンテナ起動時にPythonスクリプトを実行
CMD ["python3", "-u", "server.py"]
