require "rails_helper"

RSpec.describe ButtonComponent, type: :component do
  describe "#initialize" do
    it "accepts valid type" do
      component = ButtonComponent.new(text: "Test", type: :primary)
      expect(component).to be_instance_of(ButtonComponent)
    end

    it "raises error for invalid type" do
      expect {
        ButtonComponent.new(text: "Test", type: :invalid)
      }.to raise_error(ArgumentError, "type must be one of primary, secondary")
    end
  end

  describe "rendering" do
    it "renders primary button" do
      render_preview(:primary_button)
      expect(page).to have_button("プライマリボタン")
      expect(page).to have_css("button.bg-indigo-600")
    end

    it "renders secondary button" do
      render_preview(:secondary_button)
      expect(page).to have_button("セカンダリボタン")
      expect(page).to have_css("button.bg-white")
    end

    it "renders button_to form" do
      render_preview(:button_to_form)
      expect(page).to have_button("ログアウト")
      expect(page).to have_css("form[action='/logout'][method='post']")
    end
  end
end
