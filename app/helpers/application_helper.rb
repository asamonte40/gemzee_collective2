module ApplicationHelper
  def breadcrumbs
    crumbs = []

    # Always start with Home
    crumbs << link_to("Home", root_path)

    case controller_name
    when "products"
      if action_name == "show" && @product.present?
        # Add category
        crumbs << link_to(@product.category.name, category_path(@product.category))
        # Current product (active)
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

    # Convert to HTML list items
    crumbs.map.with_index do |crumb, i|
      if i == crumbs.size - 1
        # Active breadcrumb (current page)
        content_tag(:li, crumb, class: "breadcrumb-item active", "aria-current": "page")
      else
        content_tag(:li, crumb, class: "breadcrumb-item")
      end
    end.join.html_safe
  end
end
