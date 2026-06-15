module Merchant
  class BaseController < ApplicationController
    before_action :require_merchant_access
    helper_method :merchant_suppliers, :merchant_products

    private

    def require_merchant_access
      return if current_merchant_account&.active? && merchant_suppliers.exists?
      return if supplier_user? && current_user.suppliers.exists?

      render plain: "You don't have permission to access the merchant portal.", status: :forbidden
    end

    def merchant_suppliers
      @merchant_suppliers ||= merchant_compatible_suppliers.order(:name)
    end

    def merchant_products
      @merchant_products ||= begin
        supplier_products = Product.owned_by_suppliers(merchant_suppliers.select(:id))
        if current_merchant_account
          Product.where(account: current_merchant_account).or(supplier_products)
        else
          supplier_products
        end
      end
    end

    def merchant_stock_levels
      StockLevel.joins(:product, :location)
                .includes(:product, :location)
                .merge(merchant_products)
                .order("products.name ASC, locations.name ASC")
    end
  end
end
