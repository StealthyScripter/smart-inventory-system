module Admin
  class ModerationController < BaseController
    def index
      @reports = Report.includes(:reporter, :reportable).order(created_at: :desc)
      @products = Product.active_marketplace.includes(:supplier).order(updated_at: :desc).limit(25)
      @services = ServiceListing.includes(:supplier).order(updated_at: :desc).limit(25)
      @reviews = Review.includes(:user, :supplier, :product, :service_listing).order(created_at: :desc).limit(25)
      @suppliers = Supplier.order(updated_at: :desc).limit(25)
      @moderation_actions = ModerationAction.includes(:actor, :moderatable).order(created_at: :desc).limit(25)
    end
  end
end
