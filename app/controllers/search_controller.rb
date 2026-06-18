class SearchController < ApplicationController
  skip_before_action :require_login

  def index
    @search = ::SearchService.new(search_params.merge(page: params[:page]))
    @products = @search.products
    @services = @search.services
    @merchants = @search.merchants
    @categories = @search.categories
    @suggestions = @search.suggestions
    @service_categories = ServiceListing::CATEGORIES
    @merchant_options = Supplier.where(id: @search.merchants(limit: 50).pluck(:id)).order(:name)
  end

  private

  def search_params
    params.permit(:q, :category_id, :service_category, :merchant_id, :supplier_id, :tag_id, :sort, :page)
  end
end
