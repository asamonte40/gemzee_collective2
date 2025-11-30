class AddOrderFieldsForCheckout < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :subtotal, :decimal, precision: 10, scale: 2
    add_column :orders, :gst_amount, :decimal, precision: 10, scale: 2, default: 0
    add_column :orders, :pst_amount, :decimal, precision: 10, scale: 2, default: 0
    add_column :orders, :hst_amount, :decimal, precision: 10, scale: 2, default: 0

    # Denormalized tax rates
    add_column :orders, :gst_rate, :decimal, precision: 5, scale: 3, default: 0
    add_column :orders, :pst_rate, :decimal, precision: 5, scale: 3, default: 0
    add_column :orders, :hst_rate, :decimal, precision: 5, scale: 3, default: 0

    # Customer address at time of order
    add_column :orders, :shipping_address, :string
    add_column :orders, :shipping_city, :string
    add_column :orders, :shipping_postal_code, :string
    add_column :orders, :shipping_province_name, :string
    add_column :orders, :shipping_province_code, :string

    # Payment integration
    add_column :orders, :stripe_payment_id, :string
    add_column :orders, :stripe_customer_id, :string
    add_column :orders, :paid_at, :datetime

    # Denormalized product data in order_items
    add_column :order_items, :product_name, :string
    add_column :order_items, :product_description, :text
  end
end
