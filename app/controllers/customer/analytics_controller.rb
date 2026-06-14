module Customer
  class AnalyticsController < BaseController
    def index
      @summary = AnalyticsSummary.for_customer(current_user)
      respond_to do |format|
        format.html
        format.csv { send_data AnalyticsCsvExport.call(@summary), filename: "customer-analytics.csv", type: "text/csv" }
      end
    end
  end
end
