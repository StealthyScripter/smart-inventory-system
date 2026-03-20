module Admin
  class UsersController < ApplicationController
    before_action :require_user_management_permission
    before_action :set_user, only: [:edit, :update]
    before_action :ensure_manageable_user!, only: [:edit, :update]

    ADMIN_ASSIGNABLE_ROLES = User::ROLE_HIERARCHY.freeze
    REGIONAL_MANAGER_ASSIGNABLE_ROLES = %w[
      location_manager
      department_manager
      employee
      client
      supplier
      customer
      guest
    ].freeze

    def index
      @users = User.includes(:location).order(:last_name, :first_name)
    end

    def edit
      load_form_data
    end

    def update
      if attempting_self_role_change?
        redirect_to admin_users_path, alert: "You cannot change your own role."
        return
      end

      unless assignable_roles.include?(normalized_requested_role)
        redirect_to admin_users_path, alert: "You cannot assign that role."
        return
      end

      if @user.update(user_params)
        redirect_to admin_users_path, notice: "User was successfully updated."
      else
        load_form_data
        render :edit, status: :unprocessable_content
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def ensure_manageable_user!
      return if current_user.admin?
      return unless current_user.regional_manager?

      if @user.admin? || @user.regional_manager?
        redirect_to admin_users_path, alert: "Regional managers cannot manage admins or other regional managers."
      end
    end

    def load_form_data
      @locations = Location.order(:name)
      @assignable_roles = assignable_roles
    end

    def assignable_roles
      current_user.admin? ? ADMIN_ASSIGNABLE_ROLES : REGIONAL_MANAGER_ASSIGNABLE_ROLES
    end

    def attempting_self_role_change?
      @user == current_user &&
        user_params[:role].present? &&
        User.normalize_role(user_params[:role]) != @user.normalized_role
    end

    def normalized_requested_role
      User.normalize_role(user_params[:role])
    end

    def user_params
      params.require(:user).permit(:role, :location_id, :first_name, :last_name, :email)
    end
  end
end
