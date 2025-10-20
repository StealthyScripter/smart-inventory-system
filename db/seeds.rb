# This file ensures the existence of records required to run the application
# in every environment (production, development, test).
# The code here is idempotent and can be executed at any point.

# ========================
# Create Categories
# ========================
electronics = Category.find_or_initialize_by(name: "Electronics")
electronics.update!(description: "Electronic devices and gadgets")

accessories = Category.find_or_initialize_by(name: "Accessories")
accessories.update!(description: "Device accessories and peripherals")

computing = Category.find_or_initialize_by(name: "Computing")
computing.update!(description: "Computers and computing devices")

# ========================
# Create Suppliers
# ========================
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

# ========================
# Create or Update Users
# ========================
john = User.find_or_initialize_by(email: "john.doe@inventory.com")
john.update!(
  first_name: "John",
  last_name: "Doe",
  role: "manager",
  password: "password123",
  password_confirmation: "password123"
)

jane = User.find_or_initialize_by(email: "jane.smith@inventory.com")
jane.update!(
  first_name: "Jane",
  last_name: "Smith",
  role: "staff",
  password: "password123",
  password_confirmation: "password123"
)

bob = User.find_or_initialize_by(email: "bob.johnson@inventory.com")
bob.update!(
  first_name: "Bob",
  last_name: "Johnson",
  role: "manager",
  password: "password123",
  password_confirmation: "password123"
)

# ========================
# Create Locations
# ========================
main_warehouse = Location.find_or_initialize_by(name: "Main Warehouse")
main_warehouse.update!(
  address: "1234 Industrial Blvd, City, ST 12345",
  manager: john
)

store_downtown = Location.find_or_initialize_by(name: "Store #1 - Downtown")
store_downtown.update!(
  address: "567 Main St, City, ST 12345",
  manager: jane
)

store_mall = Location.find_or_initialize_by(name: "Store #2 - Mall")
store_mall.update!(
  address: "890 Shopping Center Dr, City, ST 12345",
  manager: bob
)

# Update users with their assigned locations
jane.update!(location: store_downtown)
bob.update!(location: store_mall)

# ========================
# Create Products
# ========================
iphone15 = Product.find_or_initialize_by(sku: "IP15P-128-BLK")
iphone15.update!(
  name: "iPhone 15 Pro 128GB Black",
  category: electronics,
  supplier: apple,
  unit_cost: 999.00,
  selling_price: 1199.00,
  reorder_point: 10,
  lead_time_days: 7,
  description: "Latest iPhone with advanced features"
)

macbook = Product.find_or_initialize_by(sku: "MBA-M3-256-SLV")
macbook.update!(
  name: "MacBook Air M3 256GB Silver",
  category: computing,
  supplier: apple,
  unit_cost: 1099.00,
  selling_price: 1299.00,
  reorder_point: 5,
  lead_time_days: 7,
  description: "Powerful and lightweight laptop"
)

airpods = Product.find_or_initialize_by(sku: "APP-2ND-WHT")
airpods.update!(
  name: "AirPods Pro 2nd Gen White",
  category: accessories,
  supplier: apple,
  unit_cost: 199.00,
  selling_price: 249.00,
  reorder_point: 20,
  lead_time_days: 7,
  description: "Premium wireless earbuds"
)

ipad_air = Product.find_or_initialize_by(sku: "IPA-5TH-256-BLU")
ipad_air.update!(
  name: "iPad Air 5th Gen 256GB Blue",
  category: electronics,
  supplier: apple,
  unit_cost: 649.00,
  selling_price: 749.00,
  reorder_point: 15,
  lead_time_days: 7,
  description: "Versatile tablet for work and play"
)

# ========================
# Create Stock Levels
# ========================
[ iphone15, macbook, airpods, ipad_air ].each do |product|
  [ main_warehouse, store_downtown, store_mall ].each do |location|
    stock = StockLevel.find_or_initialize_by(product: product, location: location)
    case location
    when main_warehouse
      stock.current_quantity ||= rand(50..100)
    when store_downtown
      stock.current_quantity ||= rand(10..30)
    when store_mall
      stock.current_quantity ||= rand(5..25)
    end
    stock.reserved_quantity ||= rand(0..3)
    stock.save!
  end
end

# Force a low stock alert
low_stock_product = StockLevel.find_by(product: iphone15, location: store_mall)
low_stock_product&.update!(current_quantity: 3)

# ========================
# Create Purchase Orders
# ========================
po1 = PurchaseOrder.find_or_initialize_by(order_number: "PO-2024-001")
po1.update!(
  supplier: apple,
  user: john,
  order_date: Date.current - 5.days,
  expected_delivery_date: Date.current + 5.days,
  status: "ordered",
  total_amount: 45890.00
)

po2 = PurchaseOrder.find_or_initialize_by(order_number: "PO-2024-002")
po2.update!(
  supplier: samsung,
  user: john,
  order_date: Date.current - 2.days,
  expected_delivery_date: Date.current + 8.days,
  status: "pending",
  total_amount: 28450.00
)

# ========================
# Create Sales Transactions
# ========================
sale1 = SalesTransaction.find_or_initialize_by(
  product: iphone15,
  location: store_downtown,
  user: jane,
  transaction_date: Time.current - 2.hours
)
sale1.update!(
  customer_name: "John Customer",
  quantity: 1,
  unit_price: 1199.00,
  total_amount: 1199.00
)

sale2 = SalesTransaction.find_or_initialize_by(
  product: airpods,
  location: store_mall,
  user: bob,
  transaction_date: Time.current - 4.hours
)
sale2.update!(
  customer_name: "Jane Buyer",
  quantity: 2,
  unit_price: 249.00,
  total_amount: 498.00
)

# ========================
# Create Demand Forecasts
# ========================
forecast1 = DemandForecast.find_or_initialize_by(
  product: iphone15,
  location: store_downtown,
  forecast_date: Date.current + 1.week,
  period_type: "weekly"
)
forecast1.update!(
  predicted_demand: 45.0,
  confidence_score: 0.94
)

forecast2 = DemandForecast.find_or_initialize_by(
  product: macbook,
  location: main_warehouse,
  forecast_date: Date.current + 1.week,
  period_type: "weekly"
)
forecast2.update!(
  predicted_demand: 12.0,
  confidence_score: 0.87
)

# ========================
# Summary Output
# ========================
puts "\n=== ✅ Seed Data Summary ==="
puts "Categories: #{Category.count}"
puts "Suppliers: #{Supplier.count}"
puts "Users: #{User.count}"
puts "Locations: #{Location.count}"
puts "Products: #{Product.count}"
puts "Stock Levels: #{StockLevel.count}"
puts "Purchase Orders: #{PurchaseOrder.count}"
puts "Sales Transactions: #{SalesTransaction.count}"
puts "Demand Forecasts: #{DemandForecast.count}"

puts "\n=== 👤 Default Login Credentials ==="
puts "Email: john.doe@inventory.com | Password: password123"
puts "Email: jane.smith@inventory.com | Password: password123"
puts "Email: bob.johnson@inventory.com | Password: password123"
puts "====================================\n"
