ActiveAdmin.register Order do
  permit_params :status

  config.sort_order = "id_desc"

  # list all orders with details
  index do
    selectable_column
    id_column
    column "Customer" do |order|
      link_to order.user.name, admin_user_path(order.user)
    end
    column :status
    column :subtotal do |order|
      number_to_currency(order.subtotal)
    end
    column "GST" do |order|
      number_to_currency(order.gst_amount)
    end
    column "PST" do |order|
      number_to_currency(order.pst_amount)
    end
    column "HST" do |order|
      number_to_currency(order.hst_amount)
    end
    column :total_price do |order|
      number_to_currency(order.total_price)
    end
    column :created_at
    actions
  end

  filter :user
  filter :status, as: :select, collection: [ "new", "paid", "shipped" ]
  filter :created_at

  show do
    attributes_table do
      row "Customer" do |order|
        link_to order.user.name, admin_user_path(order.user)
      end
      row :status
      row :shipping_address
      row :shipping_city
      row :shipping_postal_code
      row "Province" do |order|
        "#{order.shipping_province_name} (#{order.shipping_province_code})"
      end
      row :subtotal do |order|
        number_to_currency(order.subtotal)
      end
      row "GST" do |order|
        "#{number_to_currency(order.gst_amount)} (#{order.gst_rate}%)"
      end
      row "PST" do |order|
        "#{number_to_currency(order.pst_amount)} (#{order.pst_rate}%)"
      end
      row "HST" do |order|
        "#{number_to_currency(order.hst_amount)} (#{order.hst_rate}%)"
      end
      row :total_price do |order|
        number_to_currency(order.total_price)
      end
      row :stripe_payment_id
      row :paid_at
      row :created_at
    end

    # show order items
    panel "Order Items" do
      table_for order.order_items do
        column "Product" do |item|
          item.product_name
        end
        column "Price at Purchase" do |item|
          number_to_currency(item.price_at_purchase)
        end
        column :quantity
        column "Subtotal" do |item|
          number_to_currency(item.line_total)
        end
      end
    end

    # actions to change status
    panel "Actions" do
      if order.status == "paid"
        button_to "Mark as Shipped", mark_shipped_admin_order_path(order),
                  method: :put, class: "button"
      end
    end
  end

  # manual status change action
  member_action :mark_shipped, method: :put do
    order = Order.find(params[:id])
    order.mark_as_shipped!
    redirect_to admin_order_path(order), notice: "Order marked as shipped"
  end

  form do |f|
    f.inputs do
      f.input :status, as: :select, collection: [ "new", "paid", "shipped" ]
    end
    f.actions
  end
end
