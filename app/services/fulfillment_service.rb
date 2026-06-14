class FulfillmentService
  def initialize(order_item, actor:)
    @order_item = order_item
    @actor = actor
  end

  def transition_to!(status)
    OrderItem.transaction do
      deduct_inventory! if status.to_s == "shipped" && order_item.fulfillment_status != "shipped"
      order_item.transition_to!(status)
      sync_order_status!
      order_item
    end
  end

  private

  attr_reader :order_item, :actor

  def deduct_inventory!
    stock_level = order_item.product.stock_levels.order(current_quantity: :desc).first
    raise ActiveRecord::RecordInvalid, order_item unless stock_level
    raise ActiveRecord::RecordInvalid, stock_level if stock_level.current_quantity < order_item.quantity

    stock_level.update!(current_quantity: stock_level.current_quantity - order_item.quantity)
    StockMovement.create!(
      product: order_item.product,
      source_location: stock_level.location,
      movement_type: "sale",
      quantity: order_item.quantity,
      reference: order_item.order,
      user: actor,
      movement_date: Time.current,
      notes: "Marketplace order #{order_item.order.order_number} shipped"
    )
  end

  def sync_order_status!
    order = order_item.order
    statuses = order.order_items.pluck(:fulfillment_status)

    if statuses.all?("delivered")
      order.update!(status: "delivered")
      notify_customer!(order, "Order delivered", "Your order #{order.order_number} was delivered.")
      NotificationEmailJob.perform_later("OrderMailer", "delivered", order)
    elsif statuses.all?("shipped") || statuses.include?("shipped")
      order.update!(status: "shipped")
      notify_customer!(order, "Order shipped", "Your order #{order.order_number} has shipped.")
      NotificationEmailJob.perform_later("OrderMailer", "shipped", order)
    elsif statuses.all?("packed")
      order.update!(status: "packed")
    elsif statuses.any?("processing")
      order.update!(status: "processing")
    end
  end

  def notify_customer!(order, title, body)
    Notification.create!(user: order.user, event_type: "order.fulfillment", title: title, body: body)
  end
end
