require 'rails_helper'

RSpec.describe TableComponent, type: :component do
  describe 'rendering' do
    it 'renders table with data' do
      render_preview(:with_data)

      # ヘッダーの確認
      expect(page).to have_content("名前")
      expect(page).to have_content("メール")
      expect(page).to have_content("日付")

      # データ行の確認
      expect(page).to have_content("太郎")
      expect(page).to have_content("taro@example.com")
      expect(page).to have_content("2024-01-01")
      expect(page).to have_content("花子")
      expect(page).to have_content("hanako@example.com")
      expect(page).to have_content("2024-01-02")

      # テーブル構造の確認
      expect(page).to have_css("table")
      expect(page).to have_css("thead")
      expect(page).to have_css("tbody")
    end

    it 'renders empty state with default message' do
      render_preview(:empty_state)

      expect(page).to have_content("データがありません")
      expect(page).to have_css("table")
      expect(page).to have_css("thead")
      expect(page).to have_css("tbody")
    end

    it 'renders empty state with custom message' do
      render_preview(:custom_empty_message)

      expect(page).to have_content("ユーザーが見つかりません")
      expect(page).not_to have_content("データがありません")
      expect(page).to have_css("table")
      expect(page).to have_css("thead")
      expect(page).to have_css("tbody")
    end
  end
end
