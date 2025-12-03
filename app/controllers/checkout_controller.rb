class CheckoutController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_cart_not_empty
  before_action :calculate_totals


  # SHOW action
  def show
    @user = current_user
    @cart_items = build_cart_items
    @order = Order.new
  end

  def create
    # --- Update user address if using a new address ---
    if params[:use_saved_address] == "0"
      current_user.update(
        name: params[:name],
        address: params[:address],
        city: params[:city],
        province_id: params[:province_id],
        postal_code: params[:postal_code],
        phone_number: params[:phone_number]
      )

      # Update tax rates in session
      province = Province.find(params[:province_id])
      session[:province_id] = province.id
      session[:province_gst] = province.gst
      session[:province_pst] = province.pst
      session[:province_hst] = province.hst
    end

    calculate_totals

    # --- Build Stripe line items from cart ---
    stripe_line_items = @cart_items.map do |item|
      {
        price_data: {
          currency: "cad",
          product_data: { name: item[:product].name },
          unit_amount: (item[:price] * 100).to_i
        },
        quantity: item[:quantity]
      }
    end

    # --- Create Stripe checkout session ---
    checkout_session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      line_items: stripe_line_items,
      mode: "payment",
      success_url: checkout_success_url, # redirect after successful payment
      cancel_url: cart_url                # redirect if user cancels
    )

    # --- Redirect to Stripe checkout page ---
    redirect_to checkout_session.url, allow_other_host: true
  end

  def success
    # Clear the cart
    session[:cart] = []

    # Flash message
    flash[:notice] = "Payment successful! Thank you for your order."

    # Redirect to products or orders page
    redirect_to products_path
  end

  private

  def ensure_cart_not_empty
    if session[:cart].blank?
      flash[:alert] = "Your cart is empty"
      redirect_to products_path
    end
  end

  def build_cart_items
    session[:cart].map do |item|
      product = Product.find_by(id: item["product_id"])
      next unless product

      {
        product: product,
        quantity: item["quantity"],
        price: item["price"]
      }
    end.compact
  end

  def calculate_totals
    @cart_items = build_cart_items
    @subtotal = @cart_items.sum { |item| item[:price] * item[:quantity] }

    # Tax rates from session
    gst_rate = (session[:province_gst] || 0).to_f / 100
    pst_rate = (session[:province_pst] || 0).to_f / 100
    hst_rate = (session[:province_hst] || 0).to_f / 100

    @gst = (@subtotal * gst_rate).round(2)
    @pst = (@subtotal * pst_rate).round(2)
    @hst = (@subtotal * hst_rate).round(2)
    @total = (@subtotal + @gst + @pst + @hst).round(2)

    # Store in session for Stripe
    session[:cart_subtotal] = @subtotal
    session[:cart_total] = @total
  end
end
