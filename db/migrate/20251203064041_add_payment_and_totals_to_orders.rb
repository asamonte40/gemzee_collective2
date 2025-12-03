class AddPaymentAndTotalsToOrders < ActiveRecord::Migration[8.0]
  def change
    # add_column :orders, :subtotal, :decimal, precision: 10, scale: 2, default: 0.0, null: false
    add_column :orders, :gst, :decimal, precision: 10, scale: 2, default: 0.0, null: false
    add_column :orders, :pst, :decimal, precision: 10, scale: 2, default: 0.0, null: false
    add_column :orders, :hst, :decimal, precision: 10, scale: 2, default: 0.0, null: false
    add_column :orders, :total, :decimal, precision: 10, scale: 2, default: 0.0, null: false
    # add_column :orders, :stripe_payment_id, :string
    # add_column :orders, :status, :string, default: 'new', null: false
  end
end
