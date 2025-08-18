class SubmitButtonComponent < ViewComponent::Base
  def initialize(text:, disable_with:)
    @text = text
    @disable_with = disable_with
  end
end
