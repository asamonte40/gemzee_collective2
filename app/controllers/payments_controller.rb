# class PaymentsController < ApplicationController
#    before_action :authenticate_user!

#   # POST /payments/create_checkout_session
#   def create_checkout_session
#     cart = session[:cart] || []

#     if cart.empty?
#       flash[:alert] = "Your cart is empty"
#       redirect_to cart_path and return
#     end

#     total_amount = session[:cart_total] || 0
#     @amount_in_cents = (total_amount * 100).to_i

#     begin
#       checkout_session = Stripe::Checkout::Session.create(
#         payment_method_types: [ "card" ],
#         line_items: build_line_items(cart),
#         mode: "payment",
#         success_url: "#{root_url}payments/success?session_id={CHECKOUT_SESSION_ID}",
#         cancel_url: "#{root_url}payments/cancel",
#         customer_email: current_user.email,
#         metadata: {
#           customer_id: current_user.id,
#           order_data: session[:order_data].to_json
#         }
#       )

#       Rails.logger.info "Stripe Checkout Session created: #{checkout_session.id}"
#       redirect_to checkout_session.url, allow_other_host: true

#     rescue Stripe::StripeError => e
#       Rails.logger.error "Stripe error: #{e.message}"
#       flash[:alert] = "Payment processing error. Please try again."
#       redirect_to checkout_path
#     end
#   end

#   # GET /payments/success
#   def success
#     session_id = params[:session_id]

#     unless session_id
#       flash[:alert] = "Invalid payment session"
#       redirect_to root_path and return
#     end

#     begin
#       checkout_session = Stripe::Checkout::Session.retrieve(session_id)
#       payment_intent_id = checkout_session.payment_intent
#       order_data = session[:order_data]

#       # Create the Order record
#       order = Order.create!(
#         user_id: current_user.id,
#         stripe_payment_id: payment_intent_id,
#         stripe_session_id: session_id,
#         subtotal: order_data["subtotal"],
#         gst: order_data["gst"],
#         pst: order_data["pst"],
#         hst: order_data["hst"],
#         total: order_data["total"],
#         status: "paid",
#         shipping_address: order_data["shipping_address"],
#         shipping_city: order_data["shipping_city"],
#         shipping_province: order_data["shipping_province"],
#         shipping_postal_code: order_data["shipping_postal_code"]
#       )

#       # Create OrderItems
#       cart = session[:cart] || []
#       cart.each do |item|
#         product = Product.find(item["product_id"])
#         OrderItem.create!(
#           order_id: order.id,
#           product_id: product.id,
#           quantity: item["quantity"],
#           price_at_purchase: item["price"],
#           subtotal: (item["price"] * item["quantity"]).round(2)
#         )
#       end

#       # Clear session
#       session[:cart] = []
#       session[:order_data] = nil
#       session[:cart_total] = nil
#       session[:cart_subtotal] = nil

#       flash[:success] = "Payment successful! Your order ##{order.id} has been placed."
#       redirect_to order_path(order)

#     rescue Stripe::StripeError => e
#       Rails.logger.error "Stripe error in success: #{e.message}"
#       flash[:alert] = "There was an error processing your order. Please contact support."
#       redirect_to root_path
#     rescue => e
#       Rails.logger.error "Error creating order: #{e.message}"
#       flash[:alert] = "There was an error saving your order. Please contact support with session ID: #{session_id}"
#       redirect_to root_path
#     end
#   end

#   # GET /payments/cancel
#   def cancel
#     flash[:warning] = "Payment was cancelled. Your cart is still saved."
#     redirect_to cart_path
#   end

#   private

#   # Build Stripe line items from session cart
#   def build_line_items(cart)
#     items = cart.map do |item|
#       product = Product.find(item["product_id"])
#       {
#         price_data: {
#           currency: "cad",
#           product_data: {
#             name: product.name,
#             description: product.description&.truncate(200)
#           },
#           unit_amount: (item["price"] * 100).to_i
#         },
#         quantity: item["quantity"]
#       }
#     end

#     # Add taxes as a separate line item if applicable
#     total_tax = (session[:cart_total].to_f - session[:cart_subtotal].to_f).round(2)
#     if total_tax > 0
#       items << {
#         price_data: {
#           currency: "cad",
#           product_data: {
#             name: "Taxes (GST/PST/HST)",
#             description: "Based on #{current_user.province&.name || 'selected province'}"
#           },
#           unit_amount: (total_tax * 100).to_i
#         },
#         quantity: 1
#       }
#     end

#     items
#   end
# end
