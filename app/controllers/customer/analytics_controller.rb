module Customer
  class AnalyticsController < BaseController
    def index
      @summary = AnalyticsSummary.for_customer(current_user)
    end
  end
end
