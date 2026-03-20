class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :require_product_management_permission, only: [:new, :create, :edit, :update]
  before_action :require_delete_permission, only: [:destroy]

  def index
    @products = Product.includes(:category, :supplier, :stock_levels).order(:name)
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @product.as_json(only: [:id, :name, :sku, :unit_cost, :selling_price]) }
    end
  end

  def new
    @product = Product.new
    load_form_data
  end

  def create
    @product = Product.new(product_params)

    Product.transaction do
      @product.save!
      Location.find_each do |location|
        @product.stock_levels.find_or_create_by!(location: location) do |stock_level|
          stock_level.current_quantity = 0
          stock_level.reserved_quantity = 0
        end
      end
    end

    redirect_to @product, notice: "Product was successfully created."
  rescue ActiveRecord::RecordInvalid
    load_form_data
    render :new, status: :unprocessable_content
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
    @categories = Category.order(:name)
    @suppliers = Supplier.order(:name)
  end

  def product_params
    params.require(:product).permit(
      :name,
      :sku,
      :description,
      :unit_cost,
      :selling_price,
      :reorder_point,
      :lead_time_days,
      :category_id,
      :supplier_id
    )
  end
end
