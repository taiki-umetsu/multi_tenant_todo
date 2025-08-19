class TableComponentPreview < ViewComponent::Preview
  def with_data
    headers = [
      { label: "名前", width: "w-1/2" },
      { label: "メール", width: "w-1/4" },
      { label: "日付", width: "w-1/4" }
    ]

    rows = [
      [
        { content: "太郎", type: :text },
        { content: "taro@example.com", type: :text },
        { content: "2024-01-01", type: :date }
      ],
      [
        { content: "花子", type: :text },
        { content: "hanako@example.com", type: :text },
        { content: "2024-01-02", type: :date }
      ]
    ]

    render TableComponent.new(headers: headers, rows: rows)
  end

  def empty_state
    headers = [
      { label: "名前", width: "w-1/2" },
      { label: "メール", width: "w-1/4" },
      { label: "日付", width: "w-1/4" }
    ]

    render TableComponent.new(headers: headers, rows: [])
  end

  def with_badges
    headers = [
      { label: "ユーザー", width: "w-1/3" },
      { label: "権限", width: "w-1/3" },
      { label: "状態", width: "w-1/3" }
    ]

    rows = [
      [
        { content: "管理者ユーザー", type: :text },
        { content: "管理者", type: :badge_success },
        { content: "アクティブ", type: :badge_success }
      ],
      [
        { content: "一般ユーザー", type: :text },
        { content: "メンバー", type: :badge_info },
        { content: "アクティブ", type: :badge_success }
      ]
    ]

    render TableComponent.new(headers: headers, rows: rows)
  end

  def custom_empty_message
    headers = [
      { label: "ユーザー", width: "w-1/3" },
      { label: "権限", width: "w-1/3" },
      { label: "状態", width: "w-1/3" }
    ]

    render TableComponent.new(
      headers: headers,
      rows: [],
      empty_message: "ユーザーが見つかりません"
    )
  end
end
