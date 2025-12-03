class OrdersController < ApplicationController
  before_action :authenticate_user!
  def index
    @orders = current_user.orders.includes(:order_items).order(created_at: :desc)
  end

  def show
  @order = Order.find(params[:id])
      unless @order.user_id == current_user.id
      redirect_to root_path, alert: "Unauthorized"
      end
  end

  def confirmation
    @order = current_user.orders.find(params[:id])
  end
end
