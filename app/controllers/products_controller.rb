class ProductsController < ApplicationController
  def index
    @products = Product.all
    @categories = Category.all

    # filter tags
    if params[:filter].present?
      tag_name = case params[:filter]
      when "on_sale" then "On Sale"
      when "new" then "New"
      when "recently_updated" then "Recently Updated"
      when "valentines" then "Valentines"
      when "limited" then "Limited Edition"
      end

      if tag_name
        tag = Tag.find_by(name: tag_name)
        @products = @products.joins(:tags).where(tags: { id: tag.id }) if tag
      end
    end

    # Pagination
    @products = @products.page(params[:page]).per(12)
  end

  def show
    @product = Product.find(params[:id])

    # Pick the first category associated with this product
    main_category = @product.categories.first

    if main_category
      @similar_products = main_category.products
                                      .where.not(id: @product.id)
                                      .limit(8)
    else
      @similar_products = []
    end
  end

  def on_sale
    @products = Product.joins(:tags)
                     .where(tags: { name: "On Sale" })
                     .where("price < ?", 2000)
  end
end
