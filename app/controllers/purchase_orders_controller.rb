class PurchaseOrdersController < ApplicationController
  before_action :set_purchase_order, only: [:show, :edit, :update, :destroy, :mark_as_sent, :mark_as_received]
  before_action :require_create_permission, only: [:new, :create]
  before_action :require_edit_permission, only: [:edit, :update, :mark_as_sent, :mark_as_received]
  before_action :require_admin_or_manager, only: [:destroy]

  def index
    @purchase_orders = current_user.purchase_orders.includes(:supplier, :user)
      .order(created_at: :desc)
  end

  def show
    @purchase_order_items = @purchase_order.purchase_order_items.includes(:product)
  end

  def new
    @purchase_order = PurchaseOrder.new
    @purchase_order.purchase_order_items.build
    @suppliers = Supplier.all.order(:name)
    @products = Product.includes(:supplier).order(:name)
  end

  def create
    @purchase_order = PurchaseOrder.new(purchase_order_params)
    @purchase_order.user = current_user
    @purchase_order.order_number = generate_order_number
    @purchase_order.order_date = Date.current
    @purchase_order.status = "pending"
    @purchase_order.total_amount = calculate_total_amount

    if @purchase_order.save
      redirect_to @purchase_order, notice: "Purchase order was successfully created."
    else
      @suppliers = Supplier.all.order(:name)
      @products = Product.includes(:supplier).order(:name)
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @suppliers = Supplier.all.order(:name)
    @products = Product.includes(:supplier).order(:name)
  end

  def update
    @purchase_order.total_amount = calculate_total_amount

    if @purchase_order.update(purchase_order_params)
      redirect_to @purchase_order, notice: "Purchase order was successfully updated."
    else
      @suppliers = Supplier.all.order(:name)
      @products = Product.includes(:supplier).order(:name)
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @purchase_order.destroy
    redirect_to purchase_orders_url, notice: "Purchase order was successfully deleted."
  end

  def mark_as_sent
    if @purchase_order.update(status: "ordered")
      redirect_to @purchase_order, notice: "Purchase order marked as sent."
    else
      redirect_to @purchase_order, alert: "Failed to update purchase order status."
    end
  end

  def mark_as_received
    if @purchase_order.update(status: "received")
      @purchase_order.purchase_order_items.each do |item|
        location = Location.first
        stock_level = StockLevel.find_or_create_by(product: item.product, location: location)
        stock_level.increment!(:current_quantity, item.quantity)

        StockMovement.create!(
          product: item.product,
          destination_location: location,
          movement_type: "purchase",
          quantity: item.quantity,
          user: current_user,
          movement_date: Time.current,
          reference: @purchase_order,
          notes: "Received from PO ##{@purchase_order.order_number}"
        )
      end

      redirect_to @purchase_order, notice: "Purchase order received and stock updated."
    else
      redirect_to @purchase_order, alert: "Failed to receive purchase order."
    end
  end

  private

  def set_purchase_order
    @purchase_order = current_user.purchase_orders.find(params[:id])
  end

  def purchase_order_params
    params.require(:purchase_order).permit(
      :supplier_id,
      :expected_delivery_date,
      :notes,
      purchase_order_items_attributes: [:id, :product_id, :quantity, :unit_cost, :_destroy]
    )
  end

  def generate_order_number
    last_order = PurchaseOrder.order(:created_at).last
    if last_order && last_order.order_number.match(/PO-(\d{4})-(\d+)/)
      year = $1
      number = $2.to_i

      if year == Date.current.year.to_s
        "PO-#{year}-#{(number + 1).to_s.rjust(3, '0')}"
      else
        "PO-#{Date.current.year}-001"
      end
    else
      "PO-#{Date.current.year}-001"
    end
  end

  def calculate_total_amount
    return 0 unless params[:purchase_order] && params[:purchase_order][:purchase_order_items_attributes]

    total = 0
    params[:purchase_order][:purchase_order_items_attributes].each do |_, item_params|
      next if item_params[:_destroy] == "1"
      quantity = item_params[:quantity].to_f
      unit_cost = item_params[:unit_cost].to_f
      total += quantity * unit_cost
    end
    total
  end
end
