module Merchant
  class ShopsController < BaseController
    before_action -> { require_merchant_permission(:manage_account_settings) }
    before_action :set_shop

    def edit
    end

    def update
      if @shop.update(shop_params)
        redirect_to edit_merchant_shop_path(@shop), notice: "Shop profile was updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def set_shop
      @shop = merchant_suppliers.find(params[:id])
    end

    def shop_params
      params.require(:supplier).permit(
        :name,
        :contact_email,
        :contact_phone,
        :address,
        :shop_slug,
        :shop_status,
        :shop_description,
        :shop_image_url,
        :marketplace_tag_list,
        :logo,
        :banner
      )
    end
  end
end
