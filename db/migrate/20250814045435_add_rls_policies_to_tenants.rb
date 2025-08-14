class AddRlsPoliciesToTenants < ActiveRecord::Migration[8.0]
  def up
    execute "ALTER TABLE tenants ENABLE ROW LEVEL SECURITY"

    # FORCEで所有者も行レベルセキュリティを有効にする
    execute "ALTER TABLE tenants FORCE ROW LEVEL SECURITY"

    # サインアップ時だけ INSERT を許可
    execute <<~SQL
      CREATE POLICY tenants_insert_signup ON tenants
        FOR INSERT
        WITH CHECK (current_setting('app.signup_phase', true) = '1');
      CREATE POLICY tenants_select_signup ON tenants
        FOR SELECT
        USING (current_setting('app.signup_phase', true) = '1');
    SQL

    execute <<~SQL
      CREATE POLICY tenants_isolation_all ON tenants
        FOR ALL
        USING (id = current_setting('app.current_tenant', true)::uuid)
        WITH CHECK (id = current_setting('app.current_tenant', true)::uuid);
    SQL
  end

  def down
    execute "DROP POLICY IF EXISTS tenants_insert_signup ON tenants"
    execute "DROP POLICY IF EXISTS tenants_select_signup ON tenants"
    execute "DROP POLICY IF EXISTS tenants_isolation_all ON tenants"
    execute "ALTER TABLE tenants NO FORCE ROW LEVEL SECURITY"
    execute "ALTER TABLE tenants DISABLE ROW LEVEL SECURITY"
  end
end
