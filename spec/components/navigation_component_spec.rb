require 'rails_helper'

RSpec.describe NavigationComponent, type: :component do
  describe 'rendering' do
    it 'renders logged out navigation' do
      render_preview(:logged_out)

      expect(page).to have_link("ログイン")
      expect(page).to have_link("テナント作成")
      expect(page).not_to have_button("ログアウト")
    end

    it 'renders logged in navigation' do
      render_preview(:logged_in)

      expect(page).to have_button("ログアウト")
      expect(page).to have_content("テストテナント")
      expect(page).to have_content("test@example.com")
      expect(page).not_to have_link("ログイン")
    end

    it 'renders mobile logged in navigation' do
      tenant = build(:tenant, name: "テストテナント")
      user = build(:user, email: "test@example.com", tenant: tenant)

      with_variant(:mobile) do
        render_inline(NavigationComponent.new(current_user: user, current_tenant: tenant))
        expect(page).to have_css('[data-controller="mobile-menu"]')
        expect(page).to have_button("ログアウト")
        expect(page).to have_content("テストテナント")
        expect(page).to have_content("test@example.com")
      end
    end

    it 'renders mobile logged out navigation' do
      with_variant(:mobile) do
        render_inline(NavigationComponent.new(current_user: nil, current_tenant: nil))
        expect(page).to have_css('[data-controller="mobile-menu"]')
        expect(page).to have_link("ログイン")
        expect(page).to have_link("テナント作成")
        expect(page).not_to have_button("ログアウト")
      end
    end
  end
end
