# frozen_string_literal: true

class ButtonComponent < ViewComponent::Base
  def initialize(text:, variant:)
    @text = text
    @variant = variant
  end
end
