class ServicesController < ApplicationController
  skip_before_action :require_login

  def index
    @categories = ServiceListing::CATEGORIES
    search_params = params.permit(:q, :sort).merge(service_category: params[:category])
    @services = SearchService.new(search_params).services(limit: 100)
  end

  def show
    @service = ServiceListing.publicly_listed.includes(:supplier, reviews: :user).find(params[:id])
    @recommended_services = RecommendationService.new.service_recommendations(@service)
  end
end
