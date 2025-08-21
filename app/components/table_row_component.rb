class TableRowComponent < ViewComponent::Base
  renders_many :cells, "TableCellComponent"
end
