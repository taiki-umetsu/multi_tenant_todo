class ButtonComponentPreview < ViewComponent::Preview
  def primary_button
    render ButtonComponent.new(text: "プライマリボタン", type: :primary)
  end

  def secondary_button
    render ButtonComponent.new(text: "セカンダリボタン", type: :secondary)
  end

  def button_to_form
    render ButtonComponent.new(
      text: "ログアウト",
      type: :secondary,
      href: "/logout",
      method: :delete
    )
  end
end
