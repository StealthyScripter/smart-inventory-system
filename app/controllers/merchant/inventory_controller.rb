module Merchant
  class InventoryController < BaseController
    def index
      @stock_levels = merchant_stock_levels
    end
  end
end
