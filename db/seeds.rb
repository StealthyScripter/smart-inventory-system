puts "\nSeeding inventory management data...\n"

categories = [
  { name: "Electronics", description: "Electronic devices and accessories" },
  { name: "Computing", description: "Computers and office technology" },
  { name: "Accessories", description: "Peripherals and device accessories" }
].map do |attributes|
  category = Category.find_or_initialize_by(name: attributes[:name])
  category.update!(attributes)
  category
end

suppliers = [
  {
    name: "Apple Business",
    contact_email: "orders@apple.example",
    contact_phone: "(800) 100-0001",
    address: "One Apple Park Way, Cupertino, CA",
    default_lead_time_days: 7
  },
  {
    name: "Samsung Distribution",
    contact_email: "b2b@samsung.example",
    contact_phone: "(800) 100-0002",
    address: "Samsung Plaza, Seoul",
    default_lead_time_days: 10
  },
  {
    name: "Microsoft Devices",
    contact_email: "enterprise@microsoft.example",
    contact_phone: "(800) 100-0003",
    address: "One Microsoft Way, Redmond, WA",
    default_lead_time_days: 5
  }
].map do |attributes|
  supplier = Supplier.find_or_initialize_by(name: attributes[:name])
  supplier.update!(attributes)
  supplier
end

locations = [
  { name: "Main Warehouse", address: "100 Storage Way, Raleigh, NC" },
  { name: "Downtown Store", address: "12 Market St, Raleigh, NC" },
  { name: "North Store", address: "55 Capital Blvd, Raleigh, NC" }
].map do |attributes|
  location = Location.find_or_initialize_by(name: attributes[:name])
  location.update!(address: attributes[:address])
  location
end

users = [
  {
    email: "admin@inventory.com",
    first_name: "System",
    last_name: "Admin",
    role: "admin"
  },
  {
    email: "regional.manager@inventory.com",
    first_name: "Riley",
    last_name: "Manager",
    role: "regional_manager"
  },
  {
    email: "downtown.manager@inventory.com",
    first_name: "Dana",
    last_name: "Store",
    role: "location_manager",
    location: locations[1]
  },
  {
    email: "north.manager@inventory.com",
    first_name: "Noah",
    last_name: "Store",
    role: "location_manager",
    location: locations[2]
  },
  {
    email: "warehouse.department@inventory.com",
    first_name: "Morgan",
    last_name: "Lead",
    role: "department_manager",
    location: locations[0]
  },
  {
    email: "employee@inventory.com",
    first_name: "Taylor",
    last_name: "Employee",
    role: "employee",
    location: locations[0]
  },
  {
    email: "client@inventory.com",
    first_name: "Casey",
    last_name: "Client",
    role: "client"
  },
  {
    email: "supplier.user@inventory.com",
    first_name: "Sam",
    last_name: "Supplier",
    role: "supplier"
  },
  {
    email: "customer@inventory.com",
    first_name: "Chris",
    last_name: "Customer",
    role: "customer"
  },
  {
    email: "guest@inventory.com",
    first_name: "Guest",
    last_name: "Viewer",
    role: "guest"
  }
].map do |attributes|
  user = User.find_or_initialize_by(email: attributes[:email])
  user.update!(
    first_name: attributes[:first_name],
    last_name: attributes[:last_name],
    role: attributes[:role],
    location: attributes[:location],
    password: "password123",
    password_confirmation: "password123"
  )
  user
end

locations[1].update!(manager: users[2])
locations[2].update!(manager: users[3])
locations[0].update!(manager: users[1])

products = [
  {
    sku: "IP15-128-BLK",
    name: "iPhone 15 128GB Black",
    category: categories[0],
    supplier: suppliers[0],
    unit_cost: 699.00,
    selling_price: 899.00,
    reorder_point: 12,
    lead_time_days: 7,
    description: "Core Apple smartphone inventory item"
  },
  {
    sku: "MBA-M3-256-SLV",
    name: "MacBook Air M3 256GB Silver",
    category: categories[1],
    supplier: suppliers[0],
    unit_cost: 999.00,
    selling_price: 1199.00,
    reorder_point: 6,
    lead_time_days: 7,
    description: "Popular lightweight laptop"
  },
  {
    sku: "GS24-256-GRY",
    name: "Galaxy S24 256GB Gray",
    category: categories[0],
    supplier: suppliers[1],
    unit_cost: 649.00,
    selling_price: 849.00,
    reorder_point: 10,
    lead_time_days: 10,
    description: "Android flagship handset"
  },
  {
    sku: "MXM-00001",
    name: "Surface Mouse",
    category: categories[2],
    supplier: suppliers[2],
    unit_cost: 29.00,
    selling_price: 49.00,
    reorder_point: 25,
    lead_time_days: 5,
    description: "Accessory item with frequent replenishment"
  }
].map do |attributes|
  product = Product.find_or_initialize_by(sku: attributes[:sku])
  product.update!(attributes)
  product
end

stock_matrix = {
  "Main Warehouse" => {
    "IP15-128-BLK" => 30,
    "MBA-M3-256-SLV" => 12,
    "GS24-256-GRY" => 20,
    "MXM-00001" => 60
  },
  "Downtown Store" => {
    "IP15-128-BLK" => 8,
    "MBA-M3-256-SLV" => 4,
    "GS24-256-GRY" => 6,
    "MXM-00001" => 18
  },
  "North Store" => {
    "IP15-128-BLK" => 10,
    "MBA-M3-256-SLV" => 3,
    "GS24-256-GRY" => 5,
    "MXM-00001" => 22
  }
}

stock_matrix.each do |location_name, sku_map|
  location = locations.find { |record| record.name == location_name }

  sku_map.each do |sku, quantity|
    product = products.find { |record| record.sku == sku }
    stock_level = StockLevel.find_or_initialize_by(product: product, location: location)
    stock_level.update!(current_quantity: quantity, reserved_quantity: 0)
  end
end

movement_samples = [
  {
    product: products[0],
    destination_location: locations[1],
    movement_type: "adjustment",
    quantity: 2,
    user: users[2],
    notes: "Cycle count correction at Downtown Store"
  },
  {
    product: products[2],
    destination_location: locations[2],
    movement_type: "adjustment",
    quantity: 1,
    user: users[3],
    notes: "Opening inventory reconciliation at North Store"
  },
  {
    product: products[3],
    destination_location: locations[0],
    movement_type: "adjustment",
    quantity: 5,
    user: users[4],
    notes: "Received accessory pallet into warehouse stock"
  }
]

movement_samples.each_with_index do |attributes, index|
  movement = StockMovement.find_or_initialize_by(
    product: attributes[:product],
    destination_location: attributes[:destination_location],
    movement_type: attributes[:movement_type],
    notes: attributes[:notes]
  )
  movement.update!(
    quantity: attributes[:quantity],
    user: attributes[:user],
    movement_date: Time.current - index.hours
  )
end

puts "Seed complete."
puts "Categories: #{Category.count}"
puts "Suppliers: #{Supplier.count}"
puts "Locations: #{Location.count}"
puts "Users: #{User.count}"
puts "Products: #{Product.count}"
puts "Stock Levels: #{StockLevel.count}"
puts "Stock Movements: #{StockMovement.count}"
