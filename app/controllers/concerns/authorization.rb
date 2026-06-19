module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :admin?, :regional_manager?, :location_manager?, :department_manager?,
    :employee?, :client?, :supplier_user?, :customer?, :guest?,
    :can_manage_users?, :can_manage_products?, :can_manage_locations?,
    :can_manage_suppliers?, :can_adjust_inventory?, :can_delete?,
    :can_access_back_office?, :can_access_product_catalog?, :can_manage_product?,
    :can_access_location?, :accessible_locations, :viewable_locations, :manageable_suppliers,
    :can_manage_merchant?, :legacy_supplier_merchant?
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
    admin? || regional_manager? || manageable_suppliers.exists?
  end

  def can_manage_locations?
    admin? || regional_manager? || can_manage_merchant?(:manage_locations)
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

  def can_access_back_office?
    admin? || regional_manager? || location_manager? || department_manager? || employee? || client?
  end

  def can_access_product_catalog?
    can_access_back_office? || manageable_suppliers.exists?
  end

  def can_manage_product?(product)
    return true if admin? || regional_manager?
    return false unless product&.supplier_id

    manageable_suppliers.exists?(id: product.supplier_id)
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
    can_access_back_office? ? Location.order(:name) : Location.none
  end

  def manageable_suppliers
    return Supplier.order(:name) if admin? || regional_manager?
    return merchant_compatible_suppliers.order(:name) if current_user

    Supplier.none
  end

  def can_manage_merchant?(permission)
    return true if legacy_supplier_merchant?
    return false unless current_merchant_account&.active?

    current_account_membership(current_merchant_account)&.has_permission?(permission)
  end

  def require_back_office_access
    return if can_access_back_office? || can_manage_merchant?(:manage_locations)

    render plain: "You don't have permission to access inventory management.", status: :forbidden
  end

  def require_product_catalog_access
    return if can_access_product_catalog?

    render plain: "You don't have permission to access product management.", status: :forbidden
  end

  def require_user_management_permission
    redirect_to root_path, alert: "You don't have permission to manage users." unless can_manage_users?
  end

  def require_product_management_permission
    redirect_to root_path, alert: "You don't have permission to manage products." unless can_manage_products?
  end

  def require_product_ownership_permission
    return if can_manage_product?(@product)

    redirect_to products_path, alert: "You can only manage products for your supplier account."
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

  def require_merchant_permission(permission)
    return if can_manage_merchant?(permission)

    render plain: "You don't have permission to perform this merchant action.", status: :forbidden
  end

  def merchant_compatible_suppliers
    supplier_ids = []
    supplier_ids.concat(current_user.suppliers.select(:id).pluck(:id)) if supplier_user?

    account_supplier_id = current_merchant_account&.merchant_profile&.supplier_id
    supplier_ids << account_supplier_id if account_supplier_id.present?

    Supplier.where(id: supplier_ids.compact.uniq)
  end

  def legacy_supplier_merchant?
    current_merchant_account.blank? && supplier_user? && current_user.suppliers.exists?
  end
end
