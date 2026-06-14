class MerchantProductOperations
  class CSVImportError < StandardError; end

  CSV_HEADERS = %w[
    sku
    name
    description
    category
    supplier
    unit_cost
    selling_price
    reorder_point
    lead_time_days
    marketplace_status
    listing_scope
    search_tags
  ].freeze

  def initialize(suppliers, actor:)
    @suppliers = suppliers
    @actor = actor
  end

  def export_csv
    rows = [CSV_HEADERS]
    products.includes(:category, :supplier).order(:sku).find_each do |product|
      rows << CSV_HEADERS.map { |header| export_value(product, header) }
    end
    rows.map { |row| row.map { |value| csv_escape(value) }.join(",") }.join("\n")
  end

  def import_csv(io)
    result = { created: 0, updated: 0 }
    rows = parse_csv(io.read)
    headers = rows.shift
    validate_headers!(headers)
    rows.each do |values|
      raise CSVImportError, "malformed row" unless values.size == headers.size

      row = headers.zip(values).to_h
      attributes = product_attributes(row)
      product = products.find_or_initialize_by(sku: attributes[:sku])
      product.assign_attributes(attributes)
      product.new_record? ? result[:created] += 1 : result[:updated] += 1
      product.save!
    end
    result
  end

  def bulk_update!(product_ids:, marketplace_status: nil, listing_scope: nil)
    scoped_products = products.where(id: product_ids)
    attributes = {}.tap do |changes|
      changes[:marketplace_status] = marketplace_status if marketplace_status.present?
      changes[:listing_scope] = listing_scope if listing_scope.present?
    end
    scoped_products.update_all(attributes.merge(updated_at: Time.current)) if attributes.any?
    scoped_products.count
  end

  def duplicate!(product)
    raise ActiveRecord::RecordNotFound unless products.exists?(id: product.id)

    duplicate = product.dup
    duplicate.name = "#{product.name} Copy"
    duplicate.sku = next_copy_sku(product.sku)
    duplicate.barcode_value = duplicate.sku
    duplicate.marketplace_status = "draft"
    duplicate.save!
    product.stock_levels.find_each do |stock_level|
      duplicate.stock_levels.create!(
        location: stock_level.location,
        current_quantity: 0,
        reserved_quantity: 0
      )
    end
    duplicate
  end

  private

  attr_reader :suppliers, :actor

  def products
    Product.owned_by_suppliers(suppliers.select(:id))
  end

  def export_value(product, header)
    case header
    when "category"
      product.category.name
    when "supplier"
      product.supplier&.name
    else
      product.public_send(header)
    end
  end

  def product_attributes(row)
    validate_required_values!(row)
    supplier = suppliers.find_by!(name: row["supplier"])
    category = Category.find_or_create_by!(name: row["category"])
    {
      sku: row["sku"],
      name: row["name"],
      description: row["description"],
      category: category,
      supplier: supplier,
      unit_cost: row["unit_cost"],
      selling_price: row["selling_price"],
      reorder_point: row["reorder_point"].presence || 10,
      lead_time_days: row["lead_time_days"].presence || supplier.default_lead_time_days,
      marketplace_status: row["marketplace_status"].presence || "draft",
      listing_scope: row["listing_scope"].presence || "both",
      search_tags: row["search_tags"]
    }
  end

  def next_copy_sku(sku)
    base = "#{sku}-COPY"
    return base unless Product.exists?(sku: base)

    index = 2
    index += 1 while Product.exists?(sku: "#{base}-#{index}")
    "#{base}-#{index}"
  end

  def csv_escape(value)
    string = value.to_s
    return string unless string.match?(/[,"\n]/)

    "\"#{string.gsub('"', '""')}\""
  end

  def parse_csv(content)
    content.to_s.lines.map { |line| parse_csv_line(line.chomp) }.reject(&:empty?)
  end

  def parse_csv_line(line)
    fields = []
    field = +""
    quoted = false
    index = 0

    while index < line.length
      char = line[index]
      if char == '"' && quoted && line[index + 1] == '"'
        field << '"'
        index += 1
      elsif char == '"'
        quoted = !quoted
      elsif char == "," && !quoted
        fields << field
        field = +""
      else
        field << char
      end
      index += 1
    end

    raise CSVImportError, "unterminated quoted field" if quoted

    fields << field
  end

  def validate_headers!(headers)
    raise CSVImportError, "missing headers" if headers.blank?
    raise CSVImportError, "invalid headers" unless headers == CSV_HEADERS
  end

  def validate_required_values!(row)
    %w[sku name category supplier].each do |field|
      raise CSVImportError, "#{field} is required" if row[field].blank?
    end
  end
end
