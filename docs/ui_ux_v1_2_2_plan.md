# UI/UX v1.2.2 Plan

## Audit Summary

The application is functionally mature after v1.2, but many pages still use
dense table-oriented layouts from the inventory-management foundation. That is
appropriate for back-office operations in some places, but it makes public
marketplace browsing, customer order tracking, cart review, merchant dashboards,
and admin moderation harder to scan on mobile.

## Dense Or Table-Heavy Pages

- `/catalog` and `/services` use simple listing loops with limited card visual
  hierarchy.
- `/cart` and `/checkout` are table-first and need clearer item/summary areas.
- `/customer/orders`, `/customer/service_bookings`, `/notifications`, and
  conversation lists are compact but not card-oriented.
- `/merchant/products`, `/merchant/inventory`, `/merchant/orders`,
  `/merchant/services`, and `/merchant/service_bookings` are operational tables
  with limited separation between local inventory and marketplace listings.
- `/admin/moderation`, `/admin/reports`, and `/admin/analytics` are readable but
  dense for governance triage.

## Mobile Pain Points

- The sidebar becomes a large top block on narrow screens.
- There is no persistent buyer-focused bottom navigation.
- Tables can create horizontal scrolling.
- Touch targets are acceptable in buttons but less consistent in text links.
- Empty states are plain text and easy to miss.

## Pages To Convert Or Enhance With Cards

- Public catalog and service index pages: listing/service card grids.
- Product and service details: summary card, media placeholder, price/action
  emphasis.
- Merchant storefronts: banner/profile summary and product/service card grids.
- Cart and checkout: marketplace item cards plus total summary card.
- Customer orders, bookings, notifications, and conversations: status cards.
- Merchant dashboard and management pages: dashboard metric cards, product cards,
  inventory cards, order cards, booking queue cards.
- Admin moderation and reports: report/moderation action cards.

## Reusable Partials Needed

- `shared/_listing_card`
- `shared/_service_card`
- `shared/_merchant_card`
- `shared/_order_card`
- `shared/_metric_card`
- `shared/_empty_state`
- `shared/_status_badge`

## CSS/Layout Improvements

- Responsive `.card-grid` classes for marketplace and dashboard content.
- `.ui-card`, `.listing-card`, `.summary-card`, `.order-card`, and
  `.notification-card` patterns.
- Image placeholder/fallback treatment with useful alt text.
- Marketplace price styling with sale price support.
- Status/availability badges.
- Mobile bottom navigation for authenticated customers.
- Visible focus states and larger mobile tap targets.

## Constraints

This release must not change account ownership, authorization, payment state,
inventory calculations, marketplace data flow, order lifecycle, or database
schema. UI changes should use existing Rails views, helpers, Hotwire behavior,
and CSS.
