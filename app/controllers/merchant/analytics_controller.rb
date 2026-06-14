module Merchant
  class AnalyticsController < BaseController
    def index
      @summary = AnalyticsSummary.for_merchant(merchant_suppliers)
      respond_to do |format|
        format.html
        format.csv { send_data AnalyticsCsvExport.call(@summary), filename: "merchant-analytics.csv", type: "text/csv" }
      end
    end
  end
end
