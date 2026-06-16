module Merchant
  class InventoryController < BaseController
    before_action -> { require_merchant_permission(:view_inventory) }, only: [:index]
    before_action -> { require_merchant_permission(:adjust_stock) }, only: [:update]

    def index
      @stock_levels = merchant_stock_levels
      @inventory_products = merchant_products
                            .includes(:marketplace_listing, stock_levels: :location)
                            .order(:name)
    end

    def update
      stock_level = merchant_stock_levels.find(params[:id])
      quantity = inventory_params[:current_quantity].to_i
      previous_quantity = stock_level.current_quantity

      StockLevel.transaction do
        stock_level.update!(current_quantity: quantity)
        StockMovement.create!(
          product: stock_level.product,
          account: current_merchant_account,
          destination_location: stock_level.location,
          movement_type: "adjustment",
          quantity: (quantity - previous_quantity).abs,
          user: current_user,
          movement_date: Time.current,
          notes: "Merchant inventory adjustment"
        ) if quantity != previous_quantity
      end

      redirect_to merchant_inventory_path, notice: "Inventory was updated."
    rescue ActiveRecord::RecordInvalid
      redirect_to merchant_inventory_path, alert: "Inventory could not be updated."
    end

    def update_marketplace
      product = merchant_products.find(params[:product_id])

      if params[:visibility_choice] == "marketplace"
        product.update!(listing_scope: "both", marketplace_status: "public")
        listing = product.marketplace_listing || product.build_marketplace_listing(
          account: product.merchant_account,
          title: product.name,
          listing_type: "product"
        )
        listing.assign_attributes(
          account: product.merchant_account,
          title: listing.title.presence || product.name,
          public_description: listing.public_description.presence || product.description,
          public_price: listing.public_price || product.selling_price,
          status: "active",
          visibility: "public",
          listing_type: "product"
        )
        listing.save!
        redirect_to merchant_inventory_path, notice: "#{product.name} is ready for marketplace listing."
      else
        product.update!(listing_scope: "local", marketplace_status: "private")
        product.marketplace_listing&.update!(status: "hidden", visibility: "private")
        redirect_to merchant_inventory_path, notice: "#{product.name} will stay private/local."
      end
    rescue ActiveRecord::RecordInvalid
      redirect_to merchant_inventory_path, alert: "Marketplace visibility could not be updated."
    end

    private

    def inventory_params
      params.require(:stock_level).permit(:current_quantity)
    end
  end
end
