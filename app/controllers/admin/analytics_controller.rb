module Admin
  class AnalyticsController < ApplicationController
    before_action :require_user_management_permission

    def index
      @summary = AnalyticsSummary.platform
    end
  end
end
