class SuppliersController < ApplicationController
  before_action :set_supplier, only: [ :show, :edit, :update, :destroy ]

  def index
    @suppliers = Supplier.includes(:purchase_orders).order(:name)
  end

  def show
  end

  def new
    @supplier = Supplier.new
  end

  def create
    @supplier = Supplier.new(supplier_params)

    if @supplier.save
      redirect_to @supplier, notice: "Supplier was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @supplier.update(supplier_params)
      redirect_to @supplier, notice: "Supplier was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @supplier.products.any?
      redirect_to @supplier, alert: "Cannot delete supplier with associated products. Please reassign products first."
    else
      @supplier.destroy
      redirect_to suppliers_url, notice: "Supplier was successfully deleted."
    end
  end

  private

  def set_supplier
    @supplier = Supplier.find(params[:id])
  end

  def supplier_params
    params.require(:supplier).permit(:name, :contact_email, :contact_phone,
    :address, :default_lead_time_days)
  end
end
