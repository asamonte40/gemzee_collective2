class AddNameRolePhoneToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role, :string unless column_exists?(:users, :role)
    add_column :users, :phone_number, :string unless column_exists?(:users, :phone_number)
    # add_column :users, :phone_number, :string
  end
end
