require 'rails_helper'

RSpec.describe UserInvitation, type: :model do
  let(:tenant) { create(:tenant) }

  describe "validations" do
    around do |example|
      User.with_tenant(tenant.id) do
        example.run
      end
    end

    subject { build(:user_invitation, tenant: tenant) }

    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:role) }

    it "validates token presence through callback" do
      invitation = build(:user_invitation, tenant: tenant, token: nil)
      invitation.valid?
      expect(invitation.token).to be_present
    end

    it "validates expires_at presence through callback" do
      invitation = build(:user_invitation, tenant: tenant, expires_at: nil)
      invitation.valid?
      expect(invitation.expires_at).to be_present
    end

    it "validates token uniqueness" do
      create(:user_invitation, tenant: tenant, token: "existing-token")
      invitation = build(:user_invitation, tenant: tenant, token: "existing-token")
      expect(invitation).to be_invalid
      expect(invitation.errors[:token]).to include("すでに存在します")
    end

    it "validates email uniqueness within tenant" do
      create(:user_invitation, tenant: tenant, email: "test@example.com")
      invitation = build(:user_invitation, tenant: tenant, email: "test@example.com")
      expect(invitation).to be_invalid
      expect(invitation.errors[:email]).to include("すでに存在します")
    end

    it "validates email format" do
      invitation = build(:user_invitation, tenant: tenant, email: "invalid-email")
      expect(invitation).to be_invalid
      expect(invitation.errors[:email]).to include("形式が正しくありません")
    end

    context "when email is already registered in tenant" do
      let!(:existing_user) { create(:user, tenant: tenant, email: "test@example.com") }

      it "prevents invitation to existing user email" do
        User.with_tenant(tenant.id) do
          invitation = build(:user_invitation, tenant: tenant, email: "test@example.com")
          expect(invitation).to be_invalid
          expect(invitation.errors[:email]).to include("は既に登録済みです")
        end
      end
    end

    context "when email exists in different tenant" do
      let(:other_tenant) { create(:tenant, name: "Other Company") }
      let!(:other_user) { create(:user, tenant: other_tenant, email: "test@example.com") }

      it "allows invitation to same email in different tenant" do
        User.with_tenant(tenant.id) do
          invitation = build(:user_invitation, tenant: tenant, email: "test@example.com")
          expect(invitation).to be_valid
        end
      end
    end
  end

  describe "associations" do
    it { should belong_to(:tenant) }
  end

  describe "enums" do
    it { should define_enum_for(:role).with_values(member: 0, admin: 1) }
  end

  describe "scopes" do
    around do |example|
      User.with_tenant(tenant.id) do
        example.run
      end
    end

    let!(:valid_invitation) { create(:user_invitation, tenant: tenant, expires_at: 1.hour.from_now) }
    let!(:expired_invitation) { create(:user_invitation, tenant: tenant, expires_at: 1.hour.ago) }

    describe ".valid" do
      it "returns non-expired invitations" do
        expect(UserInvitation.valid).to include(valid_invitation)
        expect(UserInvitation.valid).not_to include(expired_invitation)
      end
    end

    describe ".expired" do
      it "returns expired invitations" do
        expect(UserInvitation.expired).to include(expired_invitation)
        expect(UserInvitation.expired).not_to include(valid_invitation)
      end
    end
  end

  describe "callbacks" do
    around do |example|
      User.with_tenant(tenant.id) do
        example.run
      end
    end

    describe "token generation" do
      it "generates token on creation" do
        invitation = build(:user_invitation, tenant: tenant, token: nil)
        invitation.save
        expect(invitation.token).to be_present
        expect(invitation.token.length).to be >= 32
      end

      it "does not override existing token" do
        existing_token = "existing-token"
        invitation = build(:user_invitation, tenant: tenant, token: existing_token)
        invitation.save
        expect(invitation.token).to eq(existing_token)
      end
    end

    describe "expires_at generation" do
      it "sets expires_at to 1 day from now" do
        invitation = create(:user_invitation, tenant: tenant, expires_at: nil)
        expect(invitation.expires_at).to be_within(10.seconds).of(1.day.from_now)
      end

      it "does not override existing expires_at" do
        existing_expiry = 2.days.from_now
        invitation = build(:user_invitation, tenant: tenant, expires_at: existing_expiry)
        invitation.save
        expect(invitation.expires_at).to be_within(1.second).of(existing_expiry)
      end
    end
  end

  describe "#expired?" do
    it "returns true when expires_at is in the past" do
      invitation = build(:user_invitation, tenant: tenant, expires_at: 1.hour.ago)
      expect(invitation.expired?).to be true
    end

    it "returns false when expires_at is in the future" do
      invitation = build(:user_invitation, tenant: tenant, expires_at: 1.hour.from_now)
      expect(invitation.expired?).to be false
    end
  end

  describe "class methods" do
    around do |example|
      User.with_tenant(tenant.id) do
        example.run
      end
    end

    let(:invitation) { create(:user_invitation, tenant: tenant) }

    describe ".with_token" do
      it "sets invitation token in PostgreSQL setting" do
        UserInvitation.with_token(invitation.token) do
          result = ActiveRecord::Base.connection.execute(
            "SELECT current_setting('app.invitation_token', true)"
          ).first
          expect(result["current_setting"]).to eq(invitation.token)
        end
      end
    end

    describe ".find_by_token!" do
      it "finds invitation by token using RLS" do
        found = UserInvitation.find_by_token!(invitation.token)
        expect(found).to eq(invitation)
      end

      it "raises error for non-existent token" do
        expect {
          UserInvitation.find_by_token!("non-existent-token")
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "encryption" do
    around do |example|
      User.with_tenant(tenant.id) do
        example.run
      end
    end

    it "encrypts email field" do
      invitation = create(:user_invitation, tenant: tenant, email: "test@example.com")

      # emailフィールドが暗号化されていることを確認
      expect(invitation.email).to eq("test@example.com")
      expect(invitation.attributes_before_type_cast["email"]).to be_a(String)
      expect(invitation.attributes_before_type_cast["email"]).not_to eq("test@example.com")
    end
  end

  describe "factory" do
    around do |example|
      User.with_tenant(tenant.id) do
        example.run
      end
    end

    it "creates a valid user invitation" do
      invitation = build(:user_invitation, tenant: tenant)
      expect(invitation).to be_valid
    end
  end
end
