class RecommendationService
  def product_recommendations(product, limit: 4)
    Product.publicly_listed
           .where.not(id: product.id)
           .where(
             "products.category_id = :category_id OR products.supplier_id = :supplier_id",
             category_id: product.category_id,
             supplier_id: product.supplier_id
           )
           .left_joins(:reviews)
           .group("products.id")
           .order(Arel.sql("AVG(reviews.rating) DESC NULLS LAST"), :name)
           .limit(limit)
  end

  def service_recommendations(service, limit: 4)
    ServiceListing.publicly_listed
                  .where.not(id: service.id)
                  .where(service_category: service.service_category)
                  .left_joins(:reviews)
                  .group("service_listings.id")
                  .order(Arel.sql("AVG(reviews.rating) DESC NULLS LAST"), :name)
                  .limit(limit)
  end
end
