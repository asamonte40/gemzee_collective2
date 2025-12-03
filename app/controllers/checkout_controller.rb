class CheckoutController < ApplicationController
  before_action :authenticate_user!
  before_action :initialize_cart
  before_action :load_cart_items
  before_action :load_user_and_provinces

  def new
    redirect_to cart_path, alert: "Your cart is empty" if @cart_items.empty?
    @province = @user.province || Province.first
    calculate_totals(@province)
    @order = @user.orders.build(
      status: "new",
      total_price: @total,
      shipping_address: @user.address,
      shipping_city: @user.city,
      shipping_postal_code: @user.postal_code,
      shipping_province_name: @user.province&.name,
      shipping_province_code: @user.province&.code
    )
  end

  def create
    # Update address if provided
    if params[:user].present? && !@user.update(user_params)
      set_defaults_for_render
      render :new and return
    end

    # Ensure province
    unless @user.province
      redirect_to new_checkout_path, alert: "Please provide your address" and return
    end

    # Create order
    @order = Order.new(user: @user, status: "new",
      shipping_address: @user.address,
      shipping_city: @user.city,
      shipping_postal_code: @user.postal_code,
      shipping_province_name: @user.province.name,
      shipping_province_code: @user.province.code)

    session[:cart].each do |product_id, quantity|
      product = Product.find_by(id: product_id)
      next unless product
      @order.order_items.build(
        product: product, quantity: quantity.to_i,
        price_at_purchase: product.price, product_name: product.name,
        product_description: product.description
      )
    end

    @order.calculate_totals(@user.province)
    if @order.order_items.all?(&:valid?) && @order.save
      redirect_to payment_path(@order.id)
    else
      set_defaults_for_render
      render :new
    end
  end

  def create_payment_intent
    @order = Order.find(params[:order_id])
    intent = Stripe::PaymentIntent.create(
      amount: (@order.total_price * 100).to_i, # cents
      currency: "cad",
      metadata: { order_id: @order.id }
    )
    render json: { client_secret: intent.client_secret }
  end

  # Success page after payment
  def success
    session[:cart] = {}
    @order = current_user.orders.last
  end

  private
  def user_params
    params.require(:user).permit(:address, :city, :postal_code, :province_id)
  end

  def initialize_cart; session[:cart] ||= {}; end
  def load_cart_items; @cart_items = get_cart_items; end
  def load_user_and_provinces; @user = current_user; @provinces = Province.all; end

  def get_cart_items
    (session[:cart] || {}).map do |pid, qty|
      product = Product.find_by(id: pid)
      next unless product
      { product: product, quantity: qty }
    end.compact
  end

  def calculate_totals(province)
    @subtotal = @cart_items.sum { |item| item[:product]&.price.to_f * item[:quantity].to_i }
    @gst = @subtotal * (province.gst/100.0)
    @pst = @subtotal * (province.pst/100.0)
    @hst = @subtotal * (province.hst/100.0)
    @total = @subtotal + @gst + @pst + @hst
  end
  def set_defaults_for_render
    @provinces = Province.all
    @cart_items = get_cart_items
    @province = @user.province || Province.first
    calculate_totals(@province)
  end
end
