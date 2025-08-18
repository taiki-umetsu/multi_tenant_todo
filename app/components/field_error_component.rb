class FieldErrorComponent < ViewComponent::Base
  def initialize(errors:)
    @errors = errors
  end

  def render?
    @errors.any?
  end
end
