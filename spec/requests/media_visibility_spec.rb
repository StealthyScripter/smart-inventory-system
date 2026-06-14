require "rails_helper"

RSpec.describe "Media visibility", type: :request do
  let!(:category) { Category.create!(name: "Media Visibility Category") }
  let!(:supplier) { Supplier.create!(name: "Media Visibility Merchant", default_lead_time_days: 7) }
  let!(:public_product) do
    Product.create!(name: "Visible Media Product", sku: "VISIBLE-MEDIA", category: category, supplier: supplier, marketplace_status: "public")
  end
  let!(:private_product) do
    Product.create!(name: "Hidden Media Product", sku: "HIDDEN-MEDIA", category: category, supplier: supplier, marketplace_status: "private")
  end

  before do
    public_product.featured_image.attach(image_blob("public.jpg"))
    private_product.featured_image.attach(image_blob("private.jpg"))
  end

  it "shows attachments on public product pages" do
    get catalog_product_path(public_product)

    expect(response).to have_http_status(:success)
    expect(response.body).to include("public.jpg")
  end

  it "does not expose attached private products" do
    get catalog_product_path(private_product)

    expect(response).to have_http_status(:not_found)
  end

  def image_blob(filename)
    {
      io: StringIO.new("fake image"),
      filename: filename,
      content_type: "image/jpeg"
    }
  end
end
