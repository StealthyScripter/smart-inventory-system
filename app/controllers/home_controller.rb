class HomeController < ApplicationController
  skip_before_action :require_login

  def index
    search = SearchService.new({})
    @goods = search.products(limit: 12)
    @services = search.services(limit: 12)
    @merchants = search.merchants(limit: 12)
    @discover_brands = SearchService.new(sort: "newest").merchants(limit: 12)
    @top_rated_goods = top_rated_goods(limit: 12)
    @top_rated_merchants = top_rated_merchants(limit: 12)
    @trending_services = SearchService.new(sort: "rating").services(limit: 12)
    @recommended_goods = recommended_products
    @recent_items = recent_items
    @construction_essentials = products_for_categories(["Building Materials", "Hardware"], limit: 12)
    @electrical_supplies = products_for_categories(["Electrical"], limit: 12)
    @plumbing_products = products_for_categories(["Plumbing"], limit: 12)
    @paint_and_finishing = products_for_categories(["Paint"], limit: 12)
    @interior_design_services = services_for_categories(["Interior design"], limit: 12)
    @hvac_services = services_for_categories(["AC services"], limit: 12)
    @home_services = services_for_categories(["Painting", "Cleaning"], limit: 12)
    @marketplace_sections = marketplace_sections
    @featured_product = @top_rated_goods.first || @goods.first
    @featured_service = @trending_services.first || @services.first
    @featured_merchant = @discover_brands.first || @top_rated_merchants.first || @merchants.first
  end

  private

  def marketplace_sections
    sections = [
      {
        eyebrow: "Brands",
        title: "Discover great brands",
        subtitle: "New and trusted storefronts",
        cta_label: "Browse merchants",
        cta_path: search_path,
        kind: :merchants,
        items: @discover_brands,
        variant: :rail
      },
      {
        eyebrow: "Goods",
        title: "Popular goods",
        subtitle: "Top rated public products",
        cta_label: "Shop goods",
        cta_path: catalog_path,
        kind: :products,
        items: @top_rated_goods,
        variant: :wide
      },
      {
        eyebrow: "Construction",
        title: "Construction essentials",
        subtitle: "Construction essentials",
        cta_label: "Open catalog",
        cta_path: catalog_path,
        kind: :products,
        items: @construction_essentials,
        variant: :mixed
      },
      {
        eyebrow: "Electrical",
        title: "Electrical supplies",
        subtitle: "Parts and materials for jobs",
        cta_label: "Shop electrical",
        cta_path: catalog_path(q: "Electrical"),
        kind: :products,
        items: @electrical_supplies,
        variant: :compact
      },
      {
        eyebrow: "Plumbing",
        title: "Plumbing products",
        subtitle: "Fittings and repair essentials",
        cta_label: "Shop plumbing",
        cta_path: catalog_path(q: "Plumbing"),
        kind: :products,
        items: @plumbing_products,
        variant: :compact
      },
      {
        eyebrow: "Paint",
        title: "Paint and finishing",
        subtitle: "Finishes, tools, and supplies",
        cta_label: "Shop paint",
        cta_path: catalog_path(q: "Paint"),
        kind: :products,
        items: @paint_and_finishing,
        variant: :compact
      },
      {
        eyebrow: "Services",
        title: "Trending services",
        subtitle: "Top rated public services",
        cta_label: "Open services",
        cta_path: services_path,
        kind: :services,
        items: @trending_services,
        variant: :rail
      },
      {
        eyebrow: "Interior design",
        title: "Interior design services",
        subtitle: "Planning and styling help",
        cta_label: "See all services",
        cta_path: services_path(category: "Interior design"),
        kind: :services,
        items: @interior_design_services,
        variant: :standard
      },
      {
        eyebrow: "HVAC",
        title: "HVAC services",
        subtitle: "Cooling and climate support",
        cta_label: "See HVAC services",
        cta_path: services_path(category: "AC services"),
        kind: :services,
        items: @hvac_services,
        variant: :compact
      },
      {
        eyebrow: "Services",
        title: "Services near you",
        subtitle: "Trusted public service listings",
        cta_label: "See all services",
        cta_path: services_path,
        kind: :services,
        items: @services,
        variant: :standard
      },
      {
        eyebrow: "Merchants",
        title: "Top merchants",
        subtitle: "Trusted storefronts",
        cta_label: "Browse merchants",
        cta_path: search_path,
        kind: :merchants,
        items: @top_rated_merchants,
        variant: :rail
      }
    ]

    if @recommended_goods.any?
      sections << {
        eyebrow: "Recommended",
        title: "Recommended for projects",
        subtitle: "Matched from activity",
        cta_label: "Browse goods",
        cta_path: catalog_path,
        kind: :products,
        items: @recommended_goods,
        variant: :compact
      }
    end

    sections << {
      eyebrow: "Home",
      title: "Home and interior services",
      subtitle: "Design, painting, and cleaning",
      cta_label: "Open services",
      cta_path: services_path,
      kind: :services,
      items: @home_services,
      variant: :standard
    }

    sections << {
      eyebrow: "Fresh",
      title: "Recently added",
      subtitle: "Fresh public listings",
      cta_label: "Explore marketplace",
      cta_path: search_path,
      kind: :mixed,
      items: @recent_items,
      variant: :mixed
    }

    sections
  end

  def recommended_products
    source = current_user&.customer? ? current_cart_product : nil
    source ? RecommendationService.new.product_recommendations(source, limit: 4) : []
  end

  def current_cart_product
    current_user&.carts&.find_by(status: "active")&.cart_items&.includes(product: [:category, :supplier])&.first&.product
  end

  def recent_items
    recent_goods = Product.publicly_listed.includes(:category, :supplier).order(created_at: :desc).limit(2).map do |product|
      { kind: :product, record: product }
    end

    recent_services = ServiceListing.publicly_listed.includes(:supplier).order(created_at: :desc).limit(2).map do |service|
      { kind: :service, record: service }
    end

    recent_merchants = SearchService.new(sort: "newest").merchants(limit: 2).map do |merchant|
      { kind: :merchant, record: merchant }
    end

    (recent_goods + recent_services + recent_merchants).first(6)
  end

  def products_for_categories(names, limit: 8)
    category_ids = Category.where(name: names).pluck(:id)
    return Product.none if category_ids.empty?

    Product.publicly_listed
           .includes(:category, :supplier)
           .where(category_id: category_ids)
           .left_joins(:reviews)
           .group("products.id")
           .order(Arel.sql("AVG(reviews.rating) DESC NULLS LAST"), created_at: :desc)
           .limit(limit)
  end

  def services_for_categories(names, limit: 8)
    ServiceListing.publicly_listed
                  .includes(:supplier)
                  .where(service_category: names)
                  .left_joins(:reviews)
                  .group("service_listings.id")
                  .order(Arel.sql("AVG(reviews.rating) DESC NULLS LAST"), created_at: :desc)
                  .limit(limit)
  end

  def top_rated_goods(limit: 8)
    Product.publicly_listed
           .includes(:category, :supplier)
           .left_joins(:reviews)
           .group("products.id")
           .order(Arel.sql("AVG(reviews.rating) DESC NULLS LAST"), created_at: :desc)
           .limit(limit)
  end

  def top_rated_merchants(limit: 8)
    SearchService.new(sort: "rating").merchants(limit: limit)
  end
end
