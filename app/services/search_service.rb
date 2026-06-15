class SearchService
  DEFAULT_LIMIT = 20

  def initialize(params = {})
    @params = params.to_h.symbolize_keys
  end

  def products(limit: DEFAULT_LIMIT)
    product_listings(limit: limit).includes(product: [:category, :supplier]).map(&:product)
  end

  def product_listings(limit: DEFAULT_LIMIT)
    MarketplaceListing.visible
                      .products
                      .joins(product: [:category])
                      .merge(Product.where(marketplace_status: "public").marketplace_available)
                      .search(query)
                      .for_category(params[:category_id])
                      .for_supplier(merchant_id)
                      .includes(product: [:category, :supplier])
                      .order(product_listing_order)
                      .offset(offset(limit))
                      .limit(limit)
  end

  def services(limit: DEFAULT_LIMIT)
    ServiceListing.publicly_listed
                  .search(query)
                  .for_category(params[:service_category])
                  .for_supplier(merchant_id)
                  .includes(:supplier)
                  .catalog_sorted(sort)
                  .offset(offset(limit))
                  .limit(limit)
  end

  def merchants(limit: DEFAULT_LIMIT)
    Supplier.where(id: discoverable_supplier_ids)
            .search(query)
            .left_joins(:reviews)
            .group("suppliers.id")
            .order(merchant_order)
            .offset(offset(limit))
            .limit(limit)
  end

  def categories(limit: 10)
    Category.joins(:products)
            .merge(Product.publicly_listed.search(query))
            .distinct
            .order(:name)
            .offset(offset(limit))
            .limit(limit)
  end

  def suggestions(limit: 8)
    suggestions = []
    suggestions.concat(product_listings(limit: limit).pluck(:title))
    suggestions.concat(services(limit: limit).pluck(:name))
    suggestions.concat(merchants(limit: limit).pluck(:name))
    suggestions.concat(categories(limit: limit).pluck(:name))
    suggestions.compact.uniq.first(limit)
  end

  def related_products(product, limit: 4)
    RecommendationService.new.product_recommendations(product, limit: limit)
  end

  def related_services(service, limit: 4)
    RecommendationService.new.service_recommendations(service, limit: limit)
  end

  private

  attr_reader :params

  def query
    params[:q].to_s.strip
  end

  def sort
    params[:sort].presence
  end

  def merchant_id
    params[:merchant_id].presence || params[:supplier_id].presence
  end

  def discoverable_supplier_ids
    (
      Supplier.where(shop_status: "public").pluck(:id) +
      Product.publicly_listed.where.not(supplier_id: nil).distinct.pluck(:supplier_id) +
      ServiceListing.publicly_listed.distinct.pluck(:supplier_id)
    ).uniq
  end

  def merchant_order
    return Arel.sql("AVG(reviews.rating) DESC, suppliers.name ASC") if sort == "rating"
    return { created_at: :desc } if sort == "newest"

    :name
  end

  def product_listing_order
    case sort
    when "price_asc"
      Arel.sql("COALESCE(marketplace_listings.sale_price, marketplace_listings.public_price, 0) ASC, marketplace_listings.title ASC")
    when "price_desc"
      Arel.sql("COALESCE(marketplace_listings.sale_price, marketplace_listings.public_price, 0) DESC, marketplace_listings.title ASC")
    when "newest"
      { created_at: :desc }
    else
      :title
    end
  end

  def offset(limit)
    ([params[:page].to_i, 1].max - 1) * limit
  end
end
