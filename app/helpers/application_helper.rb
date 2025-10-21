module ApplicationHelper
  # Role badge helper
  def role_badge(user)
    badge_class = case user.role
    when "admin", "manager"
      "badge-success"
    when "supervisor"
      "badge-info"
    when "employee"
      "badge-warning"
    else
      "badge-secondary"
    end

    content_tag :span, user.role.titleize, class: "badge #{badge_class}"
  end

  # Check if current user can perform action on specific location
  def can_operate_in_location?(location)
    return true if current_user.admin? || current_user.manager?
    return location == current_user.location if current_user.supervisor? || current_user.employee?
    false
  end

  # Display location with access indicator
  def location_with_access(location)
    if can_operate_in_location?(location)
      content_tag(:span, location.name, class: "location-accessible") +
        content_tag(:span, " ✓", style: "color: #38a169; margin-left: 0.25rem;", title: "You can operate in this location")
    else
      content_tag(:span, location.name, class: "location-view-only") +
        content_tag(:span, " 👁", style: "color: #718096; margin-left: 0.25rem;", title: "View only")
    end
  end

  # Permission check helpers for views
  def show_edit_button?(resource)
    can_edit?
  end

  def show_delete_button?(resource)
    can_delete?
  end

  def show_create_button?
    can_create?
  end

  # Stock status badge
  def stock_status_badge(product, location = nil)
    stock_quantity = if location
      product.stock_levels.find_by(location: location)&.current_quantity || 0
    else
      product.total_stock
    end

    if stock_quantity == 0
      content_tag :span, "Out of Stock", class: "badge badge-danger"
    elsif stock_quantity < product.reorder_point
      content_tag :span, "Low Stock", class: "badge badge-warning"
    else
      content_tag :span, "In Stock", class: "badge badge-success"
    end
  end

  # Format currency
  def currency(amount)
    number_to_currency(amount, precision: 2)
  end

  # User scope indicator
  def user_scope_indicator
    return unless logged_in?

    if current_user.admin? || current_user.manager?
      content_tag :div, class: "scope-indicator scope-all" do
        "🌐 All Locations"
      end
    elsif current_user.supervisor? || current_user.employee?
      content_tag :div, class: "scope-indicator scope-single" do
        "📍 #{current_user.location&.name || "No Location Assigned"}"
      end
    elsif current_user.guest?
      content_tag :div, class: "scope-indicator scope-readonly" do
        "👁 View Only Access"
      end
    end
  end

  # Permission message helper
  def permission_message(action)
    case action
    when :create
      "You need supervisor or higher permissions to create records."
    when :edit
      "You need supervisor or higher permissions to edit records."
    when :delete
      "You need manager or admin permissions to delete records."
    when :manage_users
      "Only managers can assign user roles."
    when :sales
      "Guests cannot make sales. Please contact a manager to upgrade your account."
    else
      "You don't have permission to perform this action."
    end
  end
end
