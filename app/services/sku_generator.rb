class SkuGenerator
  def self.call(product)
    new(product).call
  end

  def initialize(product)
    @product = product
  end

  def call
    prefix = [
      product.category&.name,
      product.supplier&.name,
      product.name
    ].compact.map { |value| value.parameterize.upcase.first(3) }.join("-")
    base = prefix.presence || "SKU"
    candidate = "#{base}-#{SecureRandom.hex(3).upcase}"
    candidate = "#{base}-#{SecureRandom.hex(3).upcase}" while Product.exists?(sku: candidate)
    candidate
  end

  private

  attr_reader :product
end
