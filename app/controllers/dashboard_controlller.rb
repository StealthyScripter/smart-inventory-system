def index
  @total_products = Product.count
  @total_value = calculate_total_inventory_value
  @low_stock_items = find_low_stock_products
  @recent_sales = SalesTransaction.recent.includes(:product, :location)
  @pending_orders = PurchaseOrder.pending.count
end

private

def calculate_total_inventory_value
  # Complex calculation across multiple models
end

def find_low_stock_products
  # Products where current stock < reorder point
end
