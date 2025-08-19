require 'rails_helper'

RSpec.describe LoginForm, type: :model do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant, password: 'password123') }

  describe 'validations' do
    subject { described_class.new(valid_attributes) }

    let(:valid_attributes) do
      {
        tenant_name: tenant.name,
        email: user.email,
        password: 'password123'
      }
    end

    it { should validate_presence_of(:tenant_name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }

    it 'validates email format' do
      subject.email = 'invalid-email'
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include('形式が正しくありません')
    end
  end

  describe '#authenticate' do
    context 'with valid credentials' do
      let(:form) do
        described_class.new(
          tenant_name: tenant.name,
          email: user.email,
          password: 'password123'
        )
      end

      it 'returns the authenticated user' do
        authenticated_user = form.authenticate
        expect(authenticated_user).to eq(user)
      end
    end

    context 'with invalid tenant name' do
      let(:form) do
        described_class.new(
          tenant_name: 'nonexistent',
          email: user.email,
          password: 'password123'
        )
      end

      it 'returns nil' do
        expect(form.authenticate).to be_nil
      end
    end

    context 'with invalid email' do
      let(:form) do
        described_class.new(
          tenant_name: tenant.name,
          email: 'nonexistent@example.com',
          password: 'password123'
        )
      end

      it 'returns nil' do
        expect(form.authenticate).to be_nil
      end
    end

    context 'with invalid password' do
      let(:form) do
        described_class.new(
          tenant_name: tenant.name,
          email: user.email,
          password: 'wrongpassword'
        )
      end

      it 'returns nil' do
        expect(form.authenticate).to be_nil
      end
    end

    context 'with empty values' do
      let(:form) do
        described_class.new(
          tenant_name: '',
          email: '',
          password: ''
        )
      end

      it 'returns nil when invalid' do
        expect(form.authenticate).to be_nil
      end
    end

    context 'when user belongs to different tenant' do
      let(:other_tenant) { create(:tenant) }
      let(:form) do
        described_class.new(
          tenant_name: other_tenant.name,
          email: user.email,
          password: 'password123'
        )
      end

      it 'returns nil due to tenant isolation' do
        expect(form.authenticate).to be_nil
      end
    end
  end
end
