# Test HTTP Server Container

80番ポートでHTTPリクエストを待ち受ける、テスト用のシンプルなコンテナです。

コンテナ起動時にPythonのHTTPサーバーを起動し、アクセスするとコンテナのホスト名を返します。

## 構成

```text
.
├── Dockerfile
├── buildspec.yml
└── README.md
```

### Dockerfile

Alpine Linuxをベースイメージとして使用し、Python 3を使ってHTTPサーバーを起動します。

* ベースイメージ: `alpine:3.15`
* HTTP待ち受けポート: `80`
* レスポンス: `Hello from <hostname>!`

### buildspec.yml

AWS CodeBuildでDockerイメージをビルドし、Amazon ECRへプッシュするためのBuildspecです。

イメージタグには、CodeBuildで取得したGitコミットIDの先頭7文字を使用します。

また、同じイメージを `latest` タグでもプッシュします。

## ローカルでの起動方法

### Dockerイメージをビルド

```bash
docker build -t test-http-server .
```

### コンテナを起動

コンテナの80番ポートをホストの80番ポートにマッピングして起動します。

```bash
docker run --rm -p 80:80 test-http-server
```

以下のようなログが表示されれば起動成功です。

```text
Server running on port 80!!
```

### 動作確認

別のターミナルから以下を実行します。

```bash
curl http://localhost/
```

以下のようなレスポンスが返ります。

```text
Hello from <container-hostname>!
```

`<container-hostname>` の部分は、実行しているコンテナのホスト名になります。

## 任意のホストポートで起動する

ホスト側の80番ポートが使用中の場合は、別のポートにマッピングできます。

例えばホストの8080番ポートからアクセスする場合は以下のように起動します。

```bash
docker run --rm -p 8080:80 test-http-server
```

動作確認:

```bash
curl http://localhost:8080/
```

## Amazon ECRへのプッシュ

`buildspec.yml` はAWS CodeBuildでの利用を想定しています。

CodeBuild実行時には、以下の環境変数を使用します。

| 環境変数                                | 用途                                 |
| ----------------------------------- | ---------------------------------- |
| `AWS_DEFAULT_REGION`                | ECRのAWSリージョン                       |
| `AWS_ACCOUNT_ID`                    | AWSアカウントID                         |
| `ECR_REPOSITORY_URI`                | ECRリポジトリURI                        |
| `CONTAINER_NAME`                    | `imagedefinitions.json` に設定するコンテナ名 |
| `CODEBUILD_RESOLVED_SOURCE_VERSION` | ビルド対象のGitコミットID                    |

CodeBuildでは、以下の処理を実行します。

1. Amazon ECRへログイン
2. GitコミットIDの先頭7文字をイメージタグとして取得
3. Dockerイメージをビルド
4. `<commit-id>` タグでECRへプッシュ
5. `latest` タグでECRへプッシュ
6. ECS等で利用するための `imagedefinitions.json` を生成
7. `imagedefinitions.json` をCodeBuildのアーティファクトとして出力

例えばコミットIDが `1234567890abcdef...` の場合、以下のタグが作成されます。

```text
<ECR_REPOSITORY_URI>:1234567
<ECR_REPOSITORY_URI>:latest
```

## 注意事項

このコンテナはテスト用途を想定した非常にシンプルなHTTPサーバーです。

本番環境で利用することを目的としたものではありません。
