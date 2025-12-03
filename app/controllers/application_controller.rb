class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :initialize_session

  helper_method :current_cart, :cart_count

  def current_cart
    session[:cart] ||= {}
  end

  def cart_count
    current_cart.sum { |item| item["quantity"] }
  end


  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  private

  def initialize_session
    # Initialize cart if not exists
    session[:cart] ||= {}

    # Initialize customer data if logged in
    if user_signed_in? && current_user.province
      session[:customer_id] = current_user.id
      session[:customer_email] = current_user.email
      session[:customer_name] = current_user.name
      session[:province_id] = current_user.province_id
      session[:province_gst] = current_user.province.gst
      session[:province_pst] = current_user.province.pst
      session[:province_hst] = current_user.province.hst
    end
  end
end
