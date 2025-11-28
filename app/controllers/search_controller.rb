class SearchController < ApplicationController
  def index
    @keyword = params[:keyword]
    @category_id = params[:category_id]

    # Start with all products
    @products = Product.all

    # Filter by keyword
    if @keyword.present?
      keyword = "%#{@keyword.downcase}%"

      @products = @products.where(
        "LOWER(name) LIKE :search OR LOWER(description) LIKE :search",
        search: keyword
      )
    end

    # Filter by category (only if selected)
    if @category_id.present? && @category_id != ""
      @products = @products.where(category_id: @category_id)
    end

    # Paginate results
    @products = @products.page(params[:page]).per(12)

    # For category dropdown list
    @categories = Category.all
  end
end
