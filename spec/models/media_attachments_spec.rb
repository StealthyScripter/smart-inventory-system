require "rails_helper"

RSpec.describe "Media attachments", type: :model do
  let!(:category) { Category.create!(name: "Media Category") }
  let!(:supplier) { Supplier.create!(name: "Media Merchant", default_lead_time_days: 7) }
  let!(:customer) { create_user(role: "customer", email: "media.customer@example.com") }
  let!(:product) { Product.create!(name: "Media Product", sku: "MEDIA-PRODUCT", category: category, supplier: supplier) }
  let!(:service) { ServiceListing.create!(supplier: supplier, name: "Media Service", service_category: "Painting", status: "public") }

  it "attaches product images" do
    product.featured_image.attach(image_blob("featured.jpg"))
    product.images.attach(image_blob("gallery.jpg"))

    expect(product.featured_image).to be_attached
    expect(product.images.count).to eq(1)
  end

  it "attaches service galleries and before/after images" do
    service.gallery_images.attach(image_blob("gallery.jpg"))
    service.before_images.attach(image_blob("before.jpg"))
    service.after_images.attach(image_blob("after.jpg"))

    expect(service.gallery_images.count).to eq(1)
    expect(service.before_images.count).to eq(1)
    expect(service.after_images.count).to eq(1)
  end

  it "attaches merchant logo and banner" do
    supplier.logo.attach(image_blob("logo.jpg"))
    supplier.banner.attach(image_blob("banner.jpg"))

    expect(supplier.logo).to be_attached
    expect(supplier.banner).to be_attached
  end

  it "attaches review photos" do
    order = Order.create!(user: customer, status: "delivered", total_amount: 1)
    item = order.order_items.create!(
      product: product,
      supplier: supplier,
      quantity: 1,
      unit_price: 1,
      total_amount: 1,
      fulfillment_status: "delivered"
    )
    review = Review.create!(user: customer, product: product, supplier: supplier, order_item: item, rating: 5)

    review.photos.attach(image_blob("review.jpg"))

    expect(review.photos.count).to eq(1)
  end

  it "rejects non-image product attachments" do
    product.featured_image.attach(
      io: StringIO.new("plain text"),
      filename: "notes.txt",
      content_type: "text/plain"
    )

    expect(product).not_to be_valid
    expect(product.errors[:featured_image]).to include("must be an image")
  end

  def image_blob(filename)
    {
      io: StringIO.new("fake image"),
      filename: filename,
      content_type: "image/jpeg"
    }
  end

  def create_user(attributes = {})
    User.create!(
      {
        first_name: "Media",
        last_name: "User",
        email: "media#{rand(1000..9999)}@example.com",
        role: "customer",
        password: "password123",
        password_confirmation: "password123"
      }.merge(attributes)
    )
  end
end
