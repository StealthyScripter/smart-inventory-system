class SessionsController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create ]

  def new
    @login_context = params[:login_context]
  end

  def create
    @login_context = params[:login_context]
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      reset_session
      session[:user_id] = user.id
      redirect_to post_login_path(@login_context), notice: "Logged in successfully!"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Logged out successfully!"
  end

  private

  def post_login_path(login_context)
    return catalog_path if login_context == "customer"
    return merchant_root_path if login_context == "merchant" && current_merchant_entry?

    root_path
  end

  def current_merchant_entry?
    current_merchant_account.present? || (current_user&.supplier_user? && current_user.suppliers.exists?)
  end
end
