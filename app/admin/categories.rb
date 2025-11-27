ActiveAdmin.register Category do
  permit_params :name

  # Filters
  filter :name
  # Optional: filter by associated products' names
  filter :products, as: :select, collection: -> { Product.all.pluck(:name, :id) }
end
