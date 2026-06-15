class AccountBackfill
  def self.call
    new.call
  end

  def call
    backfill_customer_accounts
    backfill_merchant_accounts
    backfill_customer_owned_records
    backfill_merchant_owned_records
    backfill_marketplace_listings
  end

  private

  def backfill_customer_accounts
    User.with_roles("customer").find_each do |user|
      account = user.customer_accounts.first || Account.create_with_owner!(
        creator: user,
        name: "#{user.full_name} Customer Account",
        account_type: "customer"
      )
      CustomerProfile.find_or_create_by!(account: account) do |profile|
        profile.user = user
        profile.display_name = user.full_name
      end
    end
  end

  def backfill_merchant_accounts
    Supplier.includes(:supplier_users).find_each do |supplier|
      next if supplier.merchant_account.present?

      supplier_users = supplier.supplier_users.includes(:user).to_a
      creator = supplier_users.first&.user
      account_type = supplier_users.many? ? "enterprise_merchant" : "individual_merchant"
      account = Account.create!(name: supplier.name, account_type: account_type, creator: creator)

      MerchantProfile.create!(
        account: account,
        supplier: supplier,
        display_name: supplier.name,
        description: supplier.shop_description,
        slug: supplier.shop_slug,
        status: supplier.shop_status
      )

      supplier_users.each_with_index do |supplier_user, index|
        role = account.enterprise_merchant? && index.positive? ? "employee" : "owner"
        account.account_memberships.find_or_create_by!(user: supplier_user.user) do |membership|
          membership.role = role
        end
      end
    end
  end

  def backfill_customer_owned_records
    Cart.where(customer_account_id: nil).includes(user: :accounts).find_each do |cart|
      cart.update!(customer_account: cart.user.customer_accounts.first)
    end

    Order.where(customer_account_id: nil).includes(user: :accounts).find_each do |order|
      order.update!(customer_account: order.user.customer_accounts.first)
    end
  end

  def backfill_merchant_owned_records
    backfill_supplier_scoped(Product)
    backfill_supplier_scoped(ServiceListing)
    backfill_supplier_scoped(OrderItem)
    backfill_supplier_scoped(ServiceBooking)
    backfill_supplier_scoped(Conversation)
    backfill_supplier_scoped(Review)

    StockLevel.where(account_id: nil).includes(product: :account).find_each do |stock_level|
      stock_level.update!(account: stock_level.product.merchant_account)
    end

    StockMovement.where(account_id: nil).includes(product: :account).find_each do |movement|
      movement.update!(account: movement.product.merchant_account)
    end
  end

  def backfill_supplier_scoped(model)
    model.where(account_id: nil).includes(supplier: :merchant_account).find_each do |record|
      record.update!(account: record.supplier&.merchant_account)
    end
  end

  def backfill_marketplace_listings
    Product.where(marketplace_status: "public", listing_scope: %w[marketplace both])
           .left_outer_joins(:marketplace_listing)
           .where(marketplace_listings: { id: nil })
           .find_each(&:save!)
  end
end
