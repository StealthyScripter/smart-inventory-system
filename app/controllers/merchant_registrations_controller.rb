class MerchantRegistrationsController < ApplicationController
  MERCHANT_ACCOUNT_TYPES = %w[individual_merchant enterprise_merchant].freeze

  skip_before_action :require_login, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params.merge(role: "supplier"))
    account_type = merchant_account_type
    shop_name = merchant_params[:shop_name].presence || "#{@user.full_name} Shop"

    User.transaction do
      @user.save!
      account = Account.create_with_owner!(creator: @user, name: shop_name, account_type: account_type)
      supplier = Supplier.create!(name: shop_name, default_lead_time_days: 7, shop_status: "draft")
      MerchantProfile.create!(account: account, supplier: supplier, display_name: shop_name)
    end

    reset_session
    session[:user_id] = @user.id
    redirect_to merchant_root_path, notice: "Welcome! Your merchant account has been created."
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_content
  end

  private

  def merchant_account_type
    account_type = merchant_params[:account_type]
    return account_type if MERCHANT_ACCOUNT_TYPES.include?(account_type)

    "individual_merchant"
  end

  def merchant_params
    params.fetch(:merchant, {}).permit(:account_type, :shop_name)
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation)
  end
end
