module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :admin?, :regional_manager?, :location_manager?, :department_manager?,
    :employee?, :client?, :supplier_user?, :customer?, :guest?,
    :can_manage_users?, :can_manage_products?, :can_manage_locations?,
    :can_manage_suppliers?, :can_adjust_inventory?, :can_delete?,
    :can_access_location?, :accessible_locations, :viewable_locations
  end

  def admin?
    current_user&.admin?
  end

  def regional_manager?
    current_user&.regional_manager?
  end

  def location_manager?
    current_user&.location_manager?
  end

  def department_manager?
    current_user&.department_manager?
  end

  def employee?
    current_user&.employee?
  end

  def client?
    current_user&.client?
  end

  def supplier_user?
    current_user&.supplier_user?
  end

  def customer?
    current_user&.customer?
  end

  def guest?
    current_user&.guest?
  end

  def can_manage_users?
    admin? || regional_manager?
  end

  def can_manage_products?
    admin? || regional_manager?
  end

  def can_manage_locations?
    admin? || regional_manager?
  end

  def can_manage_suppliers?
    admin? || regional_manager?
  end

  def can_adjust_inventory?
    admin? || regional_manager? || location_manager? || department_manager?
  end

  def can_delete?
    admin? || regional_manager?
  end

  def can_access_location?(location)
    return false unless location
    return true if admin? || regional_manager?
    return location == current_user.location if location_manager? || department_manager? || employee?

    false
  end

  def accessible_locations
    if admin? || regional_manager?
      Location.order(:name)
    elsif current_user&.location_id && (location_manager? || department_manager? || employee?)
      Location.where(id: current_user.location_id).order(:name)
    else
      Location.none
    end
  end

  def viewable_locations
    logged_in? ? Location.order(:name) : Location.none
  end

  def require_user_management_permission
    redirect_to root_path, alert: "You don't have permission to manage users." unless can_manage_users?
  end

  def require_product_management_permission
    redirect_to root_path, alert: "You don't have permission to manage products." unless can_manage_products?
  end

  def require_location_management_permission
    redirect_to root_path, alert: "You don't have permission to manage locations." unless can_manage_locations?
  end

  def require_supplier_management_permission
    redirect_to root_path, alert: "You don't have permission to manage suppliers." unless can_manage_suppliers?
  end

  def require_inventory_adjustment_permission
    redirect_to inventory_path, alert: "You don't have permission to adjust stock." unless can_adjust_inventory?
  end

  def require_delete_permission
    redirect_to root_path, alert: "You don't have permission to delete records." unless can_delete?
  end
end
