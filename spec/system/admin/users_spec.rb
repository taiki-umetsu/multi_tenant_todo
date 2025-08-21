require 'rails_helper'

RSpec.describe '管理者ユーザー管理画面', type: :system do
  let(:tenant) { create(:tenant) }
  let!(:admin_user) { create(:user, :admin, tenant: tenant) }
  let!(:member_user) { create(:user, tenant: tenant) }
  let!(:valid_invitation) { create(:user_invitation, tenant: tenant, email: 'test@example.com', role: 'member') }
  let!(:expired_invitation) { create(:user_invitation, tenant: tenant, email: 'expired@example.com', role: 'admin', expires_at: 1.hour.ago) }

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
        expect(page).to have_button '招待'
      end

      it '登録済みユーザー一覧が表示される' do
        visit admin_users_path

        expect(page).to have_content '登録済みユーザー'
        expect(page).to have_content '2件'

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

        expect(page).to have_content '1件'
        expect(page).to have_content single_admin.email
      end
    end
  end

  describe '招待中ユーザー一覧' do
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

      it '招待中のユーザー一覧が表示される' do
        visit admin_users_path

        expect(page).to have_content '招待中のユーザー'
        expect(page).to have_content '2件'

        # テーブルヘッダーの確認
        expect(page).to have_content 'メールアドレス'
        expect(page).to have_content '権限'
        expect(page).to have_content '招待日'
        expect(page).to have_content 'ステータス'
        expect(page).to have_content '招待URL'
      end

      it '有効な招待が表示される' do
        visit admin_users_path

        expect(page).to have_content valid_invitation.email
        expect(page).to have_content 'メンバー'
        expect(page).to have_content '有効'
      end

      it '期限切れの招待が表示される' do
        visit admin_users_path

        expect(page).to have_content expired_invitation.email
        expect(page).to have_content '管理者'
        expect(page).to have_content '期限切れ'
      end

      it 'URLをコピーボタンが表示される' do
        visit admin_users_path

        expect(page).to have_button 'URLをコピー', count: 2
      end

      it '招待日が表示される' do
        visit admin_users_path

        # 日本語フォーマットで日付が表示されることを確認
        expect(page).to have_content '年'
        expect(page).to have_content '月'
        expect(page).to have_content '日'
      end
    end

    context '招待がない場合' do
      let(:empty_tenant) { create(:tenant) }
      let(:empty_admin) { create(:user, :admin, tenant: empty_tenant) }

      before do
        # 招待がないテナントの管理者でログイン
        visit login_path
        within('form') do
          fill_in 'テナント名', with: empty_tenant.name
          fill_in 'メールアドレス', with: empty_admin.email
          fill_in 'パスワード', with: 'password123'
          click_button 'ログイン'
        end
      end

      it '招待がない旨のメッセージが表示される' do
        visit admin_users_path

        expect(page).to have_content '招待中のユーザー'
        expect(page).to have_content '0件'
        expect(page).to have_content '招待中のユーザーはいません'
      end
    end
  end
end
