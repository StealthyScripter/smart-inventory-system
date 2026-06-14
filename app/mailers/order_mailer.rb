class OrderMailer < ApplicationMailer
  def shipped(order)
    @order = order
    mail(to: order.user.email, subject: "Order #{order.order_number} shipped")
  end

  def delivered(order)
    @order = order
    mail(to: order.user.email, subject: "Order #{order.order_number} delivered")
  end
end
