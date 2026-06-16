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
    end
  end
end
