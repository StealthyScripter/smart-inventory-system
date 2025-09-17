def index
  @purchase_orders = PurchaseOrder.includes(:supplier, :user)
    .order(created_at: :desc)
end
