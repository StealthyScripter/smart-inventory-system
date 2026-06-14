require "rails_helper"

RSpec.describe User, type: :model do
  it "normalizes legacy roles into the inventory hierarchy" do
    user = User.create!(
      first_name: "Legacy",
      last_name: "Manager",
      email: "legacy.manager@example.com",
      role: "manager",
      password: "password123",
      password_confirmation: "password123"
    )

    expect(user.role).to eq("regional_manager")
    expect(user.regional_manager?).to be(true)
  end

  it "requires a location for scoped inventory roles" do
    user = User.new(
      first_name: "Department",
      last_name: "Lead",
      email: "department.lead@example.com",
      role: "department_manager",
      password: "password123",
      password_confirmation: "password123"
    )

    expect(user).not_to be_valid
    expect(user.errors[:location]).to include("must be assigned for department_manager role")
  end

  it "records a durable audit log when the role changes" do
    user = User.create!(
      first_name: "Audit",
      last_name: "User",
      email: "audit.user@example.com",
      role: "customer",
      password: "password123",
      password_confirmation: "password123"
    )

    expect do
      user.update!(role: "client")
    end.to change(AuditLog, :count).by(1)

    audit_log = AuditLog.last
    expect(audit_log.actor).to eq(user)
    expect(audit_log.auditable).to eq(user)
    expect(audit_log.action).to eq("user.role_changed")
    expect(audit_log.parsed_details).to include("from" => "customer", "to" => "client")
  end
end
