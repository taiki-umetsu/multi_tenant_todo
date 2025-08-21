class TableHeaderComponent < ViewComponent::Base
  renders_many :cells, "TableCellComponent"
end
