class ConvertStatusToIntegerInOrders < ActiveRecord::Migration[8.0]
  def up
    # Add new integer column
    add_column :orders, :status_tmp, :integer, default: 0, null: false

    # Map old string statuses to integers
    execute <<-SQL
      UPDATE orders
      SET status_tmp = CASE status
        WHEN 'pending' THEN 0
        WHEN 'paid' THEN 1
        WHEN 'shipped' THEN 2
        WHEN 'delivered' THEN 3
        WHEN 'cancelled' THEN 4
        ELSE 0
      END;
    SQL

    # Remove old string column
    remove_column :orders, :status

    # Rename new column
    rename_column :orders, :status_tmp, :status
  end

  def down
    add_column :orders, :status_tmp, :varchar
    execute <<-SQL
      UPDATE orders
      SET status_tmp = CASE status
        WHEN 0 THEN 'pending'
        WHEN 1 THEN 'paid'
        WHEN 2 THEN 'shipped'
        WHEN 3 THEN 'delivered'
        WHEN 4 THEN 'cancelled'
        ELSE 'pending'
      END;
    SQL

    remove_column :orders, :status
    rename_column :orders, :status_tmp, :status
  end
end
