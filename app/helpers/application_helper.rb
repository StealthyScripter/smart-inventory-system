module ApplicationHelper
  def safe_media_url?(url)
    return false if url.blank?
    return true if url.start_with?("/")

    uri = URI.parse(url)
    uri.host.in?(%w[127.0.0.1 localhost])
  rescue URI::InvalidURIError
    false
  end

  def account_theme_class
    return "theme-enterprise" if current_merchant_account&.enterprise_merchant?
    return "theme-merchant" if current_merchant_account&.individual_merchant? || current_user&.supplier_user?
    return "theme-customer" if current_customer_account.present? || current_user&.customer?

    "theme-enterprise"
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
          label: current_customer_account&.name.presence || current_user.full_name,
          subtitle: "Customer account",
          path: customer_profile_path,
          aria_label: "Customer account"
        }
      elsif current_merchant_account.present? || current_user&.supplier_user?
        {
          label: current_merchant_account&.name.presence || current_user.full_name,
          subtitle: "Merchant account",
          path: merchant_profile_path,
          aria_label: "Merchant account"
        }
      else
        {
          label: "Account",
          subtitle: "Profile",
          path: login_path,
          aria_label: "Account"
        }
      end
    else
      {
        label: "Sign in / Account",
        subtitle: "Guest",
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
    customer?
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
        { label: "Home", path: root_path, icon: :home },
        { label: "Shop", path: catalog_path, icon: :catalog },
        { label: "Services", path: services_path, icon: :services },
        { label: "Cart", path: cart_path, icon: :cart },
        { label: "Profile", path: customer_profile_path, icon: :profile }
      ]
    elsif merchant_navigation?
      [
        { label: "Dashboard", path: merchant_root_path, icon: :dashboard },
        { label: "Catalog", path: merchant_catalog_path, icon: :catalog },
        { label: "Products", path: merchant_products_path, icon: :products },
        { label: "Inventory", path: merchant_inventory_path, icon: :inventory },
        { label: "Profile", path: merchant_profile_path, icon: :profile }
      ]
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
      signout: "M10 17v-2h4V9h-4V7l-4 4 4 6zm5-13h3a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2h-3v-2h3V6h-3V4z"
    }.freeze

    content_tag :svg, class: "nav-icon nav-icon--#{name}", viewBox: "0 0 24 24", aria: { hidden: true }, focusable: false do
      tag.path(d: path_data.fetch(name))
    end
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
