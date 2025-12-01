ActiveAdmin.register Page do
  permit_params :title, :slug, :content

    form do |f|
      f.inputs "Page Details" do
        f.input :title
        f.input :slug, hint: "Auto-generated from title if left blank"
        f.input :content, as: :text, input_html: { rows: 10 }
      f.actions
    end
  end
end
