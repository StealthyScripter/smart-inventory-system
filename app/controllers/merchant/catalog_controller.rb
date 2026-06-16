module Merchant
  class CatalogController < BaseController
    def index
      @products = merchant_products.includes(:category, :stock_levels).order(:name).limit(12)
      @services = ServiceListing.where(supplier: merchant_suppliers).order(:name).limit(12)
      @product_count = merchant_products.count
      @service_count = ServiceListing.where(supplier: merchant_suppliers).count
    end
  end
end
