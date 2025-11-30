class CheckoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :initialize_cart
  before_action :load_cart_items
  before_action :load_user_and_provinces
  before_action :calculate_taxes

  def new
    puts "DEBUG: current_user=#{current_user.inspect}"
    @cart_items = get_cart_items
    puts "DEBUG: cart_items=#{@cart_items.inspect}"
    redirect_to cart_path, alert: "Your cart is empty" if @cart_items.empty?

    @user = current_user
    @provinces = Province.all

    # Calculate totals
    @province = @user.province || Province.first
    calculate_totals(@province)
  end

  def create
  @user = current_user

    # Update user address if provided
    if params[:user].present?
      unless @user.update(user_params)
        @provinces = Province.all
        @cart_items = get_cart_items
        calculate_totals(@user.province)
        render :new and return
      end
    end

    # Validate user has province
    unless @user.province.present?
      redirect_to new_checkout_path, alert: "Please provide your address" and return
    end

    # Create order with denormalized address
    @order = Order.new(
      user: @user,
      status: "new",
      shipping_address: @user.address,
      shipping_city: @user.city,
      shipping_postal_code: @user.postal_code,
      shipping_province_name: @user.province.name,
      shipping_province_code: @user.province.code
    )

    # Add order items with denormalized product data
    session[:cart].each do |product_id, quantity|
      product = Product.find(product_id)
      @order.order_items.build(
        product: product,
        quantity: quantity
        # price_at_purchase, product_name, product_description set by before_validation
      )
    end

    # Calculate totals with denormalized tax rates
    @order.calculate_totals(@user.province)

    if @order.save
      redirect_to payment_path(@order)
    else
      @provinces = Province.all
      @cart_items = get_cart_items
      calculate_totals(@user.province)
      render :new
    end
  end

  private

  def get_cart_items
    items = []
    cart = session[:cart] || {}
    cart.each do |product_id, quantity|
      product = Product.find_by(id: product_id)
      items << { product: product, quantity: quantity } if product
    end
    items
  end

  def calculate_totals(province)
    @cart_items = get_cart_items
    @subtotal = @cart_items.sum { |item| item[:product].price * item[:quantity] }

    @gst = @subtotal * (province.gst / 100)
    @pst = @subtotal * (province.pst / 100)
    @hst = @subtotal * (province.hst / 100)
    @total = @subtotal + @gst + @pst + @hst
  end

  def user_params
    params.require(:user).permit(:address, :city, :postal_code, :province_id)
  end

  def initialize_cart
    session[:cart] ||= {}
  end

  def load_cart_items
    @cart_items = get_cart_items
  end

  def load_user_and_provinces
    @user = current_user
    @provinces = Province.all
  end

  def calculate_taxes
    calculate_totals(@user.province || Province.first)
  end
end
