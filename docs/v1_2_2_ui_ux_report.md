# v1.2.2 UI/UX Report

## Pages Improved

- Public catalog index and detail
- Public service index and detail
- Merchant storefronts
- Marketplace search results
- Cart and checkout review
- Customer orders and order detail
- Customer service bookings
- Notifications and conversations
- Merchant dashboard, inventory, orders, services, service bookings, products,
  and enterprise team pages
- Admin moderation and reports

## Partials And Components Added

- `shared/_listing_card`
- `shared/_service_card`
- `shared/_merchant_card`
- `shared/_order_card`
- `shared/_metric_card`
- `shared/_empty_state`
- `shared/_status_badge`

## Accessibility Improvements

- Added visible focus states for links, buttons, and form controls.
- Added semantic card headings and accessible link labels.
- Added alt text and image placeholders for listings, services, and merchant
  storefronts.
- Increased button tap targets through shared button sizing.
- Preserved existing link and form semantics for server-rendered workflows.

## Mobile Improvements

- Added responsive card grids and summary cards.
- Added customer bottom navigation for Home, Search, Cart, Orders, and Account.
- Converted cart, checkout, customer history, merchant queues, and admin
  moderation areas away from table-first layouts where practical.
- Added mobile stacking for filters, cards, detail pages, and checkout summary
  panels.

## Tests Added Or Preserved

No business-flow tests were removed. Existing request specs now exercise the
new card views through the same routes:

- catalog and service marketplace rendering
- cart and checkout
- customer orders and bookings
- messaging and notifications
- merchant portal and operating system
- admin moderation

## Verification Results

- RSpec: 304 examples, 0 failures
- RuboCop: 239 files inspected, no offenses
- Zeitwerk: all good
- Brakeman: 0 active security warnings, 1 ignored warning

## Screenshots And Manual QA Notes

No browser screenshots were captured in this pass. Manual QA should verify
responsive behavior for `/catalog`, `/services`, `/cart`, `/checkout`,
`/customer/orders`, `/merchant`, `/merchant/inventory`, `/merchant/orders`,
`/merchant/service_bookings`, and `/admin/moderation` on narrow and desktop
viewports.

## Remaining UI TODOs

- Move duplicated inline layout CSS into a dedicated stylesheet file in a future
  cleanup cycle.
- Add icon assets for the mobile bottom navigation when an icon set is selected.
- Continue replacing low-value operational tables where bulk editing is not
  required.
- Add screenshot-based visual regression coverage when a browser test harness is
  available.
