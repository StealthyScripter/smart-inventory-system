class CatalogController < ApplicationController
  skip_before_action :require_login

  def index
    @categories = Category.joins(:products).merge(Product.publicly_listed).distinct.order(:name)
    @suppliers = Supplier.joins(:products).merge(Product.publicly_listed).distinct.order(:name)
    @products = SearchService.new(params.permit(:q, :category_id, :supplier_id, :sort, :page)).products(limit: 25)
  end

  def show
    @product = Product.publicly_listed.includes(:category, :supplier).find(params[:id])
    @recommended_products = RecommendationService.new.product_recommendations(@product)
  end
end
