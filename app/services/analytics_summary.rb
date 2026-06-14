class AnalyticsSummary
  def self.for_merchant(suppliers)
    order_items = OrderItem.where(supplier: suppliers)
    {
      sales_total: order_items.sum(:total_amount),
      delivered_count: order_items.where(fulfillment_status: "delivered").count,
      open_order_count: order_items.where.not(fulfillment_status: ["delivered", "cancelled"]).count,
      product_count: Product.where(supplier: suppliers).count,
      public_product_count: Product.where(supplier: suppliers).publicly_listed.count,
      service_count: ServiceListing.where(supplier: suppliers).count,
      public_service_count: ServiceListing.where(supplier: suppliers).publicly_listed.count,
      review_count: Review.published.where(supplier: suppliers).count,
      average_rating: Review.published.where(supplier: suppliers).average(:rating).to_f
    }
  end

  def self.for_customer(user)
    {
      purchase_total: user.orders.sum(:total_amount),
      order_count: user.orders.count,
      delivered_order_count: user.orders.where(status: "delivered").count,
      review_count: user.reviews.count,
      unread_notification_count: user.notifications.unread.count
    }
  end

  def self.platform
    {
      merchant_count: Supplier.count,
      product_count: Product.count,
      service_count: ServiceListing.count,
      order_count: Order.count,
      sales_total: Order.sum(:total_amount),
      review_count: Review.published.count
    }
  end
end
