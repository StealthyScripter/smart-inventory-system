module Merchant
  class ServicesController < BaseController
    before_action :set_service, only: [:edit, :update]

    def index
      @services = ServiceListing.for_supplier(merchant_suppliers.select(:id)).includes(:supplier).order(:name)
    end

    def new
      @service = ServiceListing.new(supplier: merchant_suppliers.first)
      load_form_data
    end

    def create
      @service = ServiceListing.new(service_params)
      return unless supplier_allowed?(:new)

      if @service.save
        redirect_to merchant_services_path, notice: "Service was created."
      else
        load_form_data
        render :new, status: :unprocessable_content
      end
    end

    def edit
      load_form_data
    end

    def update
      @service.assign_attributes(service_params)
      return unless supplier_allowed?(:edit)

      if @service.save
        redirect_to merchant_services_path, notice: "Service was updated."
      else
        load_form_data
        render :edit, status: :unprocessable_content
      end
    end

    private

    def set_service
      @service = ServiceListing.for_supplier(merchant_suppliers.select(:id)).find(params[:id])
    end

    def load_form_data
      @suppliers = merchant_suppliers
      @categories = ServiceListing::CATEGORIES
    end

    def supplier_allowed?(template)
      return true if @service.supplier_id.present? && merchant_suppliers.exists?(id: @service.supplier_id)

      load_form_data
      @service.errors.add(:supplier, "must belong to your supplier account")
      render template, status: :unprocessable_content
      false
    end

    def service_params
      params.require(:service_listing).permit(:supplier_id, :name, :service_category, :description, :starting_price, :image_url, :status)
    end
  end
end
