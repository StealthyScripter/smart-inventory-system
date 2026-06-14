require "rails_helper"

RSpec.describe "Services marketplace", type: :request do
  let!(:supplier) { Supplier.create!(name: "Service Provider", default_lead_time_days: 7) }
  let!(:other_supplier) { Supplier.create!(name: "Other Provider", default_lead_time_days: 7) }
  let!(:merchant) { create_authenticated_user(role: "supplier", email: "service.merchant@example.com") }

  before do
    SupplierUser.create!(supplier: supplier, user: merchant)
  end

  it "allows merchants to create services for their supplier" do
    login_as(merchant)

    expect do
      post merchant_services_path, params: {
        service_listing: {
          supplier_id: supplier.id,
          name: "Interior design consultation",
          service_category: "Interior design",
          description: "Room planning",
          starting_price: 150,
          status: "public",
          image_url: "https://example.com/design.jpg"
        }
      }
    end.to change(ServiceListing, :count).by(1)

    expect(ServiceListing.last.supplier).to eq(supplier)
    expect(response).to redirect_to(merchant_services_path)
  end

  it "prevents merchants from creating services for another supplier" do
    login_as(merchant)

    expect do
      post merchant_services_path, params: {
        service_listing: {
          supplier_id: other_supplier.id,
          name: "Bad Service",
          service_category: "Plumbing",
          status: "public"
        }
      }
    end.not_to change(ServiceListing, :count)

    expect(response).to have_http_status(:unprocessable_content)
  end

  it "lists public services and supports category search" do
    public_service = ServiceListing.create!(
      supplier: supplier,
      name: "Emergency Plumbing",
      service_category: "Plumbing",
      status: "public",
      starting_price: 75
    )
    ServiceListing.create!(supplier: supplier, name: "Draft Plumbing", service_category: "Plumbing", status: "draft")

    get services_path, params: { q: "Emergency", category: "Plumbing" }

    expect(response.body).to include(public_service.name)
    expect(response.body).not_to include("Draft Plumbing")
  end

  it "shows public service details and provider profile links" do
    service = ServiceListing.create!(supplier: supplier, name: "AC Tuneup", service_category: "AC services", status: "public")

    get service_path(service)

    expect(response).to have_http_status(:success)
    expect(response.body).to include("AC Tuneup")
    expect(response.body).to include(supplier.name)
  end

  it "shows public services on merchant storefronts" do
    service = ServiceListing.create!(supplier: supplier, name: "Roof Inspection", service_category: "Roofing", status: "public")

    get merchant_storefront_path(supplier)

    expect(response.body).to include(service.name)
  end
end
