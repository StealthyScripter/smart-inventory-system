module Merchant
  class MembersController < BaseController
    before_action -> { require_merchant_permission(:manage_members) }
    before_action :require_enterprise_account
    before_action :set_membership, only: [:update, :destroy, :enable]

    def index
      @account = current_merchant_account
      @memberships = @account.account_memberships.includes(:user).order(created_at: :asc)
    end

    def create
      user = User.find_by!(email: member_email)
      current_merchant_account.add_member!(user)

      redirect_to merchant_members_path, notice: "Member was added."
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound
      redirect_to merchant_members_path, alert: "Member could not be added."
    end

    def update
      return redirect_last_admin_alert if removing_last_owner_or_admin?(requested_role)

      @membership.update!(role: requested_role)
      redirect_to merchant_members_path, notice: "Member role was updated."
    rescue ActiveRecord::RecordInvalid
      redirect_to merchant_members_path, alert: "Member role could not be updated."
    end

    def destroy
      return redirect_last_admin_alert if removing_last_owner_or_admin?(nil)

      @membership.update!(active: false)
      redirect_to merchant_members_path, notice: "Member access was disabled."
    end

    def enable
      @membership.update!(active: true)
      redirect_to merchant_members_path, notice: "Member access was enabled."
    rescue ActiveRecord::RecordInvalid
      redirect_to merchant_members_path, alert: "Member access could not be enabled."
    end

    private

    def require_enterprise_account
      return if current_merchant_account&.enterprise_merchant?

      render plain: "Team management is only available for enterprise merchant accounts.", status: :forbidden
    end

    def set_membership
      @membership = current_merchant_account.account_memberships.find(params[:id])
    end

    def member_email
      params.require(:account_membership).permit(:email)[:email]
    end

    def requested_role
      role = params.require(:account_membership).fetch(:role).to_s
      return role if AccountMembership::ROLES.include?(role)

      "employee"
    end

    def removing_last_owner_or_admin?(new_role)
      return false unless @membership.active? && @membership.owner_or_admin?
      return false if AccountMembership.new(role: new_role).owner_or_admin?

      current_merchant_account.account_memberships.active.owners_or_admins.count <= 1
    end

    def redirect_last_admin_alert
      redirect_to merchant_members_path, alert: "Account must keep at least one active owner or admin."
    end
  end
end
