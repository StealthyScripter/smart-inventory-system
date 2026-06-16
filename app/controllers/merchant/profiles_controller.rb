module Merchant
  class ProfilesController < BaseController
    def show
      @account = current_merchant_account
      @merchant_profile = @account&.merchant_profile
      @primary_supplier = merchant_suppliers.first
      @membership = current_account_membership(@account) if @account
    end
  end
end
