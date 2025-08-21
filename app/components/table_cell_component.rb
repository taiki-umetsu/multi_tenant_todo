class TableCellComponent < ViewComponent::Base
  def initialize(body:, type: nil, is_header: false, width: nil)
    @body = body
    @type = type
    @is_header = is_header
    @width = width
  end

  def formatted_body
    case @type
    when :text
      content_tag(:div, @body, class: "text-sm text-gray-900")
    when :badge_success
      content_tag(:span, @body, class: "inline-flex px-2 py-1 text-xs rounded-full bg-green-100 text-green-800")
    when :badge_info
      content_tag(:span, @body, class: "inline-flex px-2 py-1 text-xs rounded-full bg-blue-100 text-blue-800")
    when :badge_yellow
      content_tag(:span, @body, class: "inline-flex px-2 py-1 text-xs rounded-full bg-yellow-100 text-yellow-800")
    when :date
      content_tag(:span, @body, class: "text-sm text-gray-500")
    else
      @body
    end
  end

  def wrapper_class
    case @type
    when :date
      "text-sm text-gray-500"
    else
      ""
    end
  end
end
