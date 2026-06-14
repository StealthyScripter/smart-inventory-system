class ReportsController < ApplicationController
  REPORTABLE_TYPES = {
    "Product" => Product,
    "ServiceListing" => ServiceListing,
    "Supplier" => Supplier,
    "Review" => Review
  }.freeze

  def create
    reportable = reportable_record
    Report.create!(report_params.merge(reporter: current_user, reportable: reportable))

    redirect_back fallback_location: root_path, notice: "Report was submitted."
  rescue ActiveRecord::RecordNotFound, KeyError, ActionController::ParameterMissing
    redirect_back fallback_location: root_path, alert: "Report could not be submitted."
  end

  private

  def reportable_record
    REPORTABLE_TYPES.fetch(report_params[:reportable_type]).find(report_params[:reportable_id])
  end

  def report_params
    params.require(:report).permit(:reportable_type, :reportable_id, :reason, :details)
  end
end
