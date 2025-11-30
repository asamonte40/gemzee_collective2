class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_cart, :cart_count

  def current_cart
    session[:cart] ||= {}
  end

  def cart_count
    current_cart.values.sum
  end

   protected

  # this tells Devise to accept :name when signing up / updating
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end
end
