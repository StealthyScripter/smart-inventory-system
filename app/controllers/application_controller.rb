class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  include Authorization

  before_action :require_login
  helper_method :current_user, :logged_in?, :current_account_membership,
                :current_customer_account, :current_merchant_account

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def current_account_membership(account = nil)
    return unless current_user

    if account
      current_user.account_memberships.active.find_by(account: account)
    else
      current_merchant_membership || current_customer_membership
    end
  end

  def current_customer_account
    @current_customer_account ||= current_customer_membership&.account
  end

  def current_merchant_account
    @current_merchant_account ||= current_merchant_membership&.account
  end

  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in"
      redirect_to login_path
    end
  end

  def current_customer_membership
    @current_customer_membership ||= current_user&.account_memberships&.active
                                          &.joins(:account)
                                          &.merge(Account.active.customers)
                                          &.includes(:account)
                                          &.first
  end

  def current_merchant_membership
    @current_merchant_membership ||= current_user&.account_memberships&.active
                                          &.joins(:account)
                                          &.merge(Account.active.merchants)
                                          &.includes(account: :merchant_profile)
                                          &.first
  end
end
