require "rails_helper"

RSpec.describe DailyNotificationDigestJob, type: :job do
  include ActiveJob::TestHelper

  let!(:user) do
    User.create!(
      first_name: "Digest",
      last_name: "User",
      email: "digest.user@example.com",
      role: "customer",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  around do |example|
    clear_enqueued_jobs
    clear_performed_jobs
    ActionMailer::Base.deliveries.clear
    example.run
    clear_enqueued_jobs
    clear_performed_jobs
    ActionMailer::Base.deliveries.clear
  end

  it "enqueues on the notifications queue" do
    expect do
      described_class.perform_later(user)
    end.to have_enqueued_job(described_class).with(user).on_queue("notifications")
  end

  it "sends digest email for users with unread notifications" do
    user.notifications.create!(event_type: "digest.test", title: "Digest Item", body: "Needs attention")

    expect do
      described_class.perform_now(user)
    end.to change(ActionMailer::Base.deliveries, :count).by(1)

    expect(ActionMailer::Base.deliveries.last.body.encoded).to include("Digest Item")
  end
end
