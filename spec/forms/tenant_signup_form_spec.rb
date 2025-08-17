require 'rails_helper'

RSpec.describe TenantSignupForm, type: :model do
  describe 'validations' do
    subject { described_class.new(valid_attributes) }

    let(:valid_attributes) do
      {
        tenant_name: 'Test Company',
        user_email: 'admin@test.com',
        user_password: 'password123',
        user_password_confirmation: 'password123'
      }
    end

    it { should validate_presence_of(:tenant_name) }
    it { should validate_length_of(:tenant_name).is_at_most(Tenant::NAME_MAX_LENGTH) }
    it { should validate_presence_of(:user_password_confirmation) }

    it 'validates password confirmation matches' do
      subject.user_password_confirmation = 'different'
      expect(subject).not_to be_valid
      expect(subject.errors[:user_password_confirmation]).to include('パスワードが一致しません')
    end

    it 'validates tenant name length exceeds maximum' do
      long_name = "a" * (Tenant::NAME_MAX_LENGTH + 1)
      subject.tenant_name = long_name
      expect(subject).not_to be_valid
      expect(subject.errors[:tenant_name]).to include("#{Tenant::NAME_MAX_LENGTH}文字以内で入力してください")
    end
  end

  describe '#save' do
    let(:valid_attributes) do
      {
        tenant_name: 'Test Company',
        user_email: 'admin@test.com',
        user_password: 'password123',
        user_password_confirmation: 'password123'
      }
    end

    context 'with valid attributes' do
      it 'creates tenant and admin user' do
        form = described_class.new(valid_attributes)

        expect { form.save }.to change(Tenant, :count).by(1)
                                                      .and change(User, :count).by(1)

        expect(form.tenant.name).to eq('Test Company')
        expect(form.user.email).to eq('admin@test.com')
        expect(form.user.role).to eq('admin')
        expect(form.user.tenant).to eq(form.tenant)
      end

      it 'returns true' do
        form = described_class.new(valid_attributes)
        expect(form.save).to be true
      end
    end

    context 'with invalid attributes' do
      it 'does not create any records' do
        form = described_class.new(tenant_name: '')

        expect { form.save }.not_to change(Tenant, :count)
        expect { form.save }.not_to change(User, :count)
      end

      it 'returns false' do
        form = described_class.new(tenant_name: '')
        expect(form.save).to be false
      end
    end

    context 'when tenant creation fails' do
      before do
        allow(Tenant).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Tenant.new))
      end

      it 'handles errors and returns false' do
        form = described_class.new(valid_attributes)
        expect(form.save).to be false
      end
    end
  end
end
