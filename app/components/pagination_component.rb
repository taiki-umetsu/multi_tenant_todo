class PaginationComponent < ViewComponent::Base
  def initialize(collection:, controller: nil, action: nil, exclude_params: [])
    @collection = collection
    @controller = controller
    @action = action
    @exclude_params = exclude_params
  end

  def before_render
    Rails.logger.debug "PaginationComponent variant: #{request.variant.inspect}"
  end

  private

  def show_pagination?
    @collection.respond_to?(:total_pages) && @collection.total_pages > 1
  end

  def pagination_params
    params = {}

    if @controller && @action
      params[:controller] = @controller
      params[:action] = @action
    end

    @exclude_params.each do |param|
      params[param] = nil
    end

    params
  end
end
