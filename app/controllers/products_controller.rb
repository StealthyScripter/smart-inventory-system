class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = Product.includes(:category, :supplier, :stock_levels)
                      .order(:name)
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @product.as_json(only: [:id, :name, :sku, :unit_cost, :selling_price]) }
    end
  end

  def new
    @product = Product.new
    @categories = Category.all.order(:name)
    @suppliers = Supplier.all.order(:name)
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      # Create initial stock levels for all locations
      Location.all.each do |location|
        @product.stock_levels.create!(location: location, current_quantity: 0)
      end

      redirect_to @product, notice: "Product was successfully created."
    else
      load_form_data
      render :new, status: :unprocessable_content
    end
  end

  def edit
    load_form_data
    load_stock_levels
  end

  def update
    if @product.update(product_params)
      # Update stock levels if provided
      update_stock_levels if params[:stock_levels].present?

      redirect_to @product, notice: "Product was successfully updated."
    else
      load_form_data
      load_stock_levels
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @product.destroy
    redirect_to products_url, notice: "Product was successfully deleted."
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def load_form_data
    @categories = Category.all.order(:name)
    @suppliers = Supplier.all.order(:name)
  end

  def load_stock_levels
    @locations = Location.all.order(:name)
    @stock_levels = @product.stock_levels.includes(:location).index_by(&:location_id)
  end

  def update_stock_levels
    params[:stock_levels].each do |location_id, quantity|
      stock_level = @product.stock_levels.find_or_initialize_by(location_id: location_id)
      old_quantity = stock_level.current_quantity
      new_quantity = quantity.to_i

      if stock_level.update(current_quantity: new_quantity)
        # Create stock movement record for the adjustment
        if old_quantity != new_quantity
          StockMovement.create!(
            product: @product,
            destination_location_id: location_id,
            movement_type: "adjustment",
            quantity: (new_quantity - old_quantity).abs,
            user: current_user,
            movement_date: Time.current,
            notes: "Stock adjusted from #{old_quantity} to #{new_quantity} via product edit"
          )
        end
      end
    end
  end

  def product_params
    params.require(:product).permit(:name, :sku, :description, :unit_cost,
    :selling_price, :reorder_point, :lead_time_days,
    :category_id, :supplier_id)
  end
end
