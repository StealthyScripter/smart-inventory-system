class MerchantsController < ApplicationController
  skip_before_action :require_login

  def show
    @merchant = Supplier.find(params[:id])
    @products = SearchService.new(params.permit(:q, :sort).merge(merchant_id: @merchant.id)).products(limit: 100)
    @services = SearchService.new(params.permit(:q, :sort).merge(merchant_id: @merchant.id)).services(limit: 100)
  end
end
