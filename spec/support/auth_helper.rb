module AuthHelper
  def login_as(user)
    post login_path, params: {
      email: user.email,
      password: "password123"
    }
  end

  def create_authenticated_user(attributes = {})
    default_attributes = {
      first_name: "Test",
      last_name: "User",
      email: "test#{rand(1000..9999)}@example.com",
      role: "staff",
      password: "password123",
      password_confirmation: "password123"
    }

    User.create!(default_attributes.merge(attributes))
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end
