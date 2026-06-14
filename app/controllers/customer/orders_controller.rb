module Customer
  class OrdersController < BaseController
    def index
      @orders = current_user.orders.includes(order_items: [:product, :supplier]).order(created_at: :desc)
    end

    def show
      @order = current_user.orders.includes(order_items: [:product, :supplier]).find(params[:id])
      respond_to do |format|
        format.html
        format.pdf do
          send_data order_pdf,
                    filename: "#{@order.order_number}.pdf",
                    type: "application/pdf",
                    disposition: "inline"
        end
      end
    end

    private

    def order_pdf
      lines = [
        "Customer: #{current_user.full_name}",
        "Status: #{@order.status.titleize}",
        "Total: #{helpers.currency(@order.total_amount.to_f)}"
      ] + @order.order_items.map do |item|
        "#{item.quantity} x #{item.product.name} - #{helpers.currency(item.total_amount.to_f)}"
      end
      SimplePdfRenderer.render("Invoice #{@order.order_number}", lines)
    end
  end
end
