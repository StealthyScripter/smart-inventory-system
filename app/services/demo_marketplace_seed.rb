class DemoMarketplaceSeed
  def self.call
    new.call
  end

  def call
    seed_locations
    seed_categories
    seed_users
    seed_suppliers
    link_supplier_users
    seed_products
    seed_services
    seed_marketplace_tags
    seed_orders
    seed_bookings
    seed_notifications
  end

  private

  attr_reader :locations, :categories, :users, :suppliers, :products, :services

  def seed_locations
    @locations = {
      warehouse: upsert_location("Marketplace Demo Warehouse", "410 Builder Supply Ave, Raleigh, NC"),
      downtown: upsert_location("Marketplace Pickup Counter", "88 Contractor Row, Raleigh, NC")
    }
  end

  def seed_categories
    @categories = {
      materials: upsert_category("Building Materials", "Core construction materials"),
      paint: upsert_category("Paint", "Interior and exterior coatings"),
      plumbing: upsert_category("Plumbing", "Pipes, valves, and fixtures"),
      electrical: upsert_category("Electrical", "Electrical fittings and job-site components")
    }
  end

  def seed_users
    @users = {
      hardware: upsert_user("merchant.hardware@example.com", "Harper", "Hardware", "supplier"),
      construction: upsert_user("merchant.construction@example.com", "Casey", "Construction", "supplier"),
      interiors: upsert_user("merchant.interiors@example.com", "Indigo", "Interiors", "supplier"),
      electrical: upsert_user("merchant.electrical@example.com", "Elliot", "Electrical", "supplier"),
      plumbing: upsert_user("merchant.plumbing@example.com", "Parker", "Plumbing", "supplier"),
      ac: upsert_user("merchant.ac@example.com", "Avery", "Cooling", "supplier"),
      hardware_employee: upsert_user("merchant.hardware.employee@example.com", "Hayden", "Associate", "supplier"),
      buyer: upsert_user("buyer.contractor@example.com", "Blake", "Contractor", "customer"),
      buyer_two: upsert_user("buyer.designer@example.com", "Drew", "Designer", "customer")
    }
  end

  def seed_suppliers
    @suppliers = {
      hardware: upsert_supplier("Oak City Hardware", "Hardware store for fast-moving job-site supplies", "hardware tools fasteners"),
      construction: upsert_supplier("Triangle Construction Supply", "Bulk construction materials and structural stock", "cement steel aggregate"),
      interiors: upsert_supplier("Modern Nest Interiors", "Interior design and finish selection studio", "interior design finishes"),
      electrical: upsert_supplier("BrightLine Electrical Contractors", "Licensed electrical installation provider", "electrical wiring fittings"),
      plumbing: upsert_supplier("BluePipe Plumbing Company", "Commercial and residential plumbing services", "plumbing pipes repair"),
      ac: upsert_supplier("CoolAir AC Services", "AC installation, repair, and preventive maintenance", "ac hvac cooling")
    }
  end

  def link_supplier_users
    suppliers.each do |key, supplier|
      next if key == :hardware_employee

      SupplierUser.find_or_create_by!(supplier: supplier, user: users.fetch(key))
    end
    SupplierUser.find_or_create_by!(supplier: suppliers[:hardware], user: users[:hardware_employee])
  end

  def seed_products
    @products = {
      cement: upsert_product("DEMO-CEMENT-50", "Portland Cement 50kg", categories[:materials], suppliers[:construction], 8.50, 12.00, "cement concrete masonry"),
      steel: upsert_product("DEMO-STEEL-12MM", "12mm Steel Rebar", categories[:materials], suppliers[:construction], 5.00, 7.25, "steel rebar reinforcement"),
      paint: upsert_product("DEMO-PAINT-WHITE", "Exterior White Paint 20L", categories[:paint], suppliers[:hardware], 42.00, 65.00, "paint coating exterior"),
      pipes: upsert_product("DEMO-PVC-PIPE", "PVC Pipe 2 inch", categories[:plumbing], suppliers[:plumbing], 3.20, 5.50, "pipes plumbing pvc"),
      fittings: upsert_product("DEMO-ELEC-FITTING", "Electrical Conduit Fittings Pack", categories[:electrical], suppliers[:electrical], 9.00, 14.75, "electrical fittings conduit")
    }

    products.each_value { |product| stock_product(product) }
  end

  def seed_services
    @services = {
      interior: upsert_service(suppliers[:interiors], "Interior Design Consultation", "Interior design", 250, "space planning finishes moodboard"),
      plumbing: upsert_service(suppliers[:plumbing], "Emergency Plumbing Repair", "Plumbing", 120, "leak repair pipes"),
      electrical: upsert_service(suppliers[:electrical], "Electrical Installation", "Electrical", 180, "wiring panel conduit"),
      ac: upsert_service(suppliers[:ac], "AC Repair Visit", "AC services", 140, "hvac cooling repair"),
      painting: upsert_service(suppliers[:hardware], "Exterior Painting Crew", "Painting", 600, "paint exterior labor")
    }
  end

  def seed_marketplace_tags
    assign_marketplace_tag(products.values, "category", "Project essentials", "Materials and supplies for active projects", 10)
    assign_marketplace_tag(services.values, "service", "Project services", "Professional help for repairs and improvements", 20)
    assign_marketplace_tag(suppliers.values, "supplier", "Trusted local merchants", "Established storefronts serving local projects", 30)
  end

  def seed_orders
    completed = upsert_order("DEMO-COMPLETE-001", users[:buyer], "delivered", 89.50)
    pending = upsert_order("DEMO-PENDING-001", users[:buyer_two], "confirmed", 65.00)

    completed_item = upsert_order_item(completed, products[:cement], suppliers[:construction], 5, 12.00, "delivered")
    upsert_order_item(completed, products[:fittings], suppliers[:electrical], 2, 14.75, "delivered")
    upsert_order_item(pending, products[:paint], suppliers[:hardware], 1, 65.00, "processing")

    upsert_payment(completed, "paid")
    upsert_payment(pending, "pending")
    upsert_review(completed_item)
  end

  def seed_bookings
    booking = ServiceBooking.find_or_initialize_by(booking_number: "DEMO-BOOKING-001")
    booking.update!(
      user: users[:buyer],
      supplier: suppliers[:interiors],
      status: "scheduled",
      scheduled_date: Date.current + 7.days,
      scheduled_time: Time.zone.parse("10:00"),
      duration_minutes: 120,
      notes: "Demo interior design consultation for a commercial lobby."
    )
    ServiceBookingItem.find_or_create_by!(service_booking: booking, service_listing: services[:interior]) do |item|
      item.quoted_price = services[:interior].starting_price
    end
  end

  def seed_notifications
    Notification.find_or_create_by!(
      user: users[:buyer],
      event_type: "demo.marketplace",
      title: "Demo marketplace order delivered"
    ) do |notification|
      notification.body = "Your demo construction supply order was delivered."
    end

    AccountBackfill.call
  end

  def upsert_location(name, address)
    Location.find_or_initialize_by(name: name).tap { |location| location.update!(address: address) }
  end

  def upsert_category(name, description)
    Category.find_or_initialize_by(name: name).tap { |category| category.update!(description: description) }
  end

  def assign_marketplace_tag(records, context, name, description, position)
    tag = Tag.find_or_initialize_by(context: context, slug: name.parameterize)
    tag.update!(
      name: name,
      description: description,
      marketplace_section: true,
      position: position
    )
    records.each { |record| tag.taggings.find_or_create_by!(taggable: record) }
  end

  def upsert_user(email, first_name, last_name, role)
    User.find_or_initialize_by(email: email).tap do |user|
      user.update!(
        first_name: first_name,
        last_name: last_name,
        role: role,
        password: demo_credential,
        password_confirmation: demo_credential
      )
    end
  end

  def demo_credential
    ENV.fetch("DEMO_SEED_CREDENTIAL", "password123")
  end

  def upsert_supplier(name, description, tags)
    Supplier.find_or_initialize_by(name: name).tap do |supplier|
      supplier.update!(
        contact_email: "#{name.parameterize}@marketplace.example",
        contact_phone: "(555) 010-#{format('%04d', name.length * 17)}",
        address: "Demo Marketplace District",
        default_lead_time_days: 5,
        shop_status: "public",
        shop_description: description,
        shop_slug: name.parameterize,
        search_tags: tags
      )
    end
  end

  def upsert_product(sku, name, category, supplier, unit_cost, selling_price, tags)
    Product.find_or_initialize_by(sku: sku).tap do |product|
      product.update!(
        name: name,
        category: category,
        supplier: supplier,
        unit_cost: unit_cost,
        selling_price: selling_price,
        reorder_point: 10,
        lead_time_days: supplier.default_lead_time_days,
        marketplace_status: "public",
        listing_scope: "both",
        description: "Demo marketplace listing for #{name.downcase}.",
        search_tags: tags
      )
    end
  end

  def stock_product(product)
    [locations[:warehouse], locations[:downtown]].each_with_index do |location, index|
      StockLevel.find_or_initialize_by(product: product, location: location).update!(
        current_quantity: 25 - (index * 10),
        reserved_quantity: index
      )
    end
  end

  def upsert_service(supplier, name, category, price, tags)
    ServiceListing.find_or_initialize_by(supplier: supplier, name: name).tap do |service|
      service.update!(
        service_category: category,
        status: "public",
        starting_price: price,
        description: "Demo bookable service for #{category.downcase}.",
        image_url: "https://example.com/#{name.parameterize}.jpg",
        search_tags: tags
      )
    end
  end

  def upsert_order(number, user, status, total)
    Order.find_or_initialize_by(order_number: number).tap do |order|
      order.update!(user: user, status: status, total_amount: total, submitted_at: Time.current - 3.days)
    end
  end

  def upsert_order_item(order, product, supplier, quantity, unit_price, status)
    OrderItem.find_or_initialize_by(order: order, product: product).tap do |item|
      item.update!(
        supplier: supplier,
        quantity: quantity,
        unit_price: unit_price,
        total_amount: quantity * unit_price,
        fulfillment_status: status
      )
    end
  end

  def upsert_payment(order, status)
    Payment.find_or_initialize_by(order: order, provider_reference: "demo_#{order.order_number.downcase}").tap do |payment|
      payment.update!(provider: "manual", amount: order.total_amount, currency: "USD", status: status)
    end
  end

  def upsert_review(order_item)
    Review.find_or_create_by!(user: order_item.order.user, order_item: order_item) do |review|
      review.product = order_item.product
      review.supplier = order_item.supplier
      review.rating = 5
      review.body = "Reliable demo delivery and product quality."
    end
  end
end
