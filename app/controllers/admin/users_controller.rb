module Admin
  class UsersController < ApplicationController
    before_action :require_manager
    before_action :set_user, only: [:edit, :update]

    def index
      @users = User.includes(:location).order(:last_name, :first_name)
    end

    def edit
      @locations = Location.all.order(:name)
    end

    def update
      # Prevent users from changing their own role
      if @user == current_user && user_params[:role].present? && user_params[:role] != @user.role
        redirect_to admin_users_path, alert: "You cannot change your own role."
        return
      end

      if @user.update(user_params)
        redirect_to admin_users_path, notice: "User was successfully updated."
      else
        @locations = Location.all.order(:name)
        render :edit, status: :unprocessable_content
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:role, :location_id, :first_name, :last_name, :email)
    end
  end
end
