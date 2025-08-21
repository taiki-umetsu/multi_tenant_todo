class TableComponentPreview < ViewComponent::Preview
  def with_data
    render TableComponent.new do |table|
      table.with_header do |header|
        header.with_cell(body: "名前", is_header: true, width: "w-1/2")
        header.with_cell(body: "メール", is_header: true, width: "w-1/4")
        header.with_cell(body: "日付", is_header: true, width: "w-1/4")
      end
      table.with_row do |row|
        row.with_cell(body: "太郎", type: :text)
        row.with_cell(body: "taro@example.com", type: :text)
        row.with_cell(body: "2024-01-01", type: :date)
      end
      table.with_row do |row|
        row.with_cell(body: "花子", type: :text)
        row.with_cell(body: "hanako@example.com", type: :text)
        row.with_cell(body: "2024-01-02", type: :date)
      end
    end
  end

  def empty_state
    render TableComponent.new do |table|
      table.with_header do |header|
        header.with_cell(body: "名前", is_header: true, width: "w-1/2")
        header.with_cell(body: "メール", is_header: true, width: "w-1/4")
        header.with_cell(body: "日付", is_header: true, width: "w-1/4")
      end
    end
  end

  def with_badges
    render TableComponent.new do |table|
      table.with_header do |header|
        header.with_cell(body: "ユーザー", is_header: true, width: "w-1/3")
        header.with_cell(body: "権限", is_header: true, width: "w-1/3")
        header.with_cell(body: "状態", is_header: true, width: "w-1/3")
      end
      table.with_row do |row|
        row.with_cell(body: "管理者ユーザー", type: :text)
        row.with_cell(body: "管理者", type: :badge_success)
        row.with_cell(body: "アクティブ", type: :badge_success)
      end
      table.with_row do |row|
        row.with_cell(body: "一般ユーザー", type: :text)
        row.with_cell(body: "メンバー", type: :badge_info)
        row.with_cell(body: "アクティブ", type: :badge_success)
      end
    end
  end

  def custom_empty_message
    render TableComponent.new(empty_message: "ユーザーが見つかりません") do |table|
      table.with_header do |header|
        header.with_cell(body: "ユーザー", is_header: true, width: "w-1/3")
        header.with_cell(body: "権限", is_header: true, width: "w-1/3")
        header.with_cell(body: "状態", is_header: true, width: "w-1/3")
      end
    end
  end
end
