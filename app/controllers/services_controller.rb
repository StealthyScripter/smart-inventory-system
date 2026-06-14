class ServicesController < ApplicationController
  skip_before_action :require_login

  def index
    @categories = ServiceListing::CATEGORIES
    @services = ServiceListing.publicly_listed
                              .search(params[:q])
                              .then { |scope| params[:category].present? ? scope.where(service_category: params[:category]) : scope }
                              .includes(:supplier)
                              .order(:service_category, :name)
  end

  def show
    @service = ServiceListing.publicly_listed.includes(:supplier, reviews: :user).find(params[:id])
    @recommended_services = RecommendationService.new.service_recommendations(@service)
  end
end
