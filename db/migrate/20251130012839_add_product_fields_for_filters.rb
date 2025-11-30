class AddProductFieldsForFilters < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :on_sale, :boolean, default: false
    add_column :products, :is_new, :boolean, default: true
  end
end
