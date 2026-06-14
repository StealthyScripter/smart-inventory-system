module Admin
  class BaseController < ApplicationController
    before_action :require_admin_access

    private

    def require_admin_access
      return if admin?

      render plain: "You don't have permission to access marketplace governance.", status: :forbidden
    end
  end
end
