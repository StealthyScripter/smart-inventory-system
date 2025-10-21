module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :can_manage_users?, :can_create?, :can_edit?, :can_delete?,
    :can_access_location?, :accessible_locations, :can_view_all_locations?,
    :can_make_sales?, :can_create_purchase_orders?,
    :admin?, :manager?, :supervisor?, :employee?, :guest?
  end

  # Role hierarchy checks
  def admin?
    current_user&.role == "admin"
  end

  def manager?
    current_user&.role == "manager"
  end

  def supervisor?
    current_user&.role == "supervisor"
  end

  def employee?
    current_user&.role == "employee"
  end

  def guest?
    current_user&.role == "guest"
  end

  # Permission checks
  def can_manage_users?
    manager? # Only managers can assign roles
  end

  def can_create?
    admin? || manager? || supervisor?
  end

  def can_edit?
    admin? || manager? || supervisor?
  end

  def can_delete?
    admin? || manager?
  end

  def can_make_sales?
    !guest? # Everyone except guests can make sales
  end

  def can_create_purchase_orders?
    admin? || manager? || supervisor?
  end

  def can_view_all_locations?
    admin? || manager? || employee? # Employee can VIEW all locations
  end

  # Location-based access control
  def can_access_location?(location)
    return true if admin? || manager?
    return location == current_user.location if supervisor? || employee?
    false # guests can view but not access for operations
  end

  def accessible_locations
    if admin? || manager?
      Location.all
    elsif supervisor? || employee?
      current_user.location ? [current_user.location] : []
    else
      []
    end
  end

  # Enforce permissions
  def require_admin_or_manager
    unless admin? || manager?
      redirect_to root_path, alert: "You don't have permission to access this page."
    end
  end

  def require_manager
    unless manager?
      redirect_to root_path, alert: "Only managers can access this page."
    end
  end

  def require_create_permission
    unless can_create?
      redirect_to root_path, alert: "You don't have permission to create records."
    end
  end

  def require_edit_permission
    unless can_edit?
      redirect_to root_path, alert: "You don't have permission to edit records."
    end
  end

  def require_sales_permission
    unless can_make_sales?
      redirect_to root_path, alert: "You don't have permission to make sales."
    end
  end
end
