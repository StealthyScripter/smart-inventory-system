class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy]
  before_action :require_location_management_permission, only: [:new, :create, :edit, :update]
  before_action :require_delete_permission, only: [:destroy]
  before_action :load_manager_options, only: [:new, :create, :edit, :update]

  def index
    @locations = Location.includes(:manager, :stock_levels).order(:name)
  end

  def show
  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)

    if @location.save
      redirect_to @location, notice: "Location was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @location.update(location_params)
      redirect_to @location, notice: "Location was successfully updated."
    else
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

  def load_manager_options
    @users = User.with_roles("admin", "regional_manager", "location_manager").order(:first_name, :last_name)
  end

  def location_params
    params.require(:location).permit(:name, :address, :manager_id)
  end
end
