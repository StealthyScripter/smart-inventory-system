# v1.2.4 UI Polish Report

## Pages Polished

- Public marketplace: `/catalog`, `/search`, `/services`, `/catalog/:id`, `/services/:id`, `/merchants/:id`
- Customer workflows: `/cart`, `/checkout`, `/customer/orders`, `/customer/service_bookings`, `/notifications`, `/conversations`
- Merchant workflows: `/merchant`, `/merchant/products`, `/merchant/inventory`, `/merchant/orders`, `/merchant/services`, `/merchant/service_bookings`
- Admin workflows: `/admin/reports`, `/admin/moderation`, `/admin/analytics`

## Layout Bugs Fixed

- Added responsive content width constraints to prevent Chrome/Linux cropping next to the sidebar.
- Converted high-risk wide tables into cards across marketplace, customer, merchant, and admin workflows.
- Added safe horizontal scrolling for remaining operational tables.
- Reworked mobile navigation so content is not pushed below a full vertical menu.
- Replaced fragile inline filter grids with responsive `.filter-grid` rules.
- Added fixed media aspect ratios and object-fit image handling.

## Theme Changes

- Customer theme uses a softer commerce teal accent.
- Individual merchant theme uses an operator-focused violet accent.
- Enterprise/admin theme uses a professional blue accent.
- Themes now affect navigation, active states, buttons, card accents, and focus rings.

## Responsive Improvements

- Added mobile, tablet, and desktop breakpoints.
- Cards use auto-fit/auto-fill grids with safe minimum widths.
- Header actions wrap and search expands on mobile.
- Forms use reusable inline/stack layouts that collapse on small screens.
- Long text wraps or clamps to avoid pushing layouts wider than the viewport.

## Accessibility Improvements

- Added visible focus styling through `:focus-visible`.
- Preserved form labels while shortening visible copy.
- Added consistent badge contrast tokens.
- Kept media alt text for attached product/service/merchant images.
- Improved button tap target sizing.

## Remaining UI TODOs

- Add a dedicated `/customer/profile` route if the product requires a profile hub.
- Consider converting legacy product/location/supplier/admin-user management tables to card/table hybrid views in a future release.
- Add automated visual regression coverage once a browser test harness is available in the development container.
