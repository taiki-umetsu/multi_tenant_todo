# CLAUDE.md
## 開発コマンド

### データベース操作
```bash
# PostgreSQL開発データベースに接続
docker exec -it postgres-17 psql -U multi_tenant_app -d multi_tenant_todo_development
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

#### Defense in Depth（多層防御）
RLSとアプリケーション層の両方でテナント分離を実装：

```ruby
# 推奨パターン: RLS + 明示的なwhere句
@users = User.where(tenant_id: current_tenant.id).order(:created_at)
```

**理由：**
1. **二重の安全策**: RLSが無効になった場合の保険
2. **明示的な意図**: コードでテナント分離の意図が明確
3. **パフォーマンス**: インデックスを活用した効率的なクエリ
4. **デバッグしやすさ**: SQLログで実際のクエリが確認可能

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
- テスト環境でRLSポリシーを保持するには`config.active_record.schema_format = :sql`が必須
  Rails の schema.rb は RLS の有効化やポリシーをダンプしません。
  そのため test DB を db:schema:load で用意していると、RLS が存在しない状態になります。

### ViewComponent開発
- 新しいコンポーネントには必ずプレビューとテストを作成
- モバイル対応が必要な場合はバリアント機能を使用
- `test/components/previews/`でプレビューを確認可能

### セキュリティ
- 認証・認可の実装では必ずRLSポリシーを考慮

### JavaScriptを含むシステムテスト（`js: true`）をデバッグ
ヘッドレスモードを無効にして実際のブラウザで動作を確認：

```ruby
before do
  driven_by(:selenium)  # ヘッドレスではなく実際のブラウザを使用
end
```

通常のテストでは`driven_by(:selenium_headless)`を使用してパフォーマンスを向上させる。
また、デバック時は単体のテストケースを指定して実行すると良い。
```bash
bundle exec rspec spec/system/admin/user_invitations_spec.rb:36
```

### Turbo Streams開発
- Turbo Streamsで動的に更新される要素は、ページリロード時にキャッシュの影響で古い状態が表示される場合がある
- 解決方法：更新対象の要素に`data-turbo-temporary`属性を追加してキャッシュから除外する

```erb
<div id="dynamic_content" data-turbo-temporary>
  <!-- Turbo Streamsで更新される内容 -->
</div>
```

### コミット前の必須チェック
コミット前には必ず以下のコマンドを実行してエラーがないことを確認する：

```bash
make precommit
```

このコマンドはRuboCop自動修正、Brakeman、テストを一括実行する。

```bash
# SimpleCovによるコードカバレッジレポート
# テスト実行後、coverage/index.htmlでレポートを確認
```

問題がないことを確認してからコミットすること。

