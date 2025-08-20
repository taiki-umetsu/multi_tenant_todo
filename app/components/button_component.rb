class ButtonComponent < ViewComponent::Base
  TYPES = {
    primary: "bg-indigo-600 text-white hover:bg-indigo-700 focus:ring-indigo-500",
    secondary: "bg-white text-gray-900 border border-gray-300 hover:bg-gray-50 focus:ring-gray-500"
  }.freeze

  def initialize(text:, type:, href: nil, method: nil, **html_options)
    unless TYPES.key?(type)
      raise ArgumentError, "type must be one of #{TYPES.keys.join(', ')}"
    end

    @text = text
    @type = type
    @href = href
    @method = method
    @html_options = html_options
  end

  def css_classes
    base_classes = "px-4 py-2 rounded-md text-sm font-medium focus:outline-none focus:ring-1"
    type_classes = TYPES[@type]

    [ base_classes, type_classes, @html_options[:class] ].compact.join(" ")
  end

  def html_options_without_class
    @html_options.except(:class)
  end
end
