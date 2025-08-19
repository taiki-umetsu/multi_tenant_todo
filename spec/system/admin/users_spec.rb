require 'rails_helper'

RSpec.describe '管理者ユーザー管理画面', type: :system do
  let(:tenant) { create(:tenant) }
  let!(:admin_user) { create(:user, :admin, tenant: tenant) }
  let!(:member_user) { create(:user, tenant: tenant) }

  before do
    driven_by(:rack_test)
  end

  describe '登録済みユーザー一覧' do
    context '管理者でログインした場合' do
      before do
        # 管理者でログイン
        visit login_path
        within('form') do
          fill_in 'テナント名', with: tenant.name
          fill_in 'メールアドレス', with: admin_user.email
          fill_in 'パスワード', with: 'password123'
          click_button 'ログイン'
        end
      end

      it 'ユーザー管理画面が表示される' do
        visit admin_users_path

        expect(page).to have_content 'ユーザー管理'
        expect(page).to have_content 'テナント内のユーザーの管理と招待を行います'
      end

      it '登録済みユーザー一覧が表示される' do
        visit admin_users_path

        expect(page).to have_content '登録済みユーザー'
        expect(page).to have_content '2名のユーザー'

        # テーブルヘッダーの確認
        expect(page).to have_content 'メールアドレス'
        expect(page).to have_content '権限'
        expect(page).to have_content '登録日'
      end

      it '管理者ユーザーが表示される' do
        visit admin_users_path

        expect(page).to have_content admin_user.email
        expect(page).to have_content '管理者'
      end

      it 'メンバーユーザーが表示される' do
        visit admin_users_path

        expect(page).to have_content member_user.email
        expect(page).to have_content 'メンバー'
      end

      it 'ユーザーの登録日が表示される' do
        visit admin_users_path

        # 日本語フォーマットで日付が表示されることを確認
        expect(page).to have_content '年'
        expect(page).to have_content '月'
        expect(page).to have_content '日'
      end

      it 'ユーザー管理ナビゲーションリンクが表示される' do
        visit root_path

        expect(page).to have_link 'ユーザー管理', href: admin_users_path
      end
    end

    context 'メンバーユーザーでログインした場合' do
      before do
        # メンバーでログイン
        visit login_path
        within('form') do
          fill_in 'テナント名', with: tenant.name
          fill_in 'メールアドレス', with: member_user.email
          fill_in 'パスワード', with: 'password123'
          click_button 'ログイン'
        end
      end

      it 'ユーザー管理画面にアクセスできない' do
        visit admin_users_path

        expect(current_path).to eq root_path
        expect(page).to have_content '管理者権限が必要です'
      end

      it 'ユーザー管理ナビゲーションリンクが表示されない' do
        visit root_path

        expect(page).not_to have_link 'ユーザー管理'
      end
    end

    context 'ユーザーが1人しかいない場合' do
      let(:single_tenant) { create(:tenant) }
      let(:single_admin) { create(:user, :admin, tenant: single_tenant) }

      before do
        # 単一ユーザーでログイン
        visit login_path
        within('form') do
          fill_in 'テナント名', with: single_tenant.name
          fill_in 'メールアドレス', with: single_admin.email
          fill_in 'パスワード', with: 'password123'
          click_button 'ログイン'
        end
      end

      it '正しいユーザー数が表示される' do
        visit admin_users_path

        expect(page).to have_content '1名のユーザー'
        expect(page).to have_content single_admin.email
      end
    end
  end
end
