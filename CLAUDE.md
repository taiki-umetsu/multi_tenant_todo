# CLAUDE.md
## 開発コマンド

### データベース操作
```bash
# PostgreSQL開発データベースに接続
docker exec -it postgres-16 psql -U user -d multi_tenant_todo_development
```

## アーキテクチャ概要

### マルチテナント設計
このアプリケーションはPostgreSQLのRow Level Security (RLS)を使用したマルチテナントアーキテクチャを実装している。

#### RLSベースのテナント分離
- 全てのアプリケーションテーブルでRLSが有効化されている（FORCE RLS含む）
- PostgreSQLの設定変数を使用してテナントコンテキストを管理:
  - `app.current_tenant`: 現在のテナントID
  - `app.signup_phase`: テナント登録フェーズでの特別権限
  - `app.login_email`: ログイン時のメール照合

#### データモデル
- **Tenant**: テナント情報（マルチテナントの基本単位）
- **User**: ユーザー情報（テナントに所属、メールは決定論的暗号化）

#### セキュリティポリシー
- テナント分離: 同一テナント内のデータのみアクセス可能
- テナント登録: 登録フェーズでのみ新規テナント作成可能
- ログイン認証: メール照合によるユーザー検索を限定的に許可

### ViewComponent設計
- 再利用可能なUIコンポーネントをViewComponentで実装
- プレビューとテストを含む完全なコンポーネント開発環境
- モバイル対応のバリアント機能を活用

### フォーム設計
- Form Objectパターンを使用（`app/forms/`）
- バリデーターの分離（`app/validators/`）
- コンポーネント化されたフォーム要素

### テスト設計
- RSpec + FactoryBot + Shoulda Matchersを使用
- RLSポリシーの包括的テスト（`spec/rls/`）
- システムテスト（Capybara + Selenium）
- ViewComponentのプレビューとテスト。基本的にrender_previewでテスト。
- SimpleCovによるカバレッジ測定

## 開発時の注意点

### RLS開発
- 新しいテーブル作成時は必ずRLSポリシーも定義する
- `spec/rls/rls_coverage_spec.rb`でRLS設定の網羅性を確認
- テナント切り替えは`User.with_tenant`メソッドを使用

### ViewComponent開発
- 新しいコンポーネントには必ずプレビューとテストを作成
- モバイル対応が必要な場合はバリアント機能を使用
- `test/components/previews/`でプレビューを確認可能

### セキュリティ
- 認証・認可の実装では必ずRLSポリシーを考慮

### コミット前の必須チェック
コミット前には必ず以下のコマンドを実行してエラーがないことを確認する：

```bash
# コードスタイルチェック
bundle exec rubocop

# セキュリティ脆弱性スキャン
bundle exec brakeman

# SimpleCovによるコードカバレッジレポート
# テスト実行後、coverage/index.htmlでレポートを確認
```
問題がないことを確認してからコミットすること。
