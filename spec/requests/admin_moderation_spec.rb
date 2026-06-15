require "rails_helper"

RSpec.describe "Admin marketplace moderation", type: :request do
  let!(:admin) { create_authenticated_user(role: "admin", email: "moderation.admin@example.com") }
  let!(:customer) { create_authenticated_user(role: "customer", email: "moderation.customer@example.com") }
  let!(:category) { Category.create!(name: "Moderation Hardware") }
  let!(:supplier) { Supplier.create!(name: "Moderation Merchant", default_lead_time_days: 7, shop_status: "public") }
  let!(:product) do
    Product.create!(
      name: "Moderated Bolt",
      sku: "MOD-BOLT",
      category: category,
      supplier: supplier,
      marketplace_status: "public"
    )
  end
  let!(:service) { ServiceListing.create!(supplier: supplier, name: "Moderated Plumbing", service_category: "Plumbing", status: "public") }

  it "allows admins to access marketplace governance" do
    login_as(admin)

    get admin_moderation_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include(product.name, service.name, supplier.name)
  end

  it "blocks non-admin users from marketplace governance" do
    login_as(customer)

    get admin_moderation_path

    expect(response).to have_http_status(:forbidden)
  end

  it "tracks product moderation actions and hides listings" do
    login_as(admin)
    expect(product.marketplace_listing).to be_visible

    expect do
      post admin_moderation_actions_path, params: {
        moderation_action: {
          moderatable_type: "Product",
          moderatable_id: product.id,
          action_name: "hide",
          notes: "Unsafe listing"
        }
      }
    end.to change(ModerationAction, :count).by(1)

    expect(product.reload.marketplace_status).to eq("archived")
    expect(product.marketplace_listing.reload.status).to eq("hidden")
    expect(Product.publicly_listed).not_to include(product)
    expect(ModerationAction.last.actor).to eq(admin)
  end

  it "suspends merchants through audited moderation actions" do
    account = Account.create!(name: "Moderation Account", account_type: "enterprise_merchant")
    MerchantProfile.create!(account: account, supplier: supplier, display_name: supplier.name)
    login_as(admin)

    post admin_moderation_actions_path, params: {
      moderation_action: {
        moderatable_type: "Supplier",
        moderatable_id: supplier.id,
        action_name: "suspend"
      }
    }

    expect(supplier.reload.shop_status).to eq("paused")
    expect(account.reload.status).to eq("suspended")
    expect(ModerationAction.last.moderatable).to eq(supplier)
  end

  it "lets users submit reports and admins resolve them" do
    login_as(customer)

    expect do
      post reports_path, params: {
        report: {
          reportable_type: "Product",
          reportable_id: product.id,
          reason: "Incorrect information",
          details: "The listing looks wrong."
        }
      }
    end.to change(Report, :count).by(1)

    report = Report.last
    login_as(admin)

    expect do
      patch admin_report_path(report), params: { report: { status: "resolved" } }
    end.to change(ModerationAction, :count).by(1)

    expect(report.reload.status).to eq("resolved")
  end

  it "blocks non-admin moderation mutations" do
    login_as(customer)

    post admin_moderation_actions_path, params: {
      moderation_action: {
        moderatable_type: "Product",
        moderatable_id: product.id,
        action_name: "hide"
      }
    }

    expect(response).to have_http_status(:forbidden)
    expect(product.reload.marketplace_status).to eq("public")
  end
end
