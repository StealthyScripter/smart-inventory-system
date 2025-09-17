def index
  @suppliers = Supplier.all

  # Temporary plain text response to verify data
  render plain: "Found #{@suppliers.count} suppliers"
end
