class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order

  def show
    @order = current_user.orders.find(params[:id])
  end

  def create
    authorize_order!

    line_items = @order.order_items.map do |item|
      {
        price_data: { currency: "cad",
                      product_data: { name: item.product_name },
                      unit_amount: (item.price_at_purchase * 100).to_i },
        quantity: item.quantity
      }
    end

    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      line_items: line_items,
      mode: "payment",
      customer_email: current_user.email,
      success_url: order_url(@order),
      cancel_url: payment_url(@order)
    )

    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    redirect_to payment_path(@order), alert: "Payment failed: #{e.message}"
  end

  private
  def set_order; @order = Order.find(params[:id]); end
  def authorize_order!; redirect_to root_path, alert: "Unauthorized" unless @order.user_id == current_user.id; end
end
