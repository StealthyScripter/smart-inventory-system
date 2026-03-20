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
end
