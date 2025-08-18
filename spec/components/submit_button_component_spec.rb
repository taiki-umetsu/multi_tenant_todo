require 'rails_helper'

RSpec.describe SubmitButtonComponent, type: :component do
  describe 'rendering' do
    it 'renders submit button with correct text and disable_with' do
      render_preview(:with_create_text)

      expect(page).to have_content("テナントを作成")
      expect(page).to have_css('button[type="submit"]', text: "テナントを作成")
      expect(page).to have_css('button[data-disable-with="作成中..."]')
    end

    it 'renders button with save text' do
      render_preview(:with_save_text)

      expect(page).to have_content("保存")
      expect(page).to have_css('button[type="submit"]', text: "保存")
      expect(page).to have_css('button[data-disable-with="保存中..."]')
    end

    it 'renders button with long text' do
      render_preview(:with_long_text)

      expect(page).to have_content("アカウントを作成して始める")
      expect(page).to have_css('button[type="submit"]', text: "アカウントを作成して始める")
      expect(page).to have_css('button[data-disable-with="作成中です..."]')
    end
  end
end
