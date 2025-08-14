require 'rails_helper'

RSpec.describe "RLS Coverage", type: :feature do
  EXCLUDED_TABLES = %w[
    ar_internal_metadata
    schema_migrations
  ].freeze

  def all_application_tables
    sql = <<~SQL
      SELECT tablename
      FROM pg_tables
      WHERE schemaname = 'public'
      ORDER BY tablename
    SQL

    result = ActiveRecord::Base.connection.execute(sql)
    result.map { |row| row['tablename'] } - EXCLUDED_TABLES
  end

  describe "All application tables" do
    it "have RLS enabled" do
      all_application_tables.each do |table_name|
        expect(table_has_rls?(table_name)).to be(true),
          "Table '#{table_name}' does not have RLS enabled"
        expect(table_has_force_rls?(table_name)).to be(true),
          "Table '#{table_name}' does not have FORCE RLS enabled"
      end
    end

    it "have at least one RLS policy" do
      all_application_tables.each do |table_name|
        policies = table_policies(table_name)
        expect(policies).not_to be_empty,
          "Table '#{table_name}' has no RLS policies defined"
      end
    end

    it "shows current RLS status for all tables" do
      puts "\n=== RLS Coverage Report ==="

      all_application_tables.each do |table_name|
        rls_enabled = table_has_rls?(table_name)
        force_rls = table_has_force_rls?(table_name)
        policy_count = table_policies(table_name).size

        status = rls_enabled && force_rls ? "✓" : "✗"
        puts "#{status} #{table_name.ljust(30)} RLS: #{rls_enabled}, FORCE: #{force_rls}, Policies: #{policy_count}"
      end

      puts "=========================="
    end
  end
end
