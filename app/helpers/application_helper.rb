module ApplicationHelper
  def account_theme_class
    return "theme-guest" unless logged_in?
    return "theme-enterprise-merchant" if current_merchant_account&.enterprise_merchant?
    return "theme-individual-merchant" if current_merchant_account&.individual_merchant?
    return "theme-customer" if current_user&.customer? || current_customer_account&.customer?

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

  def marketplace_home_theme_class
    return "theme-enterprise" if current_merchant_account&.enterprise_merchant?
    return "theme-merchant" if current_merchant_account.present? || current_user&.supplier_user?

    "theme-customer"
  end

  def marketplace_home_account
    if logged_in?
      if current_customer_account.present? || current_user&.customer?
        {
          label: "Hi, #{current_user.first_name}",
          subtitle: "Account",
          path: customer_profile_path,
          aria_label: "Customer account"
        }
      elsif current_merchant_account.present? || current_user&.supplier_user?
        {
          label: "Merchant",
          subtitle: "Account",
          path: merchant_profile_path,
          aria_label: "Merchant account"
        }
      else
        {
          label: "Sign in",
          subtitle: "Account",
          path: login_path,
          aria_label: "Account"
        }
      end
    else
      {
        label: "Sign in",
        subtitle: "Account",
        path: login_path,
        aria_label: "Sign in / Account"
      }
    end
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

  def account_navigation?
    customer_navigation? || merchant_navigation?
  end

  def customer_navigation?
    customer? && current_merchant_account.blank?
  end

  def merchant_navigation?
    current_merchant_account.present? || legacy_supplier_merchant?
  end

  def enterprise_merchant_navigation?
    current_merchant_account&.enterprise_merchant?
  end

  def account_navigation_items
    if customer_navigation?
      [
        { label: "Home", path: root_path, icon: :home, active: current_page?(root_path) },
        { label: "Shop", path: catalog_path, icon: :catalog, active: request.path.start_with?("/catalog") },
        { label: "Services", path: services_path, icon: :services, active: request.path.start_with?("/services") },
        { label: "Cart", path: cart_path, icon: :cart, active: current_page?(cart_path) },
        { label: "Profile", path: customer_profile_path, icon: :profile, active: request.path.start_with?("/customer") }
      ]
    elsif merchant_navigation?
      items = [
        { label: "Dashboard", path: merchant_root_path, icon: :dashboard, active: current_page?(merchant_root_path) }
      ]
      if can_manage_merchant?(:manage_catalog)
        items << { label: "Catalog", path: merchant_catalog_path, icon: :catalog, active: request.path.start_with?("/merchant/catalog") }
        items << { label: "Products", path: merchant_products_path, icon: :products, active: request.path.start_with?("/merchant/products") }
      end
      if can_manage_merchant?(:view_inventory) || can_manage_merchant?(:manage_inventory)
        items << { label: "Inventory", path: merchant_inventory_path, icon: :inventory, active: request.path.start_with?("/merchant/inventory") }
      end
      if !can_manage_merchant?(:manage_catalog) && can_manage_merchant?(:view_orders)
        items << { label: "Orders", path: merchant_orders_path, icon: :orders, active: request.path.start_with?("/merchant/orders") }
      end
      items << { label: "Profile", path: merchant_profile_path, icon: :profile, active: request.path.start_with?("/merchant/profile", "/merchant/members", "/merchant/account_settings", "/locations") }
      items
    else
      []
    end
  end

  def admin_navigation_items
    [
      { label: "Dashboard", path: dashboard_path, icon: :dashboard },
      { label: "Products", path: products_path, icon: :products },
      { label: "Inventory", path: inventory_path, icon: :inventory },
      { label: "Suppliers", path: suppliers_path, icon: :store },
      { label: "Locations", path: locations_path, icon: :locations },
      { label: "Users", path: admin_users_path, icon: :team }
    ]
  end

  def nav_icon(name)
    path_data = {
      home: "M4 11.5L12 4l8 7.5V20a1 1 0 0 1-1 1h-4.5v-6h-5v6H5a1 1 0 0 1-1-1v-8.5z",
      search: "M10.5 4a6.5 6.5 0 1 0 4.1 11.6L20 21l1-1-1.4-1.4-5.4-5.4A6.5 6.5 0 0 0 10.5 4zm0 2a4.5 4.5 0 1 1 0 9 4.5 4.5 0 0 1 0-9z",
      catalog: "M4 6.5A2.5 2.5 0 0 1 6.5 4h11A2.5 2.5 0 0 1 20 6.5v11A2.5 2.5 0 0 1 17.5 20h-11A2.5 2.5 0 0 1 4 17.5v-11zm2.5-.5a.5.5 0 0 0-.5.5V10h5V6H6.5zm6.5 0V10h5V6.5a.5.5 0 0 0-.5-.5H13zM6 12v5.5a.5.5 0 0 0 .5.5H11v-6H6zm7 0v6h4.5a.5.5 0 0 0 .5-.5V12h-5z",
      services: "M6.2 4h11.6L20 8.7l-3.2 3.2v7.1H7.2v-7.1L4 8.7 6.2 4zm1.1 2l-1.1 2.3 2.4 2.4V17h7V10.7l2.4-2.4L16.8 6H7.3z",
      cart: "M6.5 18a1.5 1.5 0 1 0 0 3 1.5 1.5 0 0 0 0-3zm9 0a1.5 1.5 0 1 0 0 3 1.5 1.5 0 0 0 0-3zM4 4h2l1.5 8.5A2 2 0 0 0 9.5 14H18a1 1 0 0 0 .95-.69L21 7H8.2l-.3-1.5A1 1 0 0 0 7 5H4V4z",
      profile: "M12 12.2a4.2 4.2 0 1 0 0-8.4 4.2 4.2 0 0 0 0 8.4zM4 20a8 8 0 0 1 16 0H4z",
      dashboard: "M4 4h7v7H4V4zm9 0h7v4h-7V4zM4 13h7v7H4v-7zm9 6v-9h7v9h-7z",
      products: "M4 6.5A2.5 2.5 0 0 1 6.5 4h11A2.5 2.5 0 0 1 20 6.5v11A2.5 2.5 0 0 1 17.5 20h-11A2.5 2.5 0 0 1 4 17.5v-11zm2 0V10h12V6.5a.5.5 0 0 0-.5-.5h-11a.5.5 0 0 0-.5.5zM6 12v5.5a.5.5 0 0 0 .5.5H17a.5.5 0 0 0 .5-.5V12H6z",
      inventory: "M4 5.5A1.5 1.5 0 0 1 5.5 4h13A1.5 1.5 0 0 1 20 5.5v11A1.5 1.5 0 0 1 18.5 18h-13A1.5 1.5 0 0 1 4 16.5v-11zm2 1V10h12V6.5a.5.5 0 0 0-.5-.5h-11a.5.5 0 0 0-.5.5zM6 12v4h12v-4H6z",
      locations: "M12 3.5C8.4 3.5 5.5 6.4 5.5 10c0 4.8 6.5 10.5 6.5 10.5S18.5 14.8 18.5 10c0-3.6-2.9-6.5-6.5-6.5zm0 8.3A1.8 1.8 0 1 1 12 8.2a1.8 1.8 0 0 1 0 3.6z",
      team: "M8.5 11a3 3 0 1 1 0-6 3 3 0 0 1 0 6zm7 0a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5zM4 19.5c0-2.5 2.8-4.5 6.2-4.5s6.2 2 6.2 4.5V20H4v-.5zm11.2-2.9c2.2.6 3.8 2.1 3.8 3.9V20h-3.8v-.5c0-1-.3-2-.8-2.9.2 0 .5 0 .8 0z",
      store: "M4 7h16l-1.2-3H5.2L4 7zm1 2v10h14V9H5zm3 2h8v2H8v-2zm0 4h5v2H8v-2z",
      orders: "M5 4h14v16H5V4zm3 4h8V6H8v2zm0 4h8v-2H8v2zm0 4h5v-2H8v2z",
      bookings: "M7 2h2v2h6V2h2v2h2a1 1 0 0 1 1 1v13a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V5a1 1 0 0 1 1-1h2V2zm10 6H7v9h10V8z",
      inbox: "M4 5h16v11H7l-3 3V5zm2 2v6.2L7.2 12H18V7H6z",
      notifications: "M12 22a2.2 2.2 0 0 0 2.1-1.5h-4.2A2.2 2.2 0 0 0 12 22zm7-6V11a7 7 0 1 0-14 0v5l-2 2v1h18v-1l-2-2z",
      analytics: "M5 19V5h2v14H5zm6 0V9h2v10h-2zm6 0v-7h2v7h-2z",
      settings: "M19.4 13.5a7.6 7.6 0 0 0 0-3l2-1.5-2-3.5-2.4 1a7.7 7.7 0 0 0-2.6-1.5L14 2h-4l-.4 3a7.7 7.7 0 0 0-2.6 1.5l-2.4-1-2 3.5 2 1.5a7.6 7.6 0 0 0 0 3L2.6 15l2 3.5 2.4-1a7.7 7.7 0 0 0 2.6 1.5l.4 3h4l.4-3a7.7 7.7 0 0 0 2.6-1.5l2.4 1 2-3.5-2.6-1.5zM12 15.5a3.5 3.5 0 1 1 0-7 3.5 3.5 0 0 1 0 7z",
      help: "M12 3a7 7 0 0 0-7 7h2a5 5 0 1 1 5 5v2a7 7 0 0 0 0-14zm-1 14h2v2h-2v-2zm1-11a3 3 0 0 0-3 3h2a1 1 0 1 1 1.6.8c-1 .8-1.6 1.5-1.6 3.2h2c0-.8.2-1.1.9-1.7A3 3 0 0 0 12 6z",
      contact: "M4 4h16v16H4V4zm2 3v10h12V7l-6 4-6-4zm1.2-1L12 9.2 16.8 6H7.2z",
      signout: "M10 17v-2h4V9h-4V7l-4 4 4 6zm5-13h3a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2h-3v-2h3V6h-3V4z"
    }.freeze

    content_tag :svg, class: "nav-icon nav-icon--#{name}", viewBox: "0 0 24 24", aria: { hidden: true }, focusable: false do
      tag.path(d: path_data.fetch(name))
    end
  end

  def merchant_account_label
    return "Business admin" if enterprise_merchant_navigation?

    "Seller workspace"
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
