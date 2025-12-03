class CreateProductsTags < ActiveRecord::Migration[8.0]
  def change
    create_table :products_tags do |t|
      t.references :product, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
