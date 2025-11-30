class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_cart, :cart_count

  def current_cart
    session[:cart] ||= {}
  end

  def cart_count
    current_cart.values.sum
  end
end
