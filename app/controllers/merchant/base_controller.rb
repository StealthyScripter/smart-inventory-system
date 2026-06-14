module Merchant
  class BaseController < ApplicationController
    before_action :require_merchant_access
    helper_method :merchant_suppliers, :merchant_products

    private

    def require_merchant_access
      return if supplier_user? && current_user.suppliers.exists?

      render plain: "You don't have permission to access the merchant portal.", status: :forbidden
    end

    def merchant_suppliers
      @merchant_suppliers ||= current_user.suppliers.order(:name)
    end

    def merchant_products
      @merchant_products ||= Product.owned_by_suppliers(merchant_suppliers.select(:id))
    end

    def merchant_stock_levels
      StockLevel.joins(:product, :location)
                .includes(:product, :location)
                .merge(merchant_products)
                .order("products.name ASC, locations.name ASC")
    end
  end
end
