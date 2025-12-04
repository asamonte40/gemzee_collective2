class AddCategoryIdToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :category_id, :integer
  end
end
