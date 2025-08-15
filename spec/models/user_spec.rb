require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  describe 'associations' do
    it { should belong_to(:tenant) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:role) }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(member: 0, admin: 1) }
  end

  describe 'password encryption' do
    let(:user) { build(:user, password: 'test123') }

    it 'encrypts password' do
      expect(user.password_digest).to be_present
    end

    it 'authenticates with correct password' do
      user.save!
      expect(user.authenticate('test123')).to eq(user)
    end

    it 'does not authenticate with wrong password' do
      user.save!
      expect(user.authenticate('wrong')).to be_falsey
    end
  end

  describe '.with_tenant' do
    let(:tenant) { create(:tenant) }

    it 'sets current_tenant in transaction' do
      expect(ActiveRecord::Base.connection).to receive(:execute)
        .with("SET LOCAL app.current_tenant = '#{tenant.id}'")

      User.with_tenant(tenant.id) do
        # テスト内容
      end
    end

    it 'yields block within transaction' do
      block_executed = false
      User.with_tenant(tenant.id) do
        block_executed = true
      end
      expect(block_executed).to be true
    end
  end

  describe '.create_with_tenant' do
    let(:tenant) { create(:tenant) }
    let(:user_attrs) { { email: 'test@example.com', password: 'password123' } }

    it 'creates user with tenant context' do
      expect(User).to receive(:with_tenant).with(tenant.id).and_call_original
      
      user = User.create_with_tenant(tenant.id, user_attrs.merge(tenant: tenant))
      expect(user).to be_persisted
      expect(user.tenant).to eq(tenant)
    end
  end
end
