class CreateCustomizations < ActiveRecord::Migration[8.0]
  def change
    create_table :customizations do |t|
      t.references :order_item, null: false, foreign_key: true
      t.string :charm_type
      t.string :gemstone

      t.timestamps
    end
  end
end
