class HomeController < ApplicationController
  skip_before_action :require_login

  def index
    search = SearchService.new({})
    @goods = search.products(limit: 4)
    @services = search.services(limit: 4)
    @merchants = search.merchants(limit: 4)
    @top_rated_goods = top_rated_goods
    @top_rated_merchants = SearchService.new(sort: "rating").merchants(limit: 4)
    @recommended_goods = recommended_products
    @recent_items = recent_items
    @continue_shopping_items = continue_shopping_items
  end

  private

  def recommended_products
    source = current_user&.customer? ? current_cart_product : nil
    source ||= @goods.first

    if source
      RecommendationService.new.product_recommendations(source, limit: 4)
    else
      @goods
    end
  end

  def current_cart_product
    current_cart&.cart_items&.includes(product: [:category, :supplier])&.first&.product
  end

  def current_cart
    return unless current_user&.customer?

    @current_cart ||= current_user.carts.find_by(status: "active")
  end

  def continue_shopping_items
    return [] unless current_cart

    current_cart.cart_items.includes(product: [:category, :supplier]).order(created_at: :desc).limit(3)
  end

  def recent_items
    recent_goods = Product.publicly_listed.includes(:category, :supplier).order(created_at: :desc).limit(2).map do |product|
      { kind: :product, record: product }
    end

    recent_services = ServiceListing.publicly_listed.includes(:supplier).order(created_at: :desc).limit(2).map do |service|
      { kind: :service, record: service }
    end

    (recent_goods + recent_services).first(4)
  end

  def top_rated_goods
    Product.publicly_listed
           .includes(:category, :supplier)
           .left_joins(:reviews)
           .group("products.id")
           .order(Arel.sql("AVG(reviews.rating) DESC NULLS LAST"), created_at: :desc)
           .limit(4)
  end
end
