# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create Categories
electronics = Category.find_or_create_by!(name: "Electronics") do |category|
  category.description = "Electronic devices and gadgets"
end

accessories = Category.find_or_create_by!(name: "Accessories") do |category|
  category.description = "Device accessories and peripherals"
end

computing = Category.find_or_create_by!(name: "Computing") do |category|
  category.description = "Computers and computing devices"
end

# Create Suppliers
apple = Supplier.find_or_create_by!(name: "Apple Inc.") do |supplier|
  supplier.contact_email = "orders@apple.com"
  supplier.contact_phone = "(800) 555-0123"
  supplier.address = "One Apple Park Way, Cupertino, CA 95014"
  supplier.default_lead_time_days = 7
end

samsung = Supplier.find_or_create_by!(name: "Samsung Electronics") do |supplier|
  supplier.contact_email = "b2b@samsung.com"
  supplier.contact_phone = "(800) 555-0456"
  supplier.address = "Samsung Plaza, Seoul, South Korea"
  supplier.default_lead_time_days = 10
end

microsoft = Supplier.find_or_create_by!(name: "Microsoft Corp.") do |supplier|
  supplier.contact_email = "enterprise@microsoft.com"
  supplier.contact_phone = "(800) 555-0789"
  supplier.address = "One Microsoft Way, Redmond, WA 98052"
  supplier.default_lead_time_days = 5
end

# Create Users
john = User.find_or_create_by!(email: "john.doe@inventory.com") do |user|
  user.first_name = "John"
  user.last_name = "Doe"
  user.role = "manager"
end

jane = User.find_or_create_by!(email: "jane.smith@inventory.com") do |user|
  user.first_name = "Jane"
  user.last_name = "Smith"
  user.role = "staff"
end

bob = User.find_or_create_by!(email: "bob.johnson@inventory.com") do |user|
  user.first_name = "Bob"
  user.last_name = "Johnson"
  user.role = "manager"
end

# Create Locations
main_warehouse = Location.find_or_create_by!(name: "Main Warehouse") do |location|
  location.address = "1234 Industrial Blvd, City, ST 12345"
  location.manager = john
end

store_downtown = Location.find_or_create_by!(name: "Store #1 - Downtown") do |location|
  location.address = "567 Main St, City, ST 12345"
  location.manager = jane
end

store_mall = Location.find_or_create_by!(name: "Store #2 - Mall") do |location|
  location.address = "890 Shopping Center Dr, City, ST 12345"
  location.manager = bob
end

# Update users with locations
jane.update!(location: store_downtown)
bob.update!(location: store_mall)

# Create Products
iphone15 = Product.find_or_create_by!(sku: "IP15P-128-BLK") do |product|
  product.name = "iPhone 15 Pro 128GB Black"
  product.category = electronics
  product.supplier = apple
  product.unit_cost = 999.00
  product.selling_price = 1199.00
  product.reorder_point = 10
  product.lead_time_days = 7
  product.description = "Latest iPhone with advanced features"
end

macbook = Product.find_or_create_by!(sku: "MBA-M3-256-SLV") do |product|
  product.name = "MacBook Air M3 256GB Silver"
  product.category = computing
  product.supplier = apple
  product.unit_cost = 1099.00
  product.selling_price = 1299.00
  product.reorder_point = 5
  product.lead_time_days = 7
  product.description = "Powerful and lightweight laptop"
end

airpods = Product.find_or_create_by!(sku: "APP-2ND-WHT") do |product|
  product.name = "AirPods Pro 2nd Gen White"
  product.category = accessories
  product.supplier = apple
  product.unit_cost = 199.00
  product.selling_price = 249.00
  product.reorder_point = 20
  product.lead_time_days = 7
  product.description = "Premium wireless earbuds"
end

ipad_air = Product.find_or_create_by!(sku: "IPA-5TH-256-BLU") do |product|
  product.name = "iPad Air 5th Gen 256GB Blue"
  product.category = electronics
  product.supplier = apple
  product.unit_cost = 649.00
  product.selling_price = 749.00
  product.reorder_point = 15
  product.lead_time_days = 7
  product.description = "Versatile tablet for work and play"
end

# Create Stock Levels
[ iphone15, macbook, airpods, ipad_air ].each do |product|
  [ main_warehouse, store_downtown, store_mall ].each do |location|
    StockLevel.find_or_create_by!(product: product, location: location) do |stock|
      case location
      when main_warehouse
        stock.current_quantity = rand(50..100)
      when store_downtown
        stock.current_quantity = rand(10..30)
      when store_mall
        stock.current_quantity = rand(5..25)
      end
      stock.reserved_quantity = rand(0..3)
    end
  end
end

# Create some low stock situations for alerts
low_stock_product = StockLevel.find_by(product: iphone15, location: store_mall)
low_stock_product.update!(current_quantity: 3) if low_stock_product

# Create Purchase Orders
po1 = PurchaseOrder.find_or_create_by!(order_number: "PO-2024-001") do |po|
  po.supplier = apple
  po.user = john
  po.order_date = Date.current - 5.days
  po.expected_delivery_date = Date.current + 5.days
  po.status = "ordered"
  po.total_amount = 45890.00
end

po2 = PurchaseOrder.find_or_create_by!(order_number: "PO-2024-002") do |po|
  po.supplier = samsung
  po.user = john
  po.order_date = Date.current - 2.days
  po.expected_delivery_date = Date.current + 8.days
  po.status = "pending"
  po.total_amount = 28450.00
end

# Create Sales Transactions
SalesTransaction.find_or_create_by!(
  product: iphone15,
  location: store_downtown,
  user: jane,
  transaction_date: Time.current - 2.hours
) do |sale|
  sale.customer_name = "John Customer"
  sale.quantity = 1
  sale.unit_price = 1199.00
  sale.total_amount = 1199.00
end

SalesTransaction.find_or_create_by!(
  product: airpods,
  location: store_mall,
  user: bob,
  transaction_date: Time.current - 4.hours
) do |sale|
  sale.customer_name = "Jane Buyer"
  sale.quantity = 2
  sale.unit_price = 249.00
  sale.total_amount = 498.00
end

# Create Demand Forecasts
DemandForecast.find_or_create_by!(
  product: iphone15,
  location: store_downtown,
  forecast_date: Date.current + 1.week,
  period_type: "weekly"
) do |forecast|
  forecast.predicted_demand = 45.0
  forecast.confidence_score = 0.94
end

DemandForecast.find_or_create_by!(
  product: macbook,
  location: main_warehouse,
  forecast_date: Date.current + 1.week,
  period_type: "weekly"
) do |forecast|
  forecast.predicted_demand = 12.0
  forecast.confidence_score = 0.87
end

puts "Seed data created successfully!"
puts "Categories: #{Category.count}"
puts "Suppliers: #{Supplier.count}"
puts "Users: #{User.count}"
puts "Locations: #{Location.count}"
puts "Products: #{Product.count}"
puts "Stock Levels: #{StockLevel.count}"
puts "Purchase Orders: #{PurchaseOrder.count}"
puts "Sales Transactions: #{SalesTransaction.count}"
puts "Demand Forecasts: #{DemandForecast.count}"
