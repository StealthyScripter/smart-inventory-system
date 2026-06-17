module Merchant
  class CatalogController < BaseController
    before_action -> { require_merchant_permission(:manage_catalog) }

    def index
      @product_listings = MarketplaceListing
                          .products
                          .includes(product: [:category, :supplier, :reviews, { featured_image_attachment: :blob }])
                          .where(product_id: merchant_products.select(:id))
                          .order(updated_at: :desc)
      @unlisted_products = merchant_products
                           .includes(:category, :supplier)
                           .left_outer_joins(:marketplace_listing)
                           .where(marketplace_listings: { id: nil })
                           .order(:name)
      @products = merchant_products.includes(:category, :stock_levels).order(:name).limit(12)
      @services = ServiceListing.where(supplier: merchant_suppliers).order(:name).limit(12)
      @product_count = merchant_products.count
      @service_count = ServiceListing.where(supplier: merchant_suppliers).count
    end
  end
end
