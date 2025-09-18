class LocationsController < ApplicationController
  def index
    @locations = Location.includes(:manager, :stock_levels).order(:name)
  end

  def show
    @location = Location.find(params[:id])
  end
end
