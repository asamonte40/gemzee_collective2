class ProductsController < ApplicationController
  def index
    @products = Product.all
    @categories = Category.all

    # --- Filters (2.4) ---
    if params[:filter] == "on_sale"
      @products = @products.where("sale_price < price")
    end

    if params[:filter] == "new"
      @products = @products.where("created_at >= ?", 3.days.ago)
    end

    if params[:filter] == "recently_updated"
      @products = @products.where("updated_at >= ?", 3.days.ago)
                           .where("created_at < ?", 3.days.ago) # exclude new items
    end

    # Pagination (2.5)
    @products = @products.page(params[:page]).per(12)
  end

  def show
    @product = Product.find(params[:id])
  end
end
