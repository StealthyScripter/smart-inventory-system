class ProductsController < ApplicationController
  def index
    @products = Product.includes(:category, :supplier, :stock_levels)
                      .order(:name)
  end

  def show
    @product = Product.find(params[:id])
  end
end
