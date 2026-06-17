module Merchant
  class ProfilesController < BaseController
    def show
      @account = current_merchant_account
      @merchant_account = current_merchant_account
      @merchant_profile = @account&.merchant_profile
      @primary_supplier = merchant_suppliers.first
      @merchant_suppliers = merchant_suppliers
      @membership = current_account_membership(@account) if @account
      @orders = OrderItem.where(supplier: @merchant_suppliers).includes(:order, :product, :supplier).order(created_at: :desc).limit(5)
      @bookings = ServiceBooking.where(supplier: @merchant_suppliers).includes(:user, :service_listings).order(created_at: :desc).limit(5)
      @notifications_count = current_user.notifications.unread.count
      @can_manage_team = @merchant_account&.enterprise_merchant? && can_manage_merchant?(:manage_members)
      @can_manage_locations = @merchant_account&.enterprise_merchant? && can_manage_merchant?(:manage_locations)
      @can_manage_settings = @merchant_account&.enterprise_merchant? && can_manage_merchant?(:manage_account_settings)
    end
  end
end
