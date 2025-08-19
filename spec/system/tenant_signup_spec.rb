require 'rails_helper'

RSpec.describe 'テナント新規作成画面', type: :system do
  before do
    driven_by(:rack_test)
  end

  describe 'テナント作成フォーム' do
    it 'テナントと管理ユーザーを正常に作成できる' do
      visit new_tenant_path

      expect(page).to have_content 'テナント作成'

      within('form') do
        fill_in 'テナント名', with: 'Test Company'
        fill_in '管理者メールアドレス', with: 'admin@test.com'
        fill_in '管理者パスワード', with: 'password123'
        fill_in '管理者パスワード確認', with: 'password123'
      end

      # テナントとユーザーの作成をチェック
      expect {
        click_button 'テナントを作成'
      }.to change {
        # signup_phaseコンテキストで作成されたテナントをカウント
        Tenant.with_signup_phase { Tenant.count }
      }.by(1)

      expect(page).to have_content 'テナント「Test Company」と管理ユーザーを作成しました'
      expect(current_path).to eq root_path

      # 作成されたテナントとユーザーを検証
      tenant = Tenant.with_signup_phase { Tenant.find_by(name: 'Test Company') }
      expect(tenant).to be_present
      expect(tenant.name).to eq 'Test Company'

      # テナントコンテキストでユーザーを取得・検証
      User.with_tenant(tenant.id) do
        user = User.find_by(email: 'admin@test.com')
        expect(user).to be_present
        expect(user.email).to eq 'admin@test.com'
        expect(user.role).to eq 'admin'
        expect(user.tenant).to eq tenant
      end

      # 自動ログインされていることを確認
      expect(page).to have_content 'Test Company'  # テナント名が表示される
      expect(page).to have_content 'admin@test.com'  # ユーザーメールが表示される
      expect(page).to have_button 'ログアウト'  # ログアウトボタンが表示される
    end

    it 'バリデーションエラーが表示される' do
      visit new_tenant_path

      click_button 'テナントを作成'

      expect(page).to have_content "入力してください"
      expect(Tenant.with_signup_phase { Tenant.count }).to eq 0
    end

    it 'パスワード不一致エラーが表示される' do
      visit new_tenant_path

      within('form') do
        fill_in 'テナント名', with: 'Test Company'
        fill_in '管理者メールアドレス', with: 'admin@test.com'
        fill_in '管理者パスワード', with: 'password123'
        fill_in '管理者パスワード確認', with: 'different'
      end

      click_button 'テナントを作成'

      expect(page).to have_content 'パスワードが一致しません'
      expect(Tenant.with_signup_phase { Tenant.count }).to eq 0
    end

    it 'メールアドレス形式エラーが表示される' do
      visit new_tenant_path

      within('form') do
        fill_in 'テナント名', with: 'Test Company'
        fill_in '管理者メールアドレス', with: 'invalid-email'
        fill_in '管理者パスワード', with: 'password123'
        fill_in '管理者パスワード確認', with: 'password123'
      end

      click_button 'テナントを作成'

      expect(page).to have_content '形式が正しくありません'
      expect(Tenant.with_signup_phase { Tenant.count }).to eq 0
    end

    it 'テナント作成後に自動ログインされ、ログアウトできる' do
      visit new_tenant_path

      within('form') do
        fill_in 'テナント名', with: 'Auto Login Test'
        fill_in '管理者メールアドレス', with: 'auto@test.com'
        fill_in '管理者パスワード', with: 'password123'
        fill_in '管理者パスワード確認', with: 'password123'
      end

      click_button 'テナントを作成'

      # 自動ログインされてルートパスにリダイレクト
      expect(current_path).to eq root_path
      expect(page).to have_button 'ログアウト'

      # ログアウトできることを確認
      click_button 'ログアウト'
      expect(current_path).to eq login_path
      expect(page).to have_content 'ログアウトしました'
    end
  end
end
