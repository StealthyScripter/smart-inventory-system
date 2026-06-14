module Merchant
  class AnalyticsController < BaseController
    def index
      @summary = AnalyticsSummary.for_merchant(merchant_suppliers)
    end
  end
end
