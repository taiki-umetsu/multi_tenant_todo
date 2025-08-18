class FormFieldComponent < ViewComponent::Base
  ALLOWED_FIELD_TYPES = [
    :text_field,
    :email_field,
    :password_field
  ].freeze

  def initialize(form:, field_name:, label_text:, field_type:, hint: nil)
    unless ALLOWED_FIELD_TYPES.include?(field_type)
      raise ArgumentError, "field_type must be one of #{ALLOWED_FIELD_TYPES.join(', ')}"
    end

    @form = form
    @field_name = field_name
    @label_text = label_text
    @field_type = field_type
    @hint = hint
  end

  private

  def field_errors
    @form.object.errors[@field_name]
  end
end
