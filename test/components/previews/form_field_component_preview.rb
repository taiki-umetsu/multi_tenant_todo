class FormFieldComponentPreview < ViewComponent::Preview
  def with_text_field
    form_object = TenantSignupForm.new
    form = ActionView::Helpers::FormBuilder.new(:tenant_signup_form, form_object, ApplicationController.new.view_context, {})
    render(FormFieldComponent.new(form: form, field_name: :tenant_name, label_text: "テナント名", field_type: :text_field))
  end

  def with_email_field
    form_object = TenantSignupForm.new
    form = ActionView::Helpers::FormBuilder.new(:tenant_signup_form, form_object, ApplicationController.new.view_context, {})
    render(FormFieldComponent.new(form: form, field_name: :user_email, label_text: "メールアドレス", field_type: :email_field))
  end

  def with_password_field
    form_object = TenantSignupForm.new
    form = ActionView::Helpers::FormBuilder.new(:tenant_signup_form, form_object, ApplicationController.new.view_context, {})
    render(FormFieldComponent.new(form: form, field_name: :user_password, label_text: "パスワード", field_type: :password_field))
  end

  def with_errors
    form_object = TenantSignupForm.new
    form_object.tenant_name = ""
    form_object.valid? # trigger validation errors
    form = ActionView::Helpers::FormBuilder.new(:tenant_signup_form, form_object, ApplicationController.new.view_context, {})
    render(FormFieldComponent.new(form: form, field_name: :tenant_name, label_text: "テナント名", field_type: :text_field))
  end
end
