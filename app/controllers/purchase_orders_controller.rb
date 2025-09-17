class PurchaseOrdersController < ApplicationController
  def index
    @purchase_orders = PurchaseOrder.includes(:supplier, :user)
      .order(created_at: :desc)
  end

  def show
    @purchase_order = PurchaseOrder.find(params[:id])
  end
end
