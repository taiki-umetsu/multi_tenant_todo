require 'rails_helper'

RSpec.describe 'ログイン画面', type: :system do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant, password: 'password123') }

  before do
    driven_by(:rack_test)
  end

  describe 'ログインフォーム' do
    it 'ログインフォームが表示される' do
      visit login_path

      expect(page).to have_content 'ログイン'
      expect(page).to have_field 'テナント名'
      expect(page).to have_field 'メールアドレス'
      expect(page).to have_field 'パスワード', type: 'password'
      expect(page).to have_button 'ログイン'
      expect(page).to have_link 'テナント作成', href: new_tenant_path
    end

    it '正常なログインができる' do
      visit login_path

      within('form') do
        fill_in 'テナント名', with: tenant.name
        fill_in 'メールアドレス', with: user.email
        fill_in 'パスワード', with: 'password123'
        click_button 'ログイン'
      end

      expect(page).to have_content 'ログインしました'
      expect(current_path).to eq root_path
    end

    it '必須項目が未入力の場合エラーが表示される' do
      visit login_path

      click_button 'ログイン'

      expect(page).to have_content '入力してください'
      expect(current_path).to eq login_path
    end

    it '存在しないテナント名でログインを試みるとエラーが表示される' do
      visit login_path

      within('form') do
        fill_in 'テナント名', with: 'nonexistent'
        fill_in 'メールアドレス', with: user.email
        fill_in 'パスワード', with: 'password123'
        click_button 'ログイン'
      end

      expect(page).to have_content 'テナント名、メールアドレス、またはパスワードが正しくありません'
      expect(current_path).to eq login_path
    end

    it '存在しないメールアドレスでログインを試みるとエラーが表示される' do
      visit login_path

      within('form') do
        fill_in 'テナント名', with: tenant.name
        fill_in 'メールアドレス', with: 'nonexistent@example.com'
        fill_in 'パスワード', with: 'password123'
        click_button 'ログイン'
      end

      expect(page).to have_content 'テナント名、メールアドレス、またはパスワードが正しくありません'
      expect(current_path).to eq login_path
    end

    it '間違ったパスワードでログインを試みるとエラーが表示される' do
      visit login_path

      within('form') do
        fill_in 'テナント名', with: tenant.name
        fill_in 'メールアドレス', with: user.email
        fill_in 'パスワード', with: 'wrongpassword'
        click_button 'ログイン'
      end

      expect(page).to have_content 'テナント名、メールアドレス、またはパスワードが正しくありません'
      expect(current_path).to eq login_path
    end

    it '無効なメールアドレス形式でログインを試みるとエラーが表示される' do
      visit login_path

      within('form') do
        fill_in 'テナント名', with: tenant.name
        fill_in 'メールアドレス', with: 'invalid-email'
        fill_in 'パスワード', with: 'password123'
        click_button 'ログイン'
      end

      expect(page).to have_content '形式が正しくありません'
      expect(current_path).to eq login_path
    end

    it '他のテナントのユーザーでログインを試みるとエラーが表示される' do
      other_tenant = create(:tenant, name: 'Other Company')

      visit login_path

      within('form') do
        fill_in 'テナント名', with: other_tenant.name
        fill_in 'メールアドレス', with: user.email
        fill_in 'パスワード', with: 'password123'
        click_button 'ログイン'
      end

      expect(page).to have_content 'テナント名、メールアドレス、またはパスワードが正しくありません'
      expect(current_path).to eq login_path
    end
  end

  describe 'ログアウト機能' do
    before do
      # ログインしておく
      visit login_path
      within('form') do
        fill_in 'テナント名', with: tenant.name
        fill_in 'メールアドレス', with: user.email
        fill_in 'パスワード', with: 'password123'
        click_button 'ログイン'
      end
    end

    it 'ログアウトできる' do
      # ナビゲーションからログアウトボタンをクリック
      click_button 'ログアウト'

      expect(page).to have_content 'ログアウトしました'
      expect(current_path).to eq login_path
    end

    it 'ログアウト後はログインページにアクセスできる' do
      click_button 'ログアウト'

      visit login_path
      expect(page).to have_content 'ログイン'
      expect(page).to have_field 'テナント名'
    end
  end

  describe 'ログイン状態での画面アクセス' do
    context 'ログイン済みの場合' do
      before do
        visit login_path
        within('form') do
          fill_in 'テナント名', with: tenant.name
          fill_in 'メールアドレス', with: user.email
          fill_in 'パスワード', with: 'password123'
          click_button 'ログイン'
        end
      end

      it 'ログインページにアクセスするとルートパスにリダイレクトされる' do
        visit login_path
        expect(current_path).to eq root_path
      end
    end
  end
end
