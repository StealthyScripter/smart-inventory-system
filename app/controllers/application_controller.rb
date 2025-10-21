class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  include Authorization

  before_action :require_login
  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in"
      redirect_to login_path
    end
  end
end
