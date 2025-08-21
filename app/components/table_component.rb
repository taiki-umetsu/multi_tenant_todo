class TableComponent < ViewComponent::Base
  def initialize(headers:, rows:, empty_message: "データがありません")
    @headers = headers
    @rows = rows
    @empty_message = empty_message
  end

  def any_rows?
    @rows.any?
  end

  def cell_content(cell)
    case cell[:type]
    when :text
      content_tag(:div, cell[:content], class: "text-sm text-gray-900")
    when :badge_success
      content_tag(:span, cell[:content], class: "inline-flex px-2 py-1 text-xs rounded-full bg-green-100 text-green-800")
    when :badge_info
      content_tag(:span, cell[:content], class: "inline-flex px-2 py-1 text-xs rounded-full bg-blue-100 text-blue-800")
    when :badge_yellow
      content_tag(:span, cell[:content], class: "inline-flex px-2 py-1 text-xs rounded-full bg-yellow-100 text-yellow-800")
    when :date
      content_tag(:span, cell[:content], class: "text-sm text-gray-500")
    when :custom
      cell[:content]
    else
      cell[:content]
    end
  end

  def cell_classes(cell)
    case cell[:type]
    when :date
      "text-sm text-gray-500"
    else
      cell[:class] || ""
    end
  end
end
