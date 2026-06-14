class CatalogController < ApplicationController
  skip_before_action :require_login

  def index
    @categories = Category.joins(:products).merge(Product.publicly_listed).distinct.order(:name)
    @suppliers = Supplier.joins(:products).merge(Product.publicly_listed).distinct.order(:name)
    @products = catalog_scope.includes(:category, :supplier)
  end

  def show
    @product = Product.publicly_listed.includes(:category, :supplier).find(params[:id])
    @recommended_products = RecommendationService.new.product_recommendations(@product)
  end

  private

  def catalog_scope
    Product.publicly_listed
           .search(params[:q])
           .for_category(params[:category_id])
           .for_supplier(params[:supplier_id])
           .catalog_sorted(params[:sort])
  end
end
