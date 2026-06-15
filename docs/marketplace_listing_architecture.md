# Marketplace Listing Architecture

## Ownership split

Inventory products are private operational records. Marketplace listings are public sellable records.

`Product` owns inventory data:

- SKU and barcode
- internal inventory name
- cost and replenishment fields
- stock levels and movements
- supplier/procurement references
- local/private inventory scope

`MarketplaceListing` owns public product listing data:

- public title
- public description
- public price and sale price
- availability
- listing status
- visibility
- shipping eligibility
- public search tags
- featured media URL

## Public catalog rule

Public product catalog discovery must query visible marketplace listings and then join to their inventory products. A product is public only when:

- the listing is `active`
- the listing visibility is `public`
- the product marketplace status is `public`
- the product listing scope is `marketplace` or `both`

Local-only, private, draft, archived, or hidden-listing products must not appear publicly.

## Backward compatibility

Existing product records still carry legacy marketplace fields. Public products with marketplace scope automatically create a compatible listing when saved. This keeps old data and tests working while new public display fields move onto `MarketplaceListing`.

## Merchant workflow

Merchant product management now separates:

- inventory product fields such as name, SKU, cost, category, supplier, reorder point, and lead time
- marketplace listing fields such as public title, public description, price, sale price, availability, listing status, visibility, and shipping eligibility

Hiding a listing does not delete or hide inventory. Editing inventory does not publish a listing unless listing fields/status explicitly make it visible.

## Service listings

`ServiceListing` remains the provider service object. Service public exposure is hardened with explicit `status` and `visibility` fields. A service is public only when both are public-facing:

- `status = public`
- `visibility = public`

Further service/listing extraction can happen later if service catalog complexity grows.
