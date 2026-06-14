require "rails_helper"

RSpec.describe "Real-world readiness services" do
  let!(:category) { Category.create!(name: "Ready Category") }
  let!(:supplier) { Supplier.create!(name: "Ready Supplier", default_lead_time_days: 7) }

  it "generates SKU and barcode values for products without a SKU" do
    product = Product.create!(name: "Ready Product", category: category, supplier: supplier)

    expect(product.sku).to start_with("REA-REA-REA-")
    expect(product.barcode_value).to eq(product.sku)
  end

  it "generates barcode and QR SVG output" do
    expect(CodeImageService.barcode_svg("ABC123")).to include("<svg", "ABC123")
    expect(CodeImageService.qr_svg("ABC123")).to include("<svg", "<rect")
  end

  it "generates lightweight PDF output" do
    pdf = SimplePdfRenderer.render("Receipt", ["Line one"])

    expect(pdf).to start_with("%PDF-1.4")
    expect(pdf).to include("%%EOF")
  end

  it "exports analytics CSV" do
    csv = AnalyticsCsvExport.call(sales_total: 10, order_count: 2)

    expect(csv).to include("metric,value", "sales_total,10")
  end
end
