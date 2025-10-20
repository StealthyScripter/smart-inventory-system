class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy]

  def index
    @locations = Location.includes(:manager, :stock_levels).order(:name)
  end

  def show
  end

  def new
    @location = Location.new
    @users = User.all.order(:first_name, :last_name)
  end

  def create
    @location = Location.new(location_params)

    if @location.save
      redirect_to @location, notice: "Location was successfully created."
    else
      @users = User.all.order(:first_name, :last_name)
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @users = User.all.order(:first_name, :last_name)
  end

  def update
    if @location.update(location_params)
      redirect_to @location, notice: "Location was successfully updated."
    else
      @users = User.all.order(:first_name, :last_name)
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @location.destroy
    redirect_to locations_url, notice: "Location was successfully deleted."
  end

  private

  def set_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :address, :manager_id)
  end
end
