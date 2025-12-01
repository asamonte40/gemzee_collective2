class AddStripeAndPaidToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :stripe_payment_id, :string unless column_exists?(:orders, :stripe_payment_id)
    add_column :orders, :stripe_customer_id, :string unless column_exists?(:orders, :stripe_customer_id)
    add_column :orders, :paid_at, :datetime unless column_exists?(:orders, :paid_at)
  end
end
