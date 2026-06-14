module Customer
  class BaseController < ApplicationController
    before_action :require_customer_access

    private

    def require_customer_access
      return if customer?

      render plain: "You don't have permission to access customer orders.", status: :forbidden
    end
  end
end
