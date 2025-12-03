ActiveAdmin.register Product do
  include Rails.application.routes.url_helpers

  # Permit parameters for create/update
  permit_params :name, :description, :price, :stock_quantity, :image, category_ids: [], tag_ids: []

  # Filters
  filter :name
  filter :price
  # Correct Ransack association filter syntax:
  filter :categories_name, as: :check_boxes, collection: proc { Category.all.pluck(:name, :id) }
  filter :tags_name, as: :check_boxes, collection: proc { Tag.all.pluck(:name, :id) }


  # Index page
  index do
    selectable_column
    id_column
    column :name
    column :price
    column :stock_quantity

    column "Categories" do |product|
      product.categories.map(&:name).join(", ")
    end

    column "Tags" do |product|
      product.tags.map(&:name).join(", ")
    end

    column "Image" do |product|
      if product.image.attached?
        image_tag product.image.variant(resize_to_limit: [ 100, 100 ])
      else
        status_tag "No Image"
      end
    end
    actions
  end

  # Show page
  show do
    attributes_table do
      row :name
      row :description
      row :price
      row :stock_quantity
      row "Categories" do |product|
        product.categories.map(&:name).join(", ")
      end
      row "Tags" do |product|
        product.tags.map(&:name).join(", ")
      end
      row "Image" do |product|
        if product.image.attached?
          image_tag product.image.variant(resize_to_limit: [ 600, 600 ])
        else
          status_tag "No Image"
        end
      end
    end
    active_admin_comments
  end

  # Form for new/edit
  form do |f|
    f.semantic_errors
    f.inputs "Product Details" do
      f.input :name
      f.input :description
      f.input :price
      f.input :stock_quantity
      f.input :categories, as: :check_boxes, collection: Category.all
      f.input :tags, as: :check_boxes, collection: Tag.all
      f.input :image, as: :file,
              hint: f.object.image.attached? ? image_tag(f.object.image.variant(resize_to_limit: [ 100, 100 ])) : content_tag(:span, "No image yet")
    end
    f.actions
  end
end
