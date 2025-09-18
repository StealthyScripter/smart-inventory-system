class SuppliersController < ApplicationController
  def index
    @suppliers = Supplier.includes(:purchase_orders).order(:name)
  end

  def show
    @supplier = Supplier.find(params[:id])
  end
end
