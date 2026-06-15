class CustomerRegistrationsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params.merge(role: "customer"))

    User.transaction do
      @user.save!
      account = Account.create_with_owner!(
        creator: @user,
        name: "#{@user.full_name} Customer Account",
        account_type: "customer"
      )
      CustomerProfile.create!(account: account, user: @user, display_name: @user.full_name)
    end

    reset_session
    session[:user_id] = @user.id
    redirect_to catalog_path, notice: "Welcome! Your customer account has been created."
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_content
  end

  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation)
  end
end
