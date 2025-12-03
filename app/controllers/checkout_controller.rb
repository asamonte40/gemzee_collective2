class CheckoutController < ApplicationController
  before_action :authenticate_user!
  before_action :initialize_cart
  before_action :load_cart_items
  before_action :load_user_and_provinces

  # SHOW action
  def show
    redirect_to cart_path, alert: "Your cart is empty" if @cart_items.empty?

    @province = @user.province || Province.first
    calculate_totals(@province)
  end

  # CREATE action
  def create
  Rails.logger.info "========================================="
  Rails.logger.info "CHECKOUT CREATE ACTION STARTED"
  Rails.logger.info "========================================="
  Rails.logger.info "Params: #{params.inspect}"
  Rails.logger.info "Session cart: #{session[:cart].inspect}"
  Rails.logger.info "Cart items loaded: #{@cart_items.count}"

  @cart_items.each_with_index do |item, i|
    Rails.logger.info "Cart item #{i}: #{item[:product].name} - Price: #{item[:product].price} - Qty: #{item[:quantity]}"
  end

  # Update user address if using new address
  if params[:use_saved_address] == "0"
    Rails.logger.info "Using NEW address"
    @user.name = params[:name] if params[:name].present?
    @user.phone_number = params[:phone_number] if params[:phone_number].present?
    @user.address = params[:address]
    @user.city = params[:city]
    @user.province_id = params[:province_id]
    @user.postal_code = params[:postal_code]

    Rails.logger.info "Attempting to save user..."
    unless @user.save
      Rails.logger.error "USER SAVE FAILED: #{@user.errors.full_messages}"
      flash.now[:alert] = "Please correct the address errors: #{@user.errors.full_messages.join(', ')}"
      @province = @user.province || Province.first
      calculate_totals(@province)
      render :show and return
    end

    Rails.logger.info "User saved successfully"
    @user.reload
  else
    Rails.logger.info "Using SAVED address"
  end

  Rails.logger.info "User province: #{@user.province.inspect}"

  unless @user.province
    Rails.logger.error "NO PROVINCE FOUND - redirecting"
    redirect_to checkout_path, alert: "Please provide your address" and return
  end

  Rails.logger.info "Creating new order..."
  @order = Order.new(
    user: @user,
    status: "paid",
    shipping_address: @user.address,
    shipping_city: @user.city,
    shipping_postal_code: @user.postal_code,
    shipping_province_name: @user.province.name,
    shipping_province_code: @user.province.code
  )
  Rails.logger.info "Order created: #{@order.inspect}"

  Rails.logger.info "Building order items..."
@cart_items.each_with_index do |item, i|
  Rails.logger.info "Building order item #{i}: #{item[:product].name}"

  order_item = @order.order_items.build(
    product_id: item[:product].id,   # IMPORTANT FIX
    quantity: item[:quantity].to_i,
    price_at_purchase: item[:product].price.to_f,
    product_name: item[:product].name,
    product_description: item[:product].description
  )

  Rails.logger.info "Order item #{i} built: #{order_item.inspect}"
end

  Rails.logger.info "Total order items: #{@order.order_items.size}"

  Rails.logger.info "Calculating totals..."
  calculate_totals(@user.province)

  @order.subtotal = @subtotal
  @order.gst = @gst
  @order.pst = @pst
  @order.hst = @hst
  @order.total = @total

  Rails.logger.info "Order totals - Subtotal: #{@order.subtotal}, GST: #{@order.gst}, PST: #{@order.pst}, HST: #{@order.hst}, Total: #{@order.total}"

  Rails.logger.info "Validating order..."
  Rails.logger.info "Order valid? #{@order.valid?}"

  unless @order.valid?
    Rails.logger.error "ORDER INVALID!"
    Rails.logger.error "Order errors: #{@order.errors.full_messages}"
    @order.order_items.each_with_index do |item, i|
      unless item.valid?
        Rails.logger.error "Order item #{i} (#{item.product_name}) invalid: #{item.errors.full_messages}"
      end
    end
  end

  Rails.logger.info "Attempting to save order..."
  if @order.save
    Rails.logger.info "========================================="
    Rails.logger.info "SUCCESS! ORDER SAVED - ID: #{@order.id}"
    Rails.logger.info "========================================="
    session[:cart] = {}
    redirect_to confirmation_order_path(@order) and return
  else
    Rails.logger.error "========================================="
    Rails.logger.error "ORDER SAVE FAILED!"
    Rails.logger.error "Order errors: #{@order.errors.full_messages}"
    Rails.logger.error "========================================="

    @order.order_items.each_with_index do |item, i|
      unless item.valid?
        Rails.logger.error "Item #{i} errors: #{item.errors.full_messages}"
      end
    end

    flash.now[:alert] = "Unable to process order: #{@order.errors.full_messages.join(', ')}"
    @province = @user.province || Province.first
    calculate_totals(@province)
    render :show
  end
  end

  private

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

  def get_cart_items
    (session[:cart] || {}).map do |pid, qty|
      product = Product.find_by(id: pid)
      next unless product
      { product: product, quantity: qty.to_i }
    end.compact
  end

  def calculate_totals(province)
    @subtotal = @cart_items.sum { |item| item[:product].price.to_f * item[:quantity].to_i }

    gst_rate = (province&.gst.to_f || 0.0) / 100.0
    pst_rate = (province&.pst.to_f || 0.0) / 100.0
    hst_rate = (province&.hst.to_f || 0.0) / 100.0

    @gst = @subtotal * gst_rate
    @pst = @subtotal * pst_rate
    @hst = @subtotal * hst_rate

    @total = @subtotal + @gst + @pst + @hst
  end
end
