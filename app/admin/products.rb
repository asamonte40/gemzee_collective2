ActiveAdmin.register Product do
  # Permit parameters for create/update
  permit_params :name, :description, :price, :stock_quantity, :category_id, :image

  # Filters (Ransack-friendly)
  filter :name
  filter :price
  filter :category, as: :select, collection: Category.all
  # ❌ Do NOT filter on :image

  # Index page
  index do
    selectable_column
    id_column
    column :name
    column :price
    column :stock_quantity
    column :category
    column "Image" do |product|
      if product.image.attached?
        image_tag url_for(product.image), size: "100x100"
      else
        status_tag "No Image"
      end
    end
    actions
  end

  # Show page (kept as you requested)
  show do
    attributes_table do
      row :name
      row :description
      row :price
      row :stock_quantity
      row :category
      row "Image" do |product|
        if product.image.attached?
          image_tag url_for(product.image)
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
    f.inputs do
      f.input :name
      f.input :description
      f.input :price
      f.input :stock_quantity
      f.input :category
      f.input :image, as: :file,
              hint: f.object.image.attached? ? image_tag(url_for(f.object.image), size: "100x100") : content_tag(:span, "No image yet")
    end
    f.actions
  end
end
