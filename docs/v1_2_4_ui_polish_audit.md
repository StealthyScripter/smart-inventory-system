# v1.2.4 UI Polish Audit

Baseline: `v1.2.3-account-navigation-ux`

Branch: `ui-polish-v1-2-4`

## Scope Checked

- Public/customer: `/`, `/catalog`, `/search`, `/services`, `/merchants/:id`, `/cart`, `/checkout`, `/customer/orders`, `/customer/service_bookings`, `/notifications`, `/conversations`
- Merchant: `/merchant`, `/merchant/catalog` via marketplace listing management, `/merchant/products`, `/merchant/inventory`, `/merchant/orders`, `/merchant/services`, `/merchant/service_bookings`, `/merchant/analytics`, `/merchant/team`, `/merchant/locations` via shared location views
- Admin: `/admin/reports`, `/admin/moderation`, `/admin/analytics`

`/customer/profile` is not currently routed in the application. `/merchant/profile` maps to merchant shop/account settings views rather than a standalone profile route.

## Findings and Fixes

- Wide tables were used for browsing catalog, services, search results, cart, orders, bookings, notifications, and moderation queues. Replaced high-traffic areas with responsive cards or safe horizontally scrollable tables.
- Inline grid widths such as `2fr 1fr 1fr 1fr auto` could overflow Chrome/Linux at narrow widths. Replaced with reusable `.filter-grid` and mobile one-column breakpoints.
- Product, service, and storefront images had max-height-only styling that could crop unpredictably. Added fixed aspect-ratio media containers and object-fit rules.
- Mobile navigation stacked as a full sidebar and could create large vertical navigation before content. Updated the mobile sidebar into a horizontal scrollable nav rail.
- Main content could exceed viewport width next to the sidebar. Added explicit flex constraints and `max-width: calc(100vw - 280px)`.
- Cards lacked consistent shadows, borders, spacing, and hover/focus states. Added shared tokenized card styles.
- Header actions used verbose labels and inline spacing. Shortened notification/inbox actions and moved spacing into CSS.
- Account themes were visually similar. Added customer, merchant, and enterprise theme tokens that affect navigation, actions, card accents, and focus states.
- Empty states were mostly italic table rows. Replaced major empty states with icon-led centered blocks.
- Long names/descriptions could force layout expansion. Added wrapping, truncation helpers, and clamp styles.

## Notes

Legacy back-office inventory/product/location/supplier tables remain table-based but now inherit safer overflow behavior from `.table-container > table`.
