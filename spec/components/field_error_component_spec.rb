require 'rails_helper'

RSpec.describe FieldErrorComponent, type: :component do
  describe 'rendering' do
    it 'renders error message with correct styling' do
      render_preview(:with_error_message)

      expect(page).to have_content("このフィールドは必須です")
      expect(page).to have_css('p.mt-1.text-sm.text-red-600', text: "このフィールドは必須です")
    end

    it 'does not render when errors are empty' do
      render_preview(:with_no_error)

      expect(page).not_to have_css('p')
    end

    it 'renders multiple error messages' do
      render_preview(:with_multiple_errors)

      expect(page).to have_content("このフィールドは必須です")
      expect(page).to have_content("100文字以内で入力してください")
      expect(page).to have_css('p.mt-1.text-sm.text-red-600', count: 2)
    end

    it 'renders long error message' do
      render_preview(:with_long_error_message)

      expect(page).to have_content("100文字以内で入力してください")
      expect(page).to have_css('p.mt-1.text-sm.text-red-600')
    end
  end
end
