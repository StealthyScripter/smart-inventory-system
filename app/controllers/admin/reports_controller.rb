module Admin
  class ReportsController < BaseController
    def index
      @reports = Report.includes(:reporter, :reportable).order(created_at: :desc)
    end

    def update
      report = Report.where(id: params[:id]).take!
      report.update!(status: params.require(:report).permit(:status)[:status])
      ModerationAction.create!(
        actor: current_user,
        moderatable: report,
        action_name: report.status == "resolved" ? "resolve_report" : "dismiss_report",
        notes: "Report marked #{report.status}."
      )

      redirect_to admin_reports_path, notice: "Report was updated."
    end
  end
end
