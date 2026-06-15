module Merchant
  class AccountSettingsController < BaseController
    before_action -> { require_merchant_permission(:manage_account_settings) }
    before_action :require_enterprise_account

    def edit
      @account = current_merchant_account
      @merchant_profile = @account.merchant_profile
    end

    def update
      @account = current_merchant_account
      @merchant_profile = @account.merchant_profile

      Account.transaction do
        @account.update!(account_params)
        @merchant_profile.update!(merchant_profile_params)
      end

      redirect_to edit_merchant_account_settings_path, notice: "Account settings were updated."
    rescue ActiveRecord::RecordInvalid
      render :edit, status: :unprocessable_content
    end

    private

    def require_enterprise_account
      return if current_merchant_account&.enterprise_merchant?

      render plain: "Enterprise account settings are not available for this account.", status: :forbidden
    end

    def account_params
      params.require(:account).permit(:name)
    end

    def merchant_profile_params
      params.require(:merchant_profile).permit(
        :display_name,
        :description,
        :default_listing_status,
        :default_inventory_policy,
        :default_fulfillment_days
      )
    end
  end
end
