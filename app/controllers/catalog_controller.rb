class CatalogController < ApplicationController
  skip_before_action :require_login

  def index
    @categories = Category.joins(products: :marketplace_listing).merge(Product.publicly_listed).distinct.order(:name)
    @suppliers = Supplier.joins(products: :marketplace_listing).merge(Product.publicly_listed).distinct.order(:name)
    @product_listings = ::SearchService.new(params.permit(:q, :category_id, :supplier_id, :sort, :page)).product_listings(limit: 25)
  end

  def show
    @product = Product.publicly_listed.includes(:category, :supplier, :marketplace_listing).find(params[:id])
    @listing = @product.marketplace_listing
    @recommended_products = RecommendationService.new.product_recommendations(@product)
  end
end
