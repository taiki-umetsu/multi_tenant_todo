class SubmitButtonComponentPreview < ViewComponent::Preview
  def with_create_text
    render(SubmitButtonComponent.new(text: "テナントを作成", disable_with: "作成中..."))
  end

  def with_save_text
    render(SubmitButtonComponent.new(text: "保存", disable_with: "保存中..."))
  end

  def with_long_text
    render(SubmitButtonComponent.new(text: "アカウントを作成して始める", disable_with: "作成中です..."))
  end
end
