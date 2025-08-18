require 'rails_helper'

RSpec.describe FormFieldComponent, type: :component do
  describe 'rendering' do
    it 'renders text field with label' do
      render_preview(:with_text_field)

      expect(page).to have_content("テナント名")
      expect(page).to have_css('label', text: "テナント名")
      expect(page).to have_css('input[type="text"][name*="tenant_name"]')
    end

    it 'renders email field with label' do
      render_preview(:with_email_field)

      expect(page).to have_content("メールアドレス")
      expect(page).to have_css('label', text: "メールアドレス")
      expect(page).to have_css('input[type="email"][name*="user_email"]')
    end

    it 'renders password field with label' do
      render_preview(:with_password_field)

      expect(page).to have_content("パスワード")
      expect(page).to have_css('label', text: "パスワード")
      expect(page).to have_css('input[type="password"][name*="user_password"]')
    end

    it 'renders field with validation errors' do
      render_preview(:with_errors)

      expect(page).to have_content("テナント名")
      expect(page).to have_css('input[type="text"][name*="tenant_name"]')
      expect(page).to have_css('p.text-red-600', text: "入力してください")
    end
  end
end
