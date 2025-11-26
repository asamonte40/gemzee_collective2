ActiveAdmin.register Product do
  permit_params :name, :description, :price, :category_id, images: []

  form do |f|
    f.inputs "Product Details" do
      f.input :name
      f.input :description
      f.input :price
      f.input :category
      f.input :images, as: :file, input_html: { multiple: true }
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :description
      row :price
      row :category

      row :images do |product|
        ul do
          product.images.each do |img|
            li do
              image_tag url_for(img), size: "100x100"
            end
          end
        end
      end
    end
  end
end
