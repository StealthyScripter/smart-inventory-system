class PurchaseOrdersController < ApplicationController
  def index
    @purchase_orders = current_user.purchase_orders.includes(:supplier, :user)
      .order(created_at: :desc)
  end

  def show
    @purchase_order = current_user.purchase_orders.find(params[:id])
  end
end
