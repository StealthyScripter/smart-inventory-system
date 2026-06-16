module ApplicationHelper
  def account_theme_class
    return "theme-guest" unless logged_in?
    return "theme-enterprise-merchant" if current_merchant_account&.enterprise_merchant?
    return "theme-individual-merchant" if current_merchant_account&.individual_merchant?
    return "theme-customer" if current_user.customer? || current_customer_account&.customer?

    "theme-operator"
  end

  def sidebar_navigation_items
    if current_merchant_account.present? || (current_user.supplier_user? && current_user.suppliers.exists?)
      merchant_navigation_items
    elsif current_user.customer?
      customer_navigation_items
    else
      operator_navigation_items
    end
  end

  def customer_navigation_items
    [
      { label: "Home", path: catalog_path, active: current_page?(catalog_path) || current_page?(root_path), icon: :home },
      { label: "Shop", path: catalog_path, active: request.path.start_with?("/catalog"), icon: :catalog },
      { label: "Services", path: services_path, active: request.path.start_with?("/services"), icon: :services },
      { label: "Cart", path: cart_path, active: current_page?(cart_path), icon: :cart },
      { label: "Profile", path: customer_profile_path, active: request.path.start_with?("/customer/profile"), icon: :profile }
    ]
  end

  def merchant_navigation_items
    items = [
      { label: "Dashboard", path: merchant_root_path, active: current_page?(merchant_root_path), icon: :dashboard },
      { label: "Catalog", path: merchant_catalog_path, active: request.path.start_with?("/merchant/catalog"), icon: :catalog },
      { label: "Products", path: merchant_products_path, active: request.path.start_with?("/merchant/products"), icon: :products },
      { label: "Inventory", path: merchant_inventory_path, active: request.path.start_with?("/merchant/inventory"), icon: :inventory },
      { label: "Orders", path: merchant_orders_path, active: request.path.start_with?("/merchant/orders"), icon: :orders },
      { label: "Services", path: merchant_services_path, active: request.path.start_with?("/merchant/services"), icon: :services },
      { label: "Bookings", path: merchant_service_bookings_path, active: request.path.start_with?("/merchant/service_bookings"), icon: :bookings },
      { label: "Messages", path: merchant_conversations_path, active: request.path.start_with?("/merchant/conversations"), icon: :messages },
      { label: "Analytics", path: merchant_analytics_path, active: request.path.start_with?("/merchant/analytics"), icon: :analytics },
      { label: "Profile", path: merchant_profile_path, active: request.path.start_with?("/merchant/profile"), icon: :profile }
    ]

    if current_merchant_account&.enterprise_merchant? && can_manage_merchant?(:manage_locations)
      items.insert(4, { label: "Locations", path: locations_path, active: request.path.start_with?("/locations"), icon: :locations })
    end

    if current_merchant_account&.enterprise_merchant? && can_manage_merchant?(:manage_members)
      items << { label: "Team", path: merchant_members_path, active: request.path.start_with?("/merchant/members"), icon: :team }
    end

    items
  end

  def operator_navigation_items
    items = [
      { label: "Search", path: search_path, active: current_page?(search_path), icon: :search },
      { label: "Catalog", path: catalog_path, active: current_page?(catalog_path), icon: :catalog },
      { label: "Services", path: services_path, active: current_page?(services_path), icon: :services }
    ]

    if can_access_back_office?
      items += [
        { label: "Dashboard", path: dashboard_path, active: current_page?(dashboard_path), icon: :dashboard },
        { label: "Products", path: products_path, active: current_page?(products_path), icon: :products },
        { label: "Inventory", path: inventory_path, active: current_page?(inventory_path), icon: :inventory },
        { label: "Locations", path: locations_path, active: current_page?(locations_path), icon: :locations },
        { label: "Suppliers", path: suppliers_path, active: current_page?(suppliers_path), icon: :team }
      ]
    end

    items << { label: "Users", path: admin_users_path, active: current_page?(admin_users_path), icon: :team } if can_manage_users?
    items
  end

  def nav_icon_path(icon)
    {
      home: "M3 11l9-8 9 8v10h-6v-6H9v6H3V11z",
      search: "M9.5 3a6.5 6.5 0 015.18 10.43l4.45 4.44-1.41 1.41-4.44-4.45A6.5 6.5 0 119.5 3zm0 2a4.5 4.5 0 100 9 4.5 4.5 0 000-9z",
      catalog: "M7 4h10l1 4h3v2h-1l-1 10H5L4 10H3V8h3l1-4zm2 2l-.5 2h7L15 6H9z",
      services: "M22 19.59L20.59 21l-6.3-6.3a7 7 0 01-8.99-8.99l4.24 4.24 2.12-2.12-4.24-4.24a7 7 0 018.99 8.99L22 19.59z",
      cart: "M7 18c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm10 0c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zM7.2 14h7.45c.75 0 1.41-.41 1.75-1.03L20 6H5.21L4.27 4H1v2h2l3.6 7.59L5.25 16C4.52 17.33 5.48 19 7 19h12v-2H7l1.1-2z",
      dashboard: "M3 13h8V3H3v10zm0 8h8v-6H3v6zm10 0h8V11h-8v10zm0-18v6h8V3h-8z",
      products: "M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z",
      inventory: "M4 6H2v14c0 1.1.9 2 2 2h14v-2H4V6zm16-4H8c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-1 9H9V9h10v2zm-4 4H9v-2h6v2zm4-8H9V5h10v2z",
      locations: "M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z",
      orders: "M19 3H5c-1.1 0-2 .9-2 2v14l4-4h12c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2z",
      bookings: "M7 2v2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2h-2V2h-2v2H9V2H7zm12 8H5V8h14v2z",
      messages: "M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z",
      analytics: "M5 9.2h3V19H5V9.2zm5.5-4.2h3v14h-3V5zm5.5 7h3v7h-3v-7z",
      profile: "M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z",
      team: "M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5z"
    }.fetch(icon)
  end

  def safe_media_url?(url)
    return false if url.blank?
    return true if url.start_with?("/")

    uri = URI.parse(url)
    uri.host.in?(%w[127.0.0.1 localhost])
  rescue URI::InvalidURIError
    false
  end

  def status_badge_class(status)
    normalized = status.to_s.downcase

    case normalized
    when /active|paid|delivered|completed|accepted|published|public|available|read/
      "badge-success"
    when /pending|draft|requested|processing|scheduled|low|review/
      "badge-warning"
    when /cancelled|canceled|failed|suspended|hidden|private|out|rejected/
      "badge-danger"
    when /shipped|in_transit|unread|open/
      "badge-info"
    else
      "badge-secondary"
    end
  end

  def ui_initial(text)
    text.to_s.strip.first&.upcase || "S"
  end

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

  def page_number
    [params[:page].to_i, 1].max
  end

  def pagination_controls(collection)
    return if collection.size < 25 && page_number == 1

    content_tag :div, class: "pagination" do
      safe_join([
        (link_to("Previous", url_for(request.query_parameters.merge(page: page_number - 1)), class: "btn btn-secondary") if page_number > 1),
        content_tag(:span, "Page #{page_number}", class: "pagination-label"),
        (link_to("Next", url_for(request.query_parameters.merge(page: page_number + 1)), class: "btn btn-secondary") if collection.size >= 25)
      ].compact, " ")
    end
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
