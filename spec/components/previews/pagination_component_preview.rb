class PaginationComponentPreview < ViewComponent::Preview
  # @!group 基本的な表示

  # @!group ページネーション表示パターン

  # 複数ページがある場合
  def with_multiple_pages
    collection = create_mock_collection(total_pages: 5, current_page: 3, total_count: 50)
    render(PaginationComponent.new(collection: collection))
  end

  # 1ページ目の表示
  def first_page
    collection = create_mock_collection(total_pages: 3, current_page: 1, total_count: 30)
    render(PaginationComponent.new(collection: collection))
  end

  # 最後のページの表示
  def last_page
    collection = create_mock_collection(total_pages: 3, current_page: 3, total_count: 30)
    render(PaginationComponent.new(collection: collection))
  end

  # 1ページのみの場合（ページネーション非表示）
  def single_page
    collection = create_mock_collection(total_pages: 1, current_page: 1, total_count: 5)
    render(PaginationComponent.new(collection: collection))
  end

  private

  def create_mock_collection(total_pages:, current_page:, total_count:)
    OpenStruct.new(
      total_pages: total_pages,
      current_page: current_page,
      total_count: total_count,
      offset_value: (current_page - 1) * 10,
      limit_value: 10,
      prev_page: current_page > 1 ? current_page - 1 : nil,
      next_page: current_page < total_pages ? current_page + 1 : nil
    ).tap do |collection|
      # Kaminariのpaginateメソッドをモック
      def collection.to_s
        ""
      end
    end
  end
end