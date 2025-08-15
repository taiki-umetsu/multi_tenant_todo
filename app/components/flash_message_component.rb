class FlashMessageComponent < ViewComponent::Base
  def initialize(flash:)
    @flash = flash
  end

  private

  def notice_classes
    "bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded mb-4"
  end

  def alert_classes
    "bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded mb-4"
  end
end
