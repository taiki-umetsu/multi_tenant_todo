class AddRlsPoliciesToUserInvitations < ActiveRecord::Migration[8.0]
  def up
    # RLSを有効化（FORCE付き）
    execute "ALTER TABLE user_invitations ENABLE ROW LEVEL SECURITY"
    execute "ALTER TABLE user_invitations FORCE ROW LEVEL SECURITY"

    # 同一テナントのみ許可（CRUD）
    execute <<~SQL
      CREATE POLICY user_invitations_tenant_isolation ON user_invitations
        FOR ALL
        USING (tenant_id = (nullif(current_setting('app.current_tenant', true), ''))::uuid)
        WITH CHECK (tenant_id = (nullif(current_setting('app.current_tenant', true), ''))::uuid);
    SQL

    # 招待受諾：tokenアクセス許可（テナント設定なしでもSELECT可能）
    execute <<~SQL
      CREATE POLICY user_invitations_token_access ON user_invitations
        FOR SELECT
        USING (token = current_setting('app.invitation_token', true));
    SQL
  end

  def down
    execute "DROP POLICY IF EXISTS user_invitations_token_access ON user_invitations"
    execute "DROP POLICY IF EXISTS user_invitations_tenant_isolation ON user_invitations"
    execute "ALTER TABLE user_invitations NO FORCE ROW LEVEL SECURITY"
    execute "ALTER TABLE user_invitations DISABLE ROW LEVEL SECURITY"
  end
end
