class FieldErrorComponentPreview < ViewComponent::Preview
  def with_error_message
    render(FieldErrorComponent.new(errors: [ "このフィールドは必須です" ]))
  end

  def with_no_error
    render(FieldErrorComponent.new(errors: []))
  end

  def with_multiple_errors
    render(FieldErrorComponent.new(errors: [ "このフィールドは必須です", "100文字以内で入力してください" ]))
  end

  def with_long_error_message
    render(FieldErrorComponent.new(errors: [ "100文字以内で入力してください" ]))
  end
end
