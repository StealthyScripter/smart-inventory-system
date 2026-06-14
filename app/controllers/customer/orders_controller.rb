module Customer
  class OrdersController < BaseController
    def index
      @orders = current_user.orders.includes(order_items: [:product, :supplier]).order(created_at: :desc)
    end

    def show
      @order = current_user.orders.includes(order_items: [:product, :supplier]).find(params[:id])
    end
  end
end
