ActiveAdmin.register Province do
  permit_params :name, :code, :gst, :pst, :hst

  index do
    selectable_column
    id_column
    column :name
    column :code
    column :gst do |province|
      "#{province.gst}%"
    end
    column :pst do |province|
      "#{province.pst}%"
    end
    column :hst do |province|
      "#{province.hst}%"
    end
    column "Total Tax" do |province|
      "#{province.total_tax_rate}%"
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :code, hint: "2-letter province code"
      f.input :gst, label: "GST (%)", hint: "Enter as number (e.g., 5 for 5%)"
      f.input :pst, label: "PST (%)", hint: "Enter as number (e.g., 7 for 7%)"
      f.input :hst, label: "HST (%)", hint: "Enter as number (e.g., 13 for 13%)"
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :code
      row :gst do |province|
        "#{province.gst}%"
      end
      row :pst do |province|
        "#{province.pst}%"
      end
      row :hst do |province|
        "#{province.hst}%"
      end
      row "Total Tax Rate" do |province|
        "#{province.total_tax_rate}%"
      end
    end
  end
end
