class CartController < ApplicationController
  before_action :initialize_cart

  def show
    @cart_items = build_cart_items
    @subtotal = @cart_items.sum { |item| item[:price] * item[:quantity] }
  end

  def add
    product = Product.find(params[:id])
    quantity = params[:quantity].to_i
    quantity = 1 if quantity < 1

    # Find existing item in cart
    cart_item = @cart.find { |item| item["product_id"] == product.id }
    if cart_item
      cart_item["quantity"] += quantity
    else
      @cart << {
        "product_id" => product.id,
        "quantity" => quantity,
        "price" => product.price.to_f
      }
    end

    session[:cart] = @cart
    redirect_to cart_path, notice: "#{product.name} added to cart"
  end

  def update
    product_id = params[:id].to_i
    quantity = params[:quantity].to_i

    cart_item = @cart.find { |item| item["product_id"] == product_id }
    if cart_item
      if quantity > 0
        cart_item["quantity"] = quantity
      else
        @cart.delete(cart_item)
      end
    end

    session[:cart] = @cart
    redirect_to cart_path, notice: "Cart updated"
  end

  def remove
    product_id = params[:id].to_i
    @cart.reject! { |item| item["product_id"] == product_id }
    session[:cart] = @cart
    redirect_to cart_path, notice: "Item removed from cart"
  end

  def clear
    session[:cart] = []
    @cart = []
    redirect_to cart_path, notice: "Cart cleared"
  end

  private

  def initialize_cart
    session[:cart] ||= []

    # Convert old hash format (if any) to array of hashes
    if session[:cart].is_a?(Hash)
      session[:cart] = session[:cart].map do |product_id, quantity|
        product = Product.find_by(id: product_id.to_i)
        next unless product
        {
          "product_id" => product.id,
          "quantity" => quantity,
          "price" => product.price.to_f
        }
      end.compact
    end

    @cart = session[:cart]
  end

  def build_cart_items
    @cart.map do |item|
      product = Product.find_by(id: item["product_id"])
      next unless product

      {
        product: product,
        quantity: item["quantity"],
        price: item["price"],
        subtotal: (item["price"] * item["quantity"]).round(2)
      }
    end.compact
  end
end
