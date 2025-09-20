class ProductsController < ApplicationController
  before_action :set_product, only: [ :show, :edit, :update, :destroy ]

  def index
    @products = Product.includes(:category, :supplier, :stock_levels)
                      .order(:name)
  end

  def show
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
  end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: "Product was successfully updated."
    else
      load_form_data
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

  def product_params
    params.require(:product).permit(:name, :sku, :description, :unit_cost,
    :selling_price, :reorder_point, :lead_time_days,
    :category_id, :supplier_id)
  end
end
