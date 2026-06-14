require "rails_helper"

RSpec.describe ServiceListing, type: :model do
  let(:supplier) { Supplier.create!(name: "Service Model Supplier", default_lead_time_days: 7) }

  it "validates supported service categories" do
    service = ServiceListing.new(supplier: supplier, name: "Unsupported", service_category: "Magic", status: "public")

    expect(service).not_to be_valid
    expect(service.errors[:service_category]).to be_present
  end
end
