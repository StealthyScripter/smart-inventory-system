class MerchantsController < ApplicationController
  skip_before_action :require_login

  def show
    @merchant = Supplier.find(params[:id])
    @products = @merchant.products.publicly_listed.includes(:category).catalog_sorted(params[:sort])
  end
end
