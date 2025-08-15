require 'rails_helper'

RSpec.describe User, type: :model do
  let(:tenant) { create(:tenant) }
  
  describe 'associations' do
    it 'belongs to tenant' do
      user = User.create_with_tenant!(tenant.id, {
        email: 'test@example.com', 
        password: 'password123', 
        role: :member
      })
      expect(user.tenant).to eq(tenant)
    end
  end

  describe 'validations' do
    it 'validates presence of email' do
      user = User.with_tenant(tenant.id) do
        User.new(tenant: tenant, password: 'password123', role: :member)
      end
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("入力してください")
    end
    
    it 'validates email uniqueness within tenant scope' do
      # 最初のユーザーを作成
      User.create_with_tenant!(tenant.id, {
        email: 'test@example.com', 
        password: 'password123', 
        role: :member
      })
      
      # 同じテナント内で同じメールアドレスのユーザーは作成できない
      duplicate_user = User.with_tenant(tenant.id) do
        User.new(tenant: tenant, email: 'test@example.com', password: 'password123', role: :member)
      end
      
      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email]).to include('すでに存在します')
    end

    it 'validates presence of role' do
      user = User.with_tenant(tenant.id) do
        User.new(tenant: tenant, email: 'test@example.com', password: 'password123', role: nil)
      end
      expect(user).not_to be_valid
      expect(user.errors[:role]).to include("入力してください")
    end
    
    it 'validates email format' do
      user = User.with_tenant(tenant.id) do
        User.new(tenant: tenant, email: 'invalid-email', password: 'password123', role: :member)
      end
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('形式が正しくありません')
    end

    it 'validates password length on create' do
      user = User.with_tenant(tenant.id) do
        User.new(tenant: tenant, email: 'test@example.com', password: 'short', role: :member)
      end
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('6文字以上で入力してください')
    end
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(member: 0, admin: 1) }
  end

  describe 'password encryption' do
    let(:user) do
      User.create_with_tenant!(tenant.id, {
        email: 'test@example.com',
        password: 'test123',
        role: :member
      })
    end

    it 'encrypts password' do
      expect(user.password_digest).to be_present
    end

    it 'authenticates with correct password' do
      expect(user.authenticate('test123')).to eq(user)
    end

    it 'does not authenticate with wrong password' do
      expect(user.authenticate('wrong')).to be_falsey
    end
  end

  describe '.with_tenant' do
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

  describe '.create_with_tenant!' do
    let(:user_attrs) { { email: 'test@example.com', password: 'password123', role: :member } }

    it 'creates user with tenant context' do
      expect(User).to receive(:with_tenant).with(tenant.id).and_call_original

      user = User.create_with_tenant!(tenant.id, user_attrs)
      expect(user).to be_persisted
      expect(user.tenant).to eq(tenant)
    end
  end
end
