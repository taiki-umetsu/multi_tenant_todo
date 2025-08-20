require 'rails_helper'

RSpec.describe 'ユーザー招待システム', type: :system do
  let(:tenant) { create(:tenant) }
  let(:admin_user) { create(:user, tenant: tenant, role: :admin, password: 'password123') }

  before do
    driven_by(:selenium_headless)
  end

  describe 'ユーザー招待機能' do
    before do
      # 管理者としてログイン
      visit login_path
      within('form') do
        fill_in 'テナント名', with: tenant.name
        fill_in 'メールアドレス', with: admin_user.email
        fill_in 'パスワード', with: 'password123'
        click_button 'ログイン'
      end
      visit admin_users_path
    end

    context '有効な招待の場合' do
      it '招待モーダルが表示される' do
        expect(page).to have_button '招待'
        click_button '招待'

        expect(page).to have_content 'ユーザー招待'
        expect(page).to have_field 'メールアドレス'
        expect(page).to have_field '権限'
        expect(page).to have_button '招待URLを作成'
      end

      it 'メンバーとして招待できる', js: true do
        click_button '招待'

        within('#invitation-modal') do
          fill_in 'メールアドレス', with: 'newuser@example.com'
          select 'メンバー', from: '権限'
          click_button '招待URLを作成'
        end

        # Turbo Streamで成功メッセージが表示されることを確認
        expect(page).to have_css('#invitation_result .bg-green-50')
        within('#invitation_result') do
          expect(page).to have_content('招待URLが生成されました')
        end
      end

      it 'URLをコピーボタンが機能する', js: true do
        click_button '招待'

        within('#invitation-modal') do
          fill_in 'メールアドレス', with: 'copytest@example.com'
          select 'メンバー', from: '権限'
          click_button '招待URLを作成'
        end

        # 招待URL生成を確認
        expect(page).to have_css('#invitation_result .bg-green-50')

        # URLをコピーボタンをクリック
        within('#invitation_result') do
          expect(page).to have_button('URLをコピー')
          click_button 'URLをコピー'

          # フィードバックメッセージが表示されることを確認
          expect(page).to have_content('コピーしました')
        end
      end

      it '管理者として招待できる', js: true do
        click_button '招待'

        within('#invitation-modal') do
          fill_in 'メールアドレス', with: 'admin@example.com'
          select '管理者', from: '権限'
          click_button '招待URLを作成'
        end

        # Turbo Streamで成功メッセージが表示されることを確認
        expect(page).to have_css('#invitation_result .bg-green-50', wait: 10)

        # 招待が作成されたことを確認
        User.with_tenant(tenant.id) do
          invitation = UserInvitation.find_by(email: 'admin@example.com')
          expect(invitation).to be_present
          expect(invitation.role).to eq('admin')
        end
      end
    end

    context '無効な招待の場合' do
      it '空のメールアドレスでエラーが表示される', js: true do
        click_button '招待'

        within('#invitation-modal') do
          fill_in 'メールアドレス', with: ''
          select 'メンバー', from: '権限'
          click_button '招待URLを作成'
        end

        # Turbo Streamでエラーメッセージが表示されることを確認
        expect(page).to have_css('#invitation_result .bg-red-50')
        within('#invitation_result') do
          expect(page).to have_content('入力してください')
        end
      end

      it '既存ユーザーのメールアドレスでエラーが表示される', js: true do
        click_button '招待'

        within('#invitation-modal') do
          fill_in 'メールアドレス', with: admin_user.email
          select 'メンバー', from: '権限'
          click_button '招待URLを作成'
        end

        # Turbo Streamでエラーメッセージが表示されることを確認
        expect(page).to have_css('#invitation_result .bg-red-50')
        within('#invitation_result') do
          expect(page).to have_content('既に登録済みです')
        end
      end

      it '同じメールアドレスで重複招待はエラーが表示される', js: true do
        # 最初の招待を作成
        User.with_tenant(tenant.id) do
          create(:user_invitation, tenant: tenant, email: 'duplicate@example.com')
        end

        click_button '招待'

        within('#invitation-modal') do
          fill_in 'メールアドレス', with: 'duplicate@example.com'
          select 'メンバー', from: '権限'
          click_button '招待URLを作成'
        end

        # Turbo Streamでエラーメッセージが表示されることを確認
        expect(page).to have_css('#invitation_result .bg-red-50')
        within('#invitation_result') do
          expect(page).to have_content('すでに存在します')
        end
      end
    end

    context 'モーダルの操作' do
      it 'モーダルを閉じることができる', js: true do
        click_button '招待'
        expect(page).to have_css('#invitation-modal', visible: true)

        # ×ボタンでモーダルを閉じる
        within('#invitation-modal') do
          find('.modal-close-btn').click
        end

        expect(page).to have_css('#invitation-modal', visible: false)
      end

      it 'モーダル外をクリックして閉じることができる', js: true do
        click_button '招待'
        expect(page).to have_css('#invitation-modal', visible: true)

        # モーダル外をクリック
        find('.modal-overlay').click

        expect(page).to have_css('#invitation-modal', visible: false)
      end
    end
  end

  describe '招待受諾機能' do
    let!(:invitation) { create(:user_invitation, tenant: tenant, email: 'invited@example.com', role: :member) }

    context '有効な招待URLの場合' do
      it '招待受諾フォームが表示される' do
        visit new_user_path(token: invitation.token)

        expect(page).to have_content 'アカウント作成'
        expect(page).to have_content 'invited@example.com'
        expect(page).to have_field 'パスワード'
        expect(page).to have_field 'パスワード確認'
        expect(page).to have_button 'アカウント作成'
      end

      it 'ユーザーアカウントを作成してログインできる' do
        visit new_user_path(token: invitation.token)

        fill_in 'パスワード', with: 'password123'
        fill_in 'パスワード確認', with: 'password123'
        click_button 'アカウント作成'

        expect(page).to have_content 'アカウントが作成されました'
        expect(current_path).to eq(root_path)

        # ユーザーが作成されたことを確認
        User.with_tenant(tenant.id) do
          user = User.find_by(email: 'invited@example.com')
          expect(user).to be_present
          expect(user.role).to eq('member')
        end

        # 招待が削除されたことを確認
        User.with_tenant(tenant.id) do
          expect(UserInvitation.find_by(token: invitation.token)).to be_nil
        end
      end

      it 'パスワード不一致でエラーが表示される' do
        visit new_user_path(token: invitation.token)

        fill_in 'パスワード', with: 'password123'
        fill_in 'パスワード確認', with: 'different'
        click_button 'アカウント作成'

        expect(page).to have_content 'ユーザー作成に失敗しました'
        expect(current_path).to eq(new_user_path)
      end

      it '短すぎるパスワードでエラーが表示される' do
        visit new_user_path(token: invitation.token)

        fill_in 'パスワード', with: '123'
        fill_in 'パスワード確認', with: '123'
        click_button 'アカウント作成'

        expect(page).to have_content 'ユーザー作成に失敗しました'
        expect(current_path).to eq(new_user_path)
      end
    end

    context '無効な招待URLの場合' do
      it '存在しないトークンでエラーページが表示される' do
        visit new_user_path(token: 'invalid-token')

        expect(page).to have_content '無効な招待URLです'
        expect(current_path).to eq(root_path)
      end

      it '期限切れの招待でエラーページが表示される' do
        expired_invitation = create(:user_invitation, :expired, tenant: tenant)

        visit new_user_path(token: expired_invitation.token)

        expect(page).to have_content '招待URLの有効期限が切れています'
        expect(current_path).to eq(root_path)
      end
    end

    context 'ログイン済みユーザーのアクセス' do
      before do
        # 別のユーザーでログイン
        other_user = create(:user, tenant: tenant)
        visit login_path
        within('form') do
          fill_in 'テナント名', with: tenant.name
          fill_in 'メールアドレス', with: other_user.email
          fill_in 'パスワード', with: 'password123'
          click_button 'ログイン'
        end
      end

      it 'ログアウトしてから招待受諾フォームが表示される' do
        visit new_user_path(token: invitation.token)

        expect(page).to have_content 'アカウント作成'
        expect(page).to have_content 'invited@example.com'
      end
    end
  end
end
