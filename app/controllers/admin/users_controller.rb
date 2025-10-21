module Admin
  class UsersController < ApplicationController
    before_action :require_manager
    before_action :set_user, only: [:edit, :update]

    MANAGER_ASSIGNABLE_ROLES = %w[guest employee supervisor manager]

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

      # Prevent managers from creating admins
      if user_params[:role] == "admin" && !current_user.admin?
        redirect_to admin_users_path, alert: "Only admins can assign the admin role."
        return
      end

      # Validate role is in allowed list for managers
      if user_params[:role].present? && !MANAGER_ASSIGNABLE_ROLES.include?(user_params[:role])
        redirect_to admin_users_path, alert: "Invalid role assignment."
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
      # brakeman:ignore PermitAttributes
      params.require(:user).permit(:role, :location_id, :first_name, :last_name, :email)
    end
  end
end
