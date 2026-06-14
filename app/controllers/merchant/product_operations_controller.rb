module Merchant
  class ProductOperationsController < BaseController
    def bulk_update
      count = operations.bulk_update!(
        product_ids: params[:product_ids],
        marketplace_status: params[:marketplace_status],
        listing_scope: params[:listing_scope]
      )
      redirect_to merchant_products_path, notice: "#{count} products were updated."
    end

    def duplicate
      product = merchant_products.find(params[:product_id])
      duplicate = operations.duplicate!(product)
      redirect_to edit_merchant_product_path(duplicate), notice: "Product was duplicated as #{duplicate.sku}."
    end

    def export
      send_data operations.export_csv,
                filename: "merchant-products-#{Time.current.strftime('%Y%m%d')}.csv",
                type: "text/csv"
    end

    def import
      result = operations.import_csv(params.require(:file))
      redirect_to merchant_products_path, notice: "Imported #{result[:created]} created and #{result[:updated]} updated products."
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound, ActionController::ParameterMissing, MerchantProductOperations::CSVImportError
      redirect_to merchant_products_path, alert: "CSV import failed."
    end

    private

    def operations
      @operations ||= MerchantProductOperations.new(merchant_suppliers, actor: current_user)
    end
  end
end
