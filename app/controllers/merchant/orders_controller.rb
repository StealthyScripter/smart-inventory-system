module Merchant
  class OrdersController < BaseController
    before_action -> { require_merchant_permission(:view_orders) }, only: [:index]
    before_action -> { require_merchant_permission(:fulfill_orders) }, only: [:update]

    def index
      @order_items = merchant_order_items.order(created_at: :desc)
    end

    def update
      order_item = merchant_order_items.find(params[:id])
      order_item.assign_attributes(tracking_params)
      FulfillmentService.new(order_item, actor: current_user).transition_to!(params[:fulfillment_status])

      redirect_to merchant_orders_path, notice: "Order item was updated."
    rescue ArgumentError, ActiveRecord::RecordInvalid
      redirect_to merchant_orders_path, alert: "Order item could not be updated."
    end

    private

    def merchant_order_items
      supplier_items = OrderItem.where(supplier: merchant_suppliers)
      scoped_items =
        if current_merchant_account
          OrderItem.where(account: current_merchant_account).or(supplier_items)
        else
          supplier_items
        end

      scoped_items.includes(:order, :product, :supplier)
    end

    def tracking_params
      params.permit(:tracking_carrier, :tracking_number, :merchant_notes)
    end
  end
end
