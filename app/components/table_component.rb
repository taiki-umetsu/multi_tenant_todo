class TableComponent < ViewComponent::Base
  renders_one :header, "TableHeaderComponent"
  renders_many :rows, "TableRowComponent"

  def initialize(empty_message: "データがありません", tbody_id: nil)
    @empty_message = empty_message
    @tbody_id = tbody_id
  end
end
