require "rails_helper"

RSpec.describe NotificationEmailJob, type: :job do
  include ActiveJob::TestHelper

  let!(:customer) do
    User.create!(
      first_name: "Job",
      last_name: "Customer",
      email: "job.customer@example.com",
      role: "customer",
      password: "password123",
      password_confirmation: "password123"
    )
  end
  let!(:order) { Order.create!(user: customer, status: "shipped", total_amount: 10) }

  around do |example|
    clear_enqueued_jobs
    clear_performed_jobs
    ActionMailer::Base.deliveries.clear
    example.run
    clear_enqueued_jobs
    clear_performed_jobs
    ActionMailer::Base.deliveries.clear
  end

  it "enqueues notification email delivery" do
    expect do
      described_class.perform_later("OrderMailer", "shipped", order)
    end.to have_enqueued_job(described_class).with("OrderMailer", "shipped", order).on_queue("mailers")
  end

  it "uses the mailers queue" do
    expect(described_class.queue_name).to eq("mailers")
  end

  it "delivers through the requested mailer action" do
    expect do
      described_class.perform_now("OrderMailer", "shipped", order)
    end.to change(ActionMailer::Base.deliveries, :count).by(1)

    expect(ActionMailer::Base.deliveries.last.subject).to include(order.order_number, "shipped")
  end
end
