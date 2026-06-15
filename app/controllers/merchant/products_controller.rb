module Merchant
  class ProductsController < BaseController
    before_action -> { require_merchant_permission(:manage_catalog) }
    before_action :set_product, only: [:edit, :update]

    def index
      @products = merchant_products.includes(:category, :supplier, :stock_levels).order(:name)
    end

    def new
      @product = Product.new(supplier: default_supplier)
      load_form_data
    end

    def create
      @product = Product.new(product_params)
      @product.account ||= current_merchant_account
      return unless supplier_assignment_allowed?(:new)

      Product.transaction do
        @product.save!
        Location.find_each do |location|
          @product.stock_levels.find_or_create_by!(location: location) do |stock_level|
            stock_level.account = current_merchant_account
            stock_level.current_quantity = 0
            stock_level.reserved_quantity = 0
          end
        end
      end

      redirect_to merchant_products_path, notice: "Product was successfully created."
    rescue ActiveRecord::RecordInvalid
      load_form_data
      render :new, status: :unprocessable_content
    end

    def edit
      load_form_data
    end

    def update
      @product.assign_attributes(product_params)
      @product.account ||= current_merchant_account
      return unless supplier_assignment_allowed?(:edit)

      if @product.save
        redirect_to merchant_products_path, notice: "Product was successfully updated."
      else
        load_form_data
        render :edit, status: :unprocessable_content
      end
    end

    private

    def set_product
      @product = merchant_products.find(params[:id])
    end

    def load_form_data
      @categories = Category.order(:name)
      @suppliers = merchant_suppliers
    end

    def default_supplier
      merchant_suppliers.first
    end

    def supplier_assignment_allowed?(template)
      return true if @product.supplier_id.present? && merchant_suppliers.exists?(id: @product.supplier_id)

      load_form_data
      @product.errors.add(:supplier, "must belong to your supplier account")
      render template, status: :unprocessable_content
      false
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
        :supplier_id,
        :marketplace_status,
        :listing_scope,
        :featured_image,
        images: []
      )
    end
  end
end
