class AddRlsPoliciesToTenants < ActiveRecord::Migration[8.0]
  def up
    execute "ALTER TABLE tenants ENABLE ROW LEVEL SECURITY"

    # FORCEで所有者も行レベルセキュリティを有効にする
    execute "ALTER TABLE tenants FORCE ROW LEVEL SECURITY"

    execute <<~SQL
      -- SELECT
      CREATE POLICY tenants_select ON tenants
        FOR SELECT
        USING (
          current_setting('app.signup_phase', true) = '1'
          OR id = (nullif(current_setting('app.current_tenant', true), ''))::uuid
        );

      -- INSERT
      CREATE POLICY tenants_insert ON tenants
        FOR INSERT
        WITH CHECK (current_setting('app.signup_phase', true) = '1');

      -- UPDATE
      CREATE POLICY tenants_update ON tenants
        FOR UPDATE
        USING (id = (nullif(current_setting('app.current_tenant', true), ''))::uuid)
        WITH CHECK (id = (nullif(current_setting('app.current_tenant', true), ''))::uuid);
    SQL
  end

  def down
    execute "DROP POLICY IF EXISTS tenants_select ON tenants"
    execute "DROP POLICY IF EXISTS tenants_insert ON tenants"
    execute "DROP POLICY IF EXISTS tenants_update ON tenants"
    execute "ALTER TABLE tenants NO FORCE ROW LEVEL SECURITY"
    execute "ALTER TABLE tenants DISABLE ROW LEVEL SECURITY"
  end
end
