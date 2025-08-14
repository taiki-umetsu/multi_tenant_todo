require 'rails_helper'

RSpec.describe Tenant, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }

    it "validates uniqueness of name" do
      Tenant.create_with_signup(name: "Existing Tenant")
      expect(build(:tenant, name: "Existing Tenant")).not_to be_valid
    end
  end

  describe "RLS (Row Level Security)" do
    describe ".create_with_signup" do
      it "creates a tenant during signup phase" do
        tenant = Tenant.create_with_signup(name: "Test Tenant")
        expect(tenant).to be_persisted
        expect(tenant.name).to eq("Test Tenant")
      end

      it "creates a tenant with UUID as primary key" do
        tenant = Tenant.create_with_signup(name: "Test Tenant")
        expect(tenant.id).to be_present
        expect(tenant.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
      end
    end

    describe "without signup phase" do
      it "cannot create tenant normally" do
        expect {
          Tenant.create!(name: "Test Tenant")
        }.to raise_error(ActiveRecord::StatementInvalid, /row-level security policy/)
      end

      it "cannot read tenants normally without current_tenant setting" do
        tenant = Tenant.create_with_signup(name: "Test Tenant")

        # app.current_tenantが設定されていない場合は読み取れない
        # ただし、app.signup_phaseが設定されている場合は読み取れる
        ActiveRecord::Base.connection.execute("RESET app.signup_phase")
        expect(Tenant.find_by(id: tenant.id)).to be_nil
      end
    end
  end

  describe "factory" do
    it "creates a valid tenant using signup method" do
      tenant = build(:tenant)
      expect(tenant).to be_valid
    end

    it "creates a tenant with specific name trait" do
      tenant = build(:tenant, :with_specific_name)
      expect(tenant.name).to eq("Acme Corp")
    end
  end
end
