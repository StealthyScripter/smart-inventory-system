module Admin
  class ModerationActionsController < BaseController
    MODERATABLE_TYPES = {
      "Product" => Product,
      "ServiceListing" => ServiceListing,
      "Supplier" => Supplier,
      "Review" => Review,
      "Report" => Report
    }.freeze

    def create
      moderatable = moderatable_record
      action_name = action_params[:action_name]

      ActiveRecord::Base.transaction do
        apply_action!(moderatable, action_name)
        ModerationAction.create!(
          actor: current_user,
          moderatable: moderatable,
          action_name: action_name,
          notes: action_params[:notes]
        )
      end

      redirect_to admin_moderation_path, notice: "Moderation action was recorded."
    rescue ActiveRecord::RecordInvalid, ArgumentError, KeyError
      redirect_to admin_moderation_path, alert: "Moderation action could not be recorded."
    end

    private

    def moderatable_record
      MODERATABLE_TYPES.fetch(action_params[:moderatable_type]).find(action_params[:moderatable_id])
    end

    def apply_action!(moderatable, action_name)
      case [moderatable.class.name, action_name]
      when ["Product", "hide"]
        moderatable.update!(marketplace_status: "archived")
      when ["Product", "approve"]
        moderatable.update!(marketplace_status: "public")
      when ["ServiceListing", "hide"]
        moderatable.update!(status: "archived")
      when ["ServiceListing", "approve"]
        moderatable.update!(status: "public")
      when ["Supplier", "suspend"]
        moderatable.update!(shop_status: "paused")
      when ["Supplier", "approve"]
        moderatable.update!(shop_status: "public")
      when ["Review", "hide"]
        moderatable.update!(status: "hidden")
      when ["Review", "approve"]
        moderatable.update!(status: "published")
      when ["Report", "dismiss_report"]
        moderatable.update!(status: "dismissed")
      when ["Report", "resolve_report"]
        moderatable.update!(status: "resolved")
      else
        raise ArgumentError, "unsupported moderation action"
      end
    end

    def action_params
      params.require(:moderation_action).permit(:moderatable_type, :moderatable_id, :action_name, :notes)
    end
  end
end
