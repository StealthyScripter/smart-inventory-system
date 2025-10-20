class SalesController < ApplicationController
  before_action :set_sale, only: [:show, :destroy]

  def index
    @recent_transactions = SalesTransaction.includes(:product, :location, :user)
      .where("transaction_date >= ?", Date.current)
      .order(transaction_date: :desc)
    @sale = SalesTransaction.new
    load_form_data
  end

  def new
    @sale = SalesTransaction.new
    load_form_data
  end

  def create
    @sale = SalesTransaction.new(sale_params)
    @sale.transaction_date = Time.current
    @sale.user ||= current_user # safer default

    if valid_stock_for_sale?
      if @sale.save
        process_successful_sale
        redirect_to sales_path, notice: "Sale processed successfully!"
      else
        handle_sale_errors
      end
    else
      @sale.errors.add(:quantity, "exceeds available stock")
      handle_sale_errors
    end
  end

  def show; end

  def destroy
    # Reverse the stock movement
    stock_level = StockLevel.find_by(product: @sale.product, location: @sale.location)
    stock_level&.update!(current_quantity: stock_level.current_quantity + @sale.quantity)

    StockMovement.where(reference: @sale).destroy_all
    @sale.destroy
    redirect_to sales_path, notice: "Sale was successfully cancelled and inventory restored."
  end

  def product_details
    @product = Product.find(params[:product_id])
    render json: { selling_price: @product.selling_price, unit_cost: @product.unit_cost }
  end

  private

  def set_sale
    @sale = current_user.sales_transactions.find(params[:id])
  end

  def valid_stock_for_sale?
    return false unless @sale.product && @sale.location && @sale.quantity
    stock_level = StockLevel.find_by(product: @sale.product, location: @sale.location)
    stock_level && stock_level.current_quantity >= @sale.quantity
  end

  def process_successful_sale
    stock_level = StockLevel.find_by(product: @sale.product, location: @sale.location)
    stock_level.update!(current_quantity: stock_level.current_quantity - @sale.quantity)

    StockMovement.create!(
      product: @sale.product,
      destination_location: @sale.location,
      movement_type: "sale",
      quantity: @sale.quantity,
      user: @sale.user,
      movement_date: @sale.transaction_date,
      reference: @sale,
      notes: "Sale to #{@sale.customer_name}"
    )
  end

  def handle_sale_errors
    load_form_data

    if request.referer&.include?("sales") && !request.referer&.include?("new")
      @recent_transactions = SalesTransaction.includes(:product, :location, :user)
        .where("transaction_date >= ?", Date.current)
        .order(transaction_date: :desc)
      render :index, status: :unprocessable_content
    else
      render :new, status: :unprocessable_content
    end
  end

  def load_form_data
    @products = Product.includes(:stock_levels).order(:name)
    @locations = Location.order(:name)
    @users = User.order(:first_name, :last_name)
  end

  def sale_params
    params.require(:sales_transaction).permit(
      :product_id, :location_id, :user_id, :customer_name, :quantity, :unit_price, :total_amount
    )
  end
end
