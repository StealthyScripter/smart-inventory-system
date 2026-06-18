class HomeController < ApplicationController
  MARKETPLACE_ROW_SIZE = 4
  SECTION_LIMIT = 12

  skip_before_action :require_login

  def index
    search = SearchService.new({})
    @goods = search.products(limit: SECTION_LIMIT)
    @services = search.services(limit: SECTION_LIMIT)
    @merchants = search.merchants(limit: SECTION_LIMIT)
    @top_rated_goods = top_rated_goods(limit: SECTION_LIMIT)
    @trending_services = SearchService.new(sort: "rating").services(limit: SECTION_LIMIT)
    @recommended_goods = recommended_products
    @recent_items = recent_items
    @marketplace_sections = marketplace_sections
    @featured_product = @top_rated_goods.first || @goods.first
    @featured_service = @trending_services.first || @services.first
    @featured_merchant = @merchants.first
  end

  private

  def marketplace_sections
    tagged_sections, fallback_records = dynamic_tag_sections
    sections = [
      general_section(:merchants, fallback_records[:merchants]),
      general_section(:products, fallback_records[:products]),
      *tagged_sections,
      general_section(:services, fallback_records[:services])
    ].compact

    if @recommended_goods.length >= MARKETPLACE_ROW_SIZE
      sections << {
        eyebrow: "Recommended",
        title: "Recommended for projects",
        subtitle: "Matched from your activity",
        cta_label: "Browse goods",
        cta_path: catalog_path,
        kind: :products,
        items: @recommended_goods,
        variant: :compact
      }
    end

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

  def dynamic_tag_sections
    fallback_records = { products: [], services: [], merchants: [] }
    @marketplace_navigation_tags = []
    sections = Tag.for_marketplace_sections.includes(taggings: :taggable).filter_map do |tag|
      records = public_tagged_records(tag)

      if records.length < MARKETPLACE_ROW_SIZE
        add_to_fallback(fallback_records, records)
        next
      end

      @marketplace_navigation_tags << tag
      tagged_section(tag, records)
    end

    [sections, fallback_records]
  end

  def public_tagged_records(tag)
    tag.taggings.filter_map(&:taggable).select do |record|
      case record
      when Product
        record.publicly_listed?
      when ServiceListing
        record.status == "public" && record.visibility == "public"
      when Supplier
        record.public_shop?
      else
        false
      end
    end.uniq { |record| [record.class.name, record.id] }.first(SECTION_LIMIT)
  end

  def tagged_section(tag, records)
    kind = section_kind(records)
    {
      eyebrow: tag.context.titleize,
      title: tag.label,
      subtitle: tag.description.presence || "Selected #{tag.label.downcase} from across the marketplace",
      cta_label: section_cta_label(kind),
      cta_path: search_path(tag_id: tag.id),
      kind: kind,
      items: section_items(kind, records),
      variant: kind == :merchants ? :rail : :compact
    }
  end

  def section_kind(records)
    types = records.map(&:class).uniq
    return :products if types == [Product]
    return :services if types == [ServiceListing]
    return :merchants if types == [Supplier]

    :mixed
  end

  def section_items(kind, records)
    return records unless kind == :mixed

    records.map do |record|
      {
        kind: { Product => :product, ServiceListing => :service, Supplier => :merchant }.fetch(record.class),
        record: record
      }
    end
  end

  def add_to_fallback(fallback_records, records)
    records.each do |record|
      key = { Product => :products, ServiceListing => :services, Supplier => :merchants }[record.class]
      fallback_records[key] << record if key
    end
  end

  def general_section(kind, tagged_records)
    defaults = {
      products: {
        eyebrow: "Goods", title: "General supplies", subtitle: "Products from across the marketplace",
        cta_label: "Shop goods", cta_path: catalog_path, items: @top_rated_goods, variant: :wide
      },
      services: {
        eyebrow: "Services", title: "General services", subtitle: "Help for projects, repairs, and home needs",
        cta_label: "Open services", cta_path: services_path, items: @trending_services, variant: :standard
      },
      merchants: {
        eyebrow: "Merchants", title: "Marketplace merchants", subtitle: "Trusted storefronts across the marketplace",
        cta_label: "Browse merchants", cta_path: search_path, items: @merchants, variant: :rail
      }
    }.fetch(kind)

    items = (tagged_records + defaults[:items].to_a).uniq(&:id).first(SECTION_LIMIT)
    return if items.empty?

    defaults.merge(kind: kind, items: items)
  end

  def section_cta_label(kind)
    {
      products: "Shop goods",
      services: "Open services",
      merchants: "Browse merchants",
      mixed: "Explore marketplace"
    }.fetch(kind)
  end

  def recommended_products
    source = current_user&.customer? ? current_cart_product : nil
    source ? RecommendationService.new.product_recommendations(source, limit: MARKETPLACE_ROW_SIZE) : []
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

  def top_rated_goods(limit:)
    Product.publicly_listed
           .includes(:category, :supplier)
           .left_joins(:reviews)
           .group("products.id")
           .order(Arel.sql("AVG(reviews.rating) DESC NULLS LAST"), created_at: :desc)
           .limit(limit)
  end
end
