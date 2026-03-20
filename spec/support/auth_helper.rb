module AuthHelper
  def login_as(user)
    post login_path, params: {
      email: user.email,
      password: "password123"
    }
  end

  def create_authenticated_user(attributes = {})
    normalized_role = User.normalize_role(attributes[:role] || "regional_manager")
    location = attributes[:location]
    location ||= Location.find_or_create_by!(name: "Test Location") if User::LOCATION_SCOPED_ROLES.include?(normalized_role)

    default_attributes = {
      first_name: "Test",
      last_name: "User",
      email: "test#{rand(1000..9999)}@example.com",
      role: normalized_role,
      location: location,
      password: "password123",
      password_confirmation: "password123"
    }.compact

    User.create!(default_attributes.merge(attributes))
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end
