class PaymentService
  def initialize(order)
    @order = order
  end

  def create_payment!(provider: "manual")
    PaymentProviders::Registry.fetch(provider).new.create_payment!(order)
  end

  def mark_paid!(payment)
    raise ArgumentError, "payment does not belong to order" unless payment.order == order
    raise ArgumentError, "payment is not pending" unless payment.status == "pending"

    Payment.transaction do
      payment.update!(status: "paid")
      order.update!(status: "confirmed")
    end
  end

  def mark_failed!(payment)
    raise ArgumentError, "payment does not belong to order" unless payment.order == order
    raise ArgumentError, "payment is not pending" unless payment.status == "pending"

    payment.update!(status: "failed")
  end

  private

  attr_reader :order
end
