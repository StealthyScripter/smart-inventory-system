module Merchant
  class OrdersController < BaseController
    def index
      @order_items = merchant_order_items.order(created_at: :desc)
    end

    def update
      order_item = merchant_order_items.find(params[:id])
      FulfillmentService.new(order_item, actor: current_user).transition_to!(params[:fulfillment_status])

      redirect_to merchant_orders_path, notice: "Order item was updated."
    rescue ArgumentError, ActiveRecord::RecordInvalid
      redirect_to merchant_orders_path, alert: "Order item could not be updated."
    end

    private

    def merchant_order_items
      OrderItem.includes(:order, :product, :supplier)
               .where(supplier: merchant_suppliers)
    end
  end
end
