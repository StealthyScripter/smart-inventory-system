module ApplicationHelper
  def role_badge(user)
    badge_class = case user.normalized_role
    when "admin"
      "badge-success"
    when "regional_manager"
      "badge-info"
    when "location_manager", "department_manager"
      "badge-warning"
    else
      "badge-secondary"
    end

    content_tag :span, user.role_name, class: "badge #{badge_class}"
  end

  def can_operate_in_location?(location)
    can_access_location?(location) && can_adjust_inventory?
  end

  def location_with_access(location)
    if can_operate_in_location?(location)
      content_tag(:span, location.name, class: "location-accessible") +
        content_tag(:span, " ✓", style: "color: #38a169; margin-left: 0.25rem;", title: "You can operate in this location")
    else
      content_tag(:span, location.name, class: "location-view-only") +
        content_tag(:span, " 👁", style: "color: #718096; margin-left: 0.25rem;", title: "View only")
    end
  end

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

  def currency(amount)
    number_to_currency(amount, precision: 2)
  end

  def user_scope_indicator
    return unless logged_in?

    if admin? || regional_manager?
      content_tag :div, class: "scope-indicator scope-all" do
        "🌐 All Locations"
      end
    elsif current_user.location.present? && (location_manager? || department_manager? || employee?)
      content_tag :div, class: "scope-indicator scope-single" do
        "📍 #{current_user.location&.name || "No Location Assigned"}"
      end
    elsif client? || supplier_user? || customer? || guest?
      content_tag :div, class: "scope-indicator scope-readonly" do
        "👁 Read-Only Access"
      end
    end
  end

  def permission_message(action)
    case action
    when :products
      "Only admins and regional managers can manage products."
    when :locations
      "Only admins and regional managers can manage locations."
    when :suppliers
      "Only admins and regional managers can manage suppliers."
    when :inventory
      "Only admins, regional managers, location managers, and department managers can adjust stock."
    when :delete
      "Only admins and regional managers can delete records."
    when :manage_users
      "Only admins and regional managers can assign user roles."
    else
      "You don't have permission to perform this action."
    end
  end
end
