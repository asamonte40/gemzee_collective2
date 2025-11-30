ActiveAdmin.register User do
  permit_params :email, :name, :admin, :address, :city, :postal_code, :province_id

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :province
    column :admin
    column "Orders Count" do |user|
      user.orders.count
    end
    column :created_at
    actions
  end

  filter :name
  filter :email
  filter :admin
  filter :created_at

  show do
    attributes_table do
      row :name
      row :email
      row :admin
      row :address
      row :city
      row :postal_code
      row :province
      row :created_at
    end

    panel "Orders" do
      table_for user.orders.order(created_at: :desc) do
        column "Order ID" do |order|
          link_to "##{order.id}", admin_order_path(order)
        end
        column :status
        column :total_price do |order|
          number_to_currency(order.total_price)
        end
        column :created_at
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :admin
      f.input :address
      f.input :city
      f.input :postal_code
      f.input :province
    end
    f.actions
  end
end
