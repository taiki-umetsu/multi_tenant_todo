class AddRlsPoliciesToUsers < ActiveRecord::Migration[8.0]
  def up
    # RLSを有効化（FORCE付き）
    execute "ALTER TABLE users ENABLE ROW LEVEL SECURITY"
    execute "ALTER TABLE users FORCE ROW LEVEL SECURITY"

    # 同一テナントのみ許可（CRUD）
    execute <<~SQL
      CREATE POLICY users_tenant_isolation ON users
        FOR ALL
        USING (tenant_id = current_setting('app.current_tenant', true)::uuid)
        WITH CHECK (tenant_id = current_setting('app.current_tenant', true)::uuid);
    SQL

    # ログイン前：メール一致だけ SELECT 許可（未設定ならNULL→false）
    execute <<~SQL
      CREATE POLICY users_login_by_email ON users
        FOR SELECT
        USING (email = current_setting('app.login_email', true));
    SQL
  end

  def down
    execute "DROP POLICY IF EXISTS users_login_by_email ON users"
    execute "DROP POLICY IF EXISTS users_tenant_isolation ON users"
    execute "ALTER TABLE users NO FORCE ROW LEVEL SECURITY"
    execute "ALTER TABLE users DISABLE ROW LEVEL SECURITY"
  end
end
