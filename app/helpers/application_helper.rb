module ApplicationHelper
  def breadcrumbs
    crumbs = []
    crumbs << link_to("Home", root_path)

    case controller_name
    when "products"
      if action_name == "show" && @product.present?
        @product.categories.each do |cat|
          crumbs << link_to(cat.name, category_path(cat))
        end
        crumbs << @product.name

      elsif action_name == "index" && @category.present?
        crumbs << @category.name
      end

    when "categories"
      if action_name == "show" && @category.present?
        crumbs << @category.name
      end

    when "pages"
      if action_name == "show" && @page.present?
        crumbs << @page.title
      end
    end

    crumbs.map.with_index do |crumb, i|
      if i == crumbs.size - 1
        content_tag(:li, crumb, class: "breadcrumb-item active", "aria-current": "page")
      else
        content_tag(:li, crumb, class: "breadcrumb-item")
      end
    end.join.html_safe
  end
end
