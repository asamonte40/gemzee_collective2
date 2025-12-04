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
        "LOWER(products.name) LIKE :search OR LOWER(products.description) LIKE :search",
        search: keyword
      )
    end

    # Filter by single category (many-to-many)
    if @category_id.present? && @category_id != ""
      @products = @products.joins(:categories)
                           .where(categories: { id: @category_id })
                           .distinct
    end

    # Paginate results
    @products = @products.page(params[:page]).per(12)

    # Get all categories for dropdown
    @categories = Category.order(:name)
  end
end
