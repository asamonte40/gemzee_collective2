class CartController < ApplicationController
  before_action :initialize_cart
  def show
    @cart_items = []
    @cart.each do |product_id, quantity|
      product = Product.find_by(id: product_id)
      @cart_items << { product: product, quantity: quantity } if product
    end

    @subtotal = @cart_items.sum { |item| item[:product].price * item[:quantity] }
  end

  def add
    product = Product.find(params[:id])

    if @cart[product.id.to_s]
      @cart[product.id.to_s] += 1
    else
      @cart[product.id.to_s] = 1
    end
    session[:cart] = @cart
    redirect_to cart_path, notice: "#{product.name} added to cart"
  end

  def update
    product_id = params[:id]
    quantity = params[:quantity].to_i

    if quantity > 0
      @cart[product_id] = quantity
    else
      @cart.delete(product_id)
    end

    session[:cart] = @cart
    redirect_to cart_path, notice: "Cart updated"
  end

  def remove
    @cart.delete(params[:id])
    session[:cart] = @cart
    redirect_to cart_path, notice: "Item removed from cart"
  end

  def clear
    session[:cart] = {}
    redirect_to cart_path, notice: "Cart cleared"
  end

  private

  def initialize_cart
    session[:cart] ||= {}  # creates the empty cart if none exists
    @cart = session[:cart] # loads it into @cart
  end
end
