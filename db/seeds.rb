# This file ensures the existence of records required to run the application
# in every environment (production, development, test).
# The code here is idempotent and can be executed at any point.

puts "\n🌱 Starting seed process...\n"

# ========================
# Create Categories
# ========================
puts "\n📦 Creating categories..."
electronics = Category.find_or_initialize_by(name: "Electronics")
electronics.update!(description: "Electronic devices and gadgets")

accessories = Category.find_or_initialize_by(name: "Accessories")
accessories.update!(description: "Device accessories and peripherals")

computing = Category.find_or_initialize_by(name: "Computing")
computing.update!(description: "Computers and computing devices")

home_appliances = Category.find_or_initialize_by(name: "Home Appliances")
home_appliances.update!(description: "Home and kitchen appliances")

puts "   ✓ Created #{Category.count} categories"

# ========================
# Create Suppliers
# ========================
puts "\n🏢 Creating suppliers..."
apple = Supplier.find_or_initialize_by(name: "Apple Inc.")
apple.update!(
  contact_email: "orders@apple.com",
  contact_phone: "(800) 555-0123",
  address: "One Apple Park Way, Cupertino, CA 95014",
  default_lead_time_days: 7
)

samsung = Supplier.find_or_initialize_by(name: "Samsung Electronics")
samsung.update!(
  contact_email: "b2b@samsung.com",
  contact_phone: "(800) 555-0456",
  address: "Samsung Plaza, Seoul, South Korea",
  default_lead_time_days: 10
)

microsoft = Supplier.find_or_initialize_by(name: "Microsoft Corp.")
microsoft.update!(
  contact_email: "enterprise@microsoft.com",
  contact_phone: "(800) 555-0789",
  address: "One Microsoft Way, Redmond, WA 98052",
  default_lead_time_days: 5
)

sony = Supplier.find_or_initialize_by(name: "Sony Corporation")
sony.update!(
  contact_email: "business@sony.com",
  contact_phone: "(800) 555-1234",
  address: "Sony Building, Tokyo, Japan",
  default_lead_time_days: 14
)

puts "   ✓ Created #{Supplier.count} suppliers"

# ========================
# Create Admin and Manager Users (no location required)
# ========================
puts "\n👥 Creating users..."

admin = User.find_or_initialize_by(email: "admin@inventory.com")
admin.update!(
  first_name: "System",
  last_name: "Administrator",
  role: "admin",
  password: "password123",
  password_confirmation: "password123"
)

manager = User.find_or_initialize_by(email: "manager@inventory.com")
manager.update!(
  first_name: "Sarah",
  last_name: "Johnson",
  role: "manager",
  password: "password123",
  password_confirmation: "password123"
)

puts "   ✓ Created admin and manager users"

# ========================
# Create Locations
# ========================
puts "\n📍 Creating locations..."
main_warehouse = Location.find_or_initialize_by(name: "Main Warehouse")
main_warehouse.update!(
  address: "1234 Industrial Blvd, Raleigh, NC 27601",
  manager: manager
)

downtown_store = Location.find_or_initialize_by(name: "Downtown Store")
downtown_store.update!(
  address: "567 Fayetteville St, Raleigh, NC 27601"
)

north_raleigh_store = Location.find_or_initialize_by(name: "North Raleigh Store")
north_raleigh_store.update!(
  address: "890 Falls of Neuse Rd, Raleigh, NC 27609"
)

cary_store = Location.find_or_initialize_by(name: "Cary Store")
cary_store.update!(
  address: "123 Walnut St, Cary, NC 27511"
)

puts "   ✓ Created #{Location.count} locations"

# ========================
# Create Supervisors (require location)
# ========================
puts "\n👷 Creating supervisors and employees..."

supervisor_downtown = User.find_or_initialize_by(email: "supervisor.downtown@inventory.com")
supervisor_downtown.update!(
  first_name: "Michael",
  last_name: "Chen",
  role: "supervisor",
  location: downtown_store,
  password: "password123",
  password_confirmation: "password123"
)

supervisor_north = User.find_or_initialize_by(email: "supervisor.north@inventory.com")
supervisor_north.update!(
  first_name: "Jennifer",
  last_name: "Martinez",
  role: "supervisor",
  location: north_raleigh_store,
  password: "password123",
  password_confirmation: "password123"
)

# ========================
# Create Employees (require location)
# ========================
employee_downtown = User.find_or_initialize_by(email: "employee.downtown@inventory.com")
employee_downtown.update!(
  first_name: "David",
  last_name: "Wilson",
  role: "employee",
  location: downtown_store,
  password: "password123",
  password_confirmation: "password123"
)

employee_north = User.find_or_initialize_by(email: "employee.north@inventory.com")
employee_north.update!(
  first_name: "Emily",
  last_name: "Taylor",
  role: "employee",
  location: north_raleigh_store,
  password: "password123",
  password_confirmation: "password123"
)

employee_cary = User.find_or_initialize_by(email: "employee.cary@inventory.com")
employee_cary.update!(
  first_name: "James",
  last_name: "Anderson",
  role: "employee",
  location: cary_store,
  password: "password123",
  password_confirmation: "password123"
)

# ========================
# Create Guest User (no location required)
# ========================
guest = User.find_or_initialize_by(email: "guest@inventory.com")
guest.update!(
  first_name: "Guest",
  last_name: "User",
  role: "guest",
  password: "password123",
  password_confirmation: "password123"
)

# Update location managers
downtown_store.update!(manager: supervisor_downtown)
north_raleigh_store.update!(manager: supervisor_north)
cary_store.update!(manager: manager)

puts "   ✓ Created #{User.count} users total"

# ========================
# Create Products
# ========================
puts "\n📱 Creating products..."

# Apple Products
iphone15_pro = Product.find_or_initialize_by(sku: "IP15P-128-BLK")
iphone15_pro.update!(
  name: "iPhone 15 Pro 128GB Black",
  category: electronics,
  supplier: apple,
  unit_cost: 899.00,
  selling_price: 1099.00,
  reorder_point: 15,
  lead_time_days: 7,
  description: "Latest iPhone Pro with titanium design and A17 Pro chip"
)

iphone15 = Product.find_or_initialize_by(sku: "IP15-128-BLU")
iphone15.update!(
  name: "iPhone 15 128GB Blue",
  category: electronics,
  supplier: apple,
  unit_cost: 699.00,
  selling_price: 899.00,
  reorder_point: 20,
  lead_time_days: 7,
  description: "iPhone 15 with Dynamic Island and 48MP camera"
)

macbook_air = Product.find_or_initialize_by(sku: "MBA-M3-256-SLV")
macbook_air.update!(
  name: "MacBook Air M3 256GB Silver",
  category: computing,
  supplier: apple,
  unit_cost: 999.00,
  selling_price: 1199.00,
  reorder_point: 8,
  lead_time_days: 7,
  description: "Powerful and lightweight laptop with M3 chip"
)

airpods_pro = Product.find_or_initialize_by(sku: "APP-2ND-WHT")
airpods_pro.update!(
  name: "AirPods Pro 2nd Gen",
  category: accessories,
  supplier: apple,
  unit_cost: 199.00,
  selling_price: 249.00,
  reorder_point: 25,
  lead_time_days: 5,
  description: "Premium wireless earbuds with active noise cancellation"
)

ipad_air = Product.find_or_initialize_by(sku: "IPA-5TH-256-BLU")
ipad_air.update!(
  name: "iPad Air 5th Gen 256GB",
  category: electronics,
  supplier: apple,
  unit_cost: 649.00,
  selling_price: 799.00,
  reorder_point: 12,
  lead_time_days: 7,
  description: "Versatile tablet with M1 chip"
)

# Samsung Products
galaxy_s24 = Product.find_or_initialize_by(sku: "GS24-256-GRY")
galaxy_s24.update!(
  name: "Samsung Galaxy S24 256GB",
  category: electronics,
  supplier: samsung,
  unit_cost: 699.00,
  selling_price: 899.00,
  reorder_point: 15,
  lead_time_days: 10,
  description: "Latest Galaxy flagship with AI features"
)

galaxy_buds = Product.find_or_initialize_by(sku: "GBPRO-2-BLK")
galaxy_buds.update!(
  name: "Galaxy Buds Pro 2",
  category: accessories,
  supplier: samsung,
  unit_cost: 179.00,
  selling_price: 229.00,
  reorder_point: 20,
  lead_time_days: 10,
  description: "Premium wireless earbuds with intelligent ANC"
)

# Microsoft Products
surface_laptop = Product.find_or_initialize_by(sku: "SL5-512-PLT")
surface_laptop.update!(
  name: "Surface Laptop 5 512GB",
  category: computing,
  supplier: microsoft,
  unit_cost: 1299.00,
  selling_price: 1599.00,
  reorder_point: 6,
  lead_time_days: 5,
  description: "Elegant and powerful Windows laptop"
)

xbox_controller = Product.find_or_initialize_by(sku: "XBOX-CTL-BLK")
xbox_controller.update!(
  name: "Xbox Wireless Controller",
  category: accessories,
  supplier: microsoft,
  unit_cost: 49.00,
  selling_price: 69.00,
  reorder_point: 30,
  lead_time_days: 5,
  description: "Wireless controller for Xbox and PC"
)

# Sony Products
wh1000xm5 = Product.find_or_initialize_by(sku: "WH1000XM5-BLK")
wh1000xm5.update!(
  name: "Sony WH-1000XM5 Headphones",
  category: accessories,
  supplier: sony,
  unit_cost: 299.00,
  selling_price: 399.00,
  reorder_point: 10,
  lead_time_days: 14,
  description: "Industry-leading noise canceling headphones"
)

puts "   ✓ Created #{Product.count} products"

# ========================
# Create Stock Levels
# ========================
puts "\n📊 Creating stock levels..."

products = [iphone15_pro, iphone15, macbook_air, airpods_pro, ipad_air,
            galaxy_s24, galaxy_buds, surface_laptop, xbox_controller, wh1000xm5]
locations = [main_warehouse, downtown_store, north_raleigh_store, cary_store]

products.each do |product|
  locations.each do |location|
    stock = StockLevel.find_or_initialize_by(product: product, location: location)

    # Set realistic stock quantities based on location type
    quantity = case location.name
    when "Main Warehouse"
      rand(80..150)  # Higher stock in warehouse
    when "Downtown Store"
      rand(15..40)   # Medium stock in busy store
    when "North Raleigh Store"
      rand(10..30)   # Lower stock in smaller store
    when "Cary Store"
      rand(8..25)    # Lower stock in smaller store
    else
      rand(5..20)
    end

    stock.current_quantity = quantity
    stock.reserved_quantity = rand(0..3)
    stock.save!
  end
end

# Create some low stock situations for testing alerts
low_stock_items = [
  { product: iphone15_pro, location: downtown_store, quantity: 3 },
  { product: galaxy_s24, location: cary_store, quantity: 5 },
  { product: macbook_air, location: north_raleigh_store, quantity: 2 }
]

low_stock_items.each do |item|
  stock = StockLevel.find_by(product: item[:product], location: item[:location])
  stock&.update!(current_quantity: item[:quantity])
end

puts "   ✓ Created #{StockLevel.count} stock level records"

# ========================
# Create Purchase Orders
# ========================
puts "\n📝 Creating purchase orders..."

# Recent completed order
po1 = PurchaseOrder.find_or_initialize_by(order_number: "PO-2025-001")
po1.update!(
  supplier: apple,
  user: manager,
  order_date: Date.current - 15.days,
  expected_delivery_date: Date.current - 8.days,
  status: "received"
)

# Add items to PO1
unless po1.purchase_order_items.any?
  po1.purchase_order_items.create!([
    { product: iphone15_pro, quantity: 20, unit_cost: 899.00, total_cost: 17980.00 },
    { product: airpods_pro, quantity: 30, unit_cost: 199.00, total_cost: 5970.00 },
    { product: ipad_air, quantity: 15, unit_cost: 649.00, total_cost: 9735.00 }
  ])
end

# Currently ordered
po2 = PurchaseOrder.find_or_initialize_by(order_number: "PO-2025-002")
po2.update!(
  supplier: samsung,
  user: manager,
  order_date: Date.current - 5.days,
  expected_delivery_date: Date.current + 5.days,
  status: "ordered"
)

unless po2.purchase_order_items.any?
  po2.purchase_order_items.create!([
    { product: galaxy_s24, quantity: 25, unit_cost: 699.00, total_cost: 17475.00 },
    { product: galaxy_buds, quantity: 40, unit_cost: 179.00, total_cost: 7160.00 }
  ])
end

# Pending order
po3 = PurchaseOrder.find_or_initialize_by(order_number: "PO-2025-003")
po3.update!(
  supplier: microsoft,
  user: manager,
  order_date: Date.current - 1.day,
  expected_delivery_date: Date.current + 4.days,
  status: "pending"
)

unless po3.purchase_order_items.any?
  po3.purchase_order_items.create!([
    { product: surface_laptop, quantity: 10, unit_cost: 1299.00, total_cost: 12990.00 },
    { product: xbox_controller, quantity: 50, unit_cost: 49.00, total_cost: 2450.00 }
  ])
end

puts "   ✓ Created #{PurchaseOrder.count} purchase orders"

# ========================
# Create Sales Transactions
# ========================
puts "\n💰 Creating sales transactions..."

# Recent sales from various locations and users
sales_data = [
  # Downtown Store sales
  { product: iphone15_pro, location: downtown_store, user: employee_downtown,
    customer: "Alice Johnson", quantity: 1, price: 1099.00, days_ago: 0, hours_ago: 2 },
  { product: airpods_pro, location: downtown_store, user: employee_downtown,
    customer: "Bob Smith", quantity: 2, price: 249.00, days_ago: 0, hours_ago: 4 },
  { product: galaxy_s24, location: downtown_store, user: supervisor_downtown,
    customer: "Carol Williams", quantity: 1, price: 899.00, days_ago: 0, hours_ago: 6 },

  # North Raleigh Store sales
  { product: macbook_air, location: north_raleigh_store, user: employee_north,
    customer: "David Brown", quantity: 1, price: 1199.00, days_ago: 0, hours_ago: 3 },
  { product: iphone15, location: north_raleigh_store, user: supervisor_north,
    customer: "Emma Davis", quantity: 1, price: 899.00, days_ago: 0, hours_ago: 5 },
  { product: wh1000xm5, location: north_raleigh_store, user: employee_north,
    customer: "Frank Miller", quantity: 1, price: 399.00, days_ago: 1, hours_ago: 2 },

  # Cary Store sales
  { product: ipad_air, location: cary_store, user: employee_cary,
    customer: "Grace Wilson", quantity: 1, price: 799.00, days_ago: 0, hours_ago: 1 },
  { product: xbox_controller, location: cary_store, user: employee_cary,
    customer: "Henry Martinez", quantity: 2, price: 69.00, days_ago: 1, hours_ago: 4 },

  # Yesterday's sales
  { product: iphone15_pro, location: downtown_store, user: employee_downtown,
    customer: "Isabel Garcia", quantity: 1, price: 1099.00, days_ago: 1, hours_ago: 8 },
  { product: surface_laptop, location: north_raleigh_store, user: supervisor_north,
    customer: "Jack Anderson", quantity: 1, price: 1599.00, days_ago: 1, hours_ago: 10 }
]

sales_data.each do |sale_info|
  # Check if sale already exists to avoid duplicates
  transaction_date = Time.current - sale_info[:days_ago].days - sale_info[:hours_ago].hours

  existing_sale = SalesTransaction.find_by(
    product: sale_info[:product],
    location: sale_info[:location],
    user: sale_info[:user],
    transaction_date: transaction_date.beginning_of_minute..transaction_date.end_of_minute
  )

  next if existing_sale

  total = sale_info[:quantity] * sale_info[:price]

  SalesTransaction.create!(
    product: sale_info[:product],
    location: sale_info[:location],
    user: sale_info[:user],
    customer_name: sale_info[:customer],
    quantity: sale_info[:quantity],
    unit_price: sale_info[:price],
    total_amount: total,
    transaction_date: transaction_date
  )

  # Update stock level (subtract sold quantity)
  stock_level = StockLevel.find_by(product: sale_info[:product], location: sale_info[:location])
  if stock_level && stock_level.current_quantity >= sale_info[:quantity]
    stock_level.decrement!(:current_quantity, sale_info[:quantity])

    # Create stock movement record
    StockMovement.create!(
      product: sale_info[:product],
      destination_location: sale_info[:location],
      movement_type: "sale",
      quantity: sale_info[:quantity],
      user: sale_info[:user],
      movement_date: transaction_date,
      notes: "Sale to #{sale_info[:customer]}"
    )
  end
end

puts "   ✓ Created #{SalesTransaction.count} sales transactions"

# ========================
# Create Demand Forecasts
# ========================
puts "\n📈 Creating demand forecasts..."

forecast_products = [iphone15_pro, galaxy_s24, macbook_air, airpods_pro]
forecast_locations = [downtown_store, north_raleigh_store]

forecast_products.each do |product|
  forecast_locations.each do |location|
    # Weekly forecast for next week
    forecast1 = DemandForecast.find_or_initialize_by(
      product: product,
      location: location,
      forecast_date: Date.current + 1.week,
      period_type: "weekly"
    )
    forecast1.update!(
      predicted_demand: rand(15.0..50.0).round(1),
      confidence_score: rand(0.75..0.95).round(2)
    )

    # Monthly forecast
    forecast2 = DemandForecast.find_or_initialize_by(
      product: product,
      location: location,
      forecast_date: Date.current.end_of_month + 1.day,
      period_type: "monthly"
    )
    forecast2.update!(
      predicted_demand: rand(60.0..200.0).round(1),
      confidence_score: rand(0.70..0.90).round(2)
    )
  end
end

puts "   ✓ Created #{DemandForecast.count} demand forecasts"

# ========================
# Summary Output
# ========================
puts "\n" + "="*60
puts "✅ SEED DATA SUMMARY"
puts "="*60
puts "Categories:           #{Category.count}"
puts "Suppliers:            #{Supplier.count}"
puts "Locations:            #{Location.count}"
puts "Users:                #{User.count}"
puts "  - Admin:            #{User.where(role: 'admin').count}"
puts "  - Manager:          #{User.where(role: 'manager').count}"
puts "  - Supervisor:       #{User.where(role: 'supervisor').count}"
puts "  - Employee:         #{User.where(role: 'employee').count}"
puts "  - Guest:            #{User.where(role: 'guest').count}"
puts "Products:             #{Product.count}"
puts "Stock Levels:         #{StockLevel.count}"
puts "Purchase Orders:      #{PurchaseOrder.count}"
puts "Purchase Order Items: #{PurchaseOrderItem.count}"
puts "Sales Transactions:   #{SalesTransaction.count}"
puts "Stock Movements:      #{StockMovement.count}"
puts "Demand Forecasts:     #{DemandForecast.count}"
puts "="*60

puts "\n🔐 DEFAULT LOGIN CREDENTIALS"
puts "="*60
puts "Admin:     admin@inventory.com           | password123"
puts "Manager:   manager@inventory.com         | password123"
puts "Supervisor: supervisor.downtown@inventory.com | password123"
puts "Supervisor: supervisor.north@inventory.com    | password123"
puts "Employee:  employee.downtown@inventory.com    | password123"
puts "Employee:  employee.north@inventory.com       | password123"
puts "Employee:  employee.cary@inventory.com        | password123"
puts "Guest:     guest@inventory.com           | password123"
puts "="*60

puts "\n✨ Seed process completed successfully!\n\n"
