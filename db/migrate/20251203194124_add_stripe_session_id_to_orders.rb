class AddStripeSessionIdToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :stripe_session_id, :string unless column_exists?(:orders, :stripe_session_id)
    add_index :orders, :stripe_session_id, unique: true
  end
end
