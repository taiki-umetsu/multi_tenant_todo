module RlsHelpers
  def table_has_rls?(table_name)
    sql = <<~SQL
      SELECT rowsecurity
      FROM pg_tables
      WHERE schemaname = 'public' AND tablename = $1
    SQL

    result = ActiveRecord::Base.connection.exec_query(sql, 'table_has_rls', [ table_name ])
    value = result.first&.fetch('rowsecurity')
    value == 't' || value == true
  end

  def table_has_force_rls?(table_name)
    sql = <<~SQL
      SELECT c.relname, c.relforcerowsecurity
      FROM pg_class c
      JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE n.nspname = 'public' AND c.relname = $1
    SQL

    result = ActiveRecord::Base.connection.exec_query(sql, 'table_has_force_rls', [ table_name ])
    value = result.first&.fetch('relforcerowsecurity')
    value == 't' || value == true
  end

  def table_policies(table_name)
    sql = <<~SQL
      SELECT policyname, cmd, qual, with_check
      FROM pg_policies
      WHERE schemaname = 'public' AND tablename = '#{table_name}'
      ORDER BY policyname
    SQL

    ActiveRecord::Base.connection.execute(sql).to_a
  end

  def policy_exists?(table_name, policy_name)
    table_policies(table_name).any? { |policy| policy['policyname'] == policy_name }
  end
end

RSpec.configure do |config|
  config.include RlsHelpers
end
