class PaymentsController < ApplicationController
  before_action :authenticate_user!

  def show
    @order = Order.find(params[:id])
    authorize_order!
  end

  def create
    @order = Order.find(params[:id])
    authorize_order!

    begin
      # Create Stripe payment (requires Stripe gem and config)
      payment_intent = Stripe::PaymentIntent.create({
        amount: (@order.total_price * 100).to_i,
        currency: "cad",
        payment_method: params[:payment_method_id],
        confirm: true,
        description: "Order ##{@order.id}"
      })

      stripe_customer = Stripe::Customer.create({
        email: current_user.email,
        name: current_user.name
      })

      # 3.2.2 - Mark as paid
      @order.mark_as_paid!(payment_intent.id, stripe_customer.id)

      # Clear cart
      session[:cart] = {}

      redirect_to order_path(@order), notice: "Payment successful!"

    rescue Stripe::CardError => e
      redirect_to payment_path(@order), alert: "Payment failed: #{e.message}"
    end
  end

  private

  def authorize_order!
    unless @order.user_id == current_user.id
      redirect_to root_path, alert: "Unauthorized"
    end
  end
end
