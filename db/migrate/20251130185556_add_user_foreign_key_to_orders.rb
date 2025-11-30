class AddUserForeignKeyToOrders < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :orders, :users
  end
end
