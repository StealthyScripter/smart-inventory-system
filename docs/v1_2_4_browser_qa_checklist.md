# v1.2.4 Browser QA Checklist

Use Chrome on Linux/Debian plus one narrow mobile viewport.

## Layout

- [ ] No horizontal page scroll at 375px, 768px, 1280px, and 1440px widths.
- [ ] Header controls wrap without covering page titles.
- [ ] Mobile navigation scrolls horizontally and does not cover content.
- [ ] Cards keep stable image/media ratios and do not stretch product photos.
- [ ] Forms in filters, cart, checkout, merchant orders, and booking updates fit narrow screens.
- [ ] Tables that remain are horizontally scrollable inside their card container.

## Public Marketplace

- [ ] `/catalog` cards show image/placeholder, price, category, merchant, rating, and status.
- [ ] `/search` product, service, and merchant result sections do not overflow.
- [ ] `/services` service cards show provider, category, price, and rating.
- [ ] `/merchants/:id` storefront hero and product/service cards fit mobile.
- [ ] Product and service detail pages keep purchase/booking panels visible.

## Customer

- [ ] `/cart` quantity and remove actions stay tappable.
- [ ] `/checkout` total and payment actions do not overlap.
- [ ] `/customer/orders` and `/customer/service_bookings` cards show status and dates clearly.
- [ ] `/notifications` and inbox cards handle long titles/messages.

## Merchant

- [ ] `/merchant` dashboard stat cards and tool buttons wrap cleanly.
- [ ] `/merchant/products` bulk/import controls fit narrow widths.
- [ ] `/merchant/inventory` stock cards keep adjustment forms usable.
- [ ] `/merchant/orders` and `/merchant/service_bookings` transition forms do not overflow.
- [ ] Enterprise-only team/settings links remain visually separated by theme and permissions.

## Admin

- [ ] `/admin/reports` moderation cards keep status controls visible.
- [ ] `/admin/moderation` report/product/service/review/merchant queues are easy to scan.
- [ ] `/admin/analytics` metric cards use the enterprise accent.

## Accessibility

- [ ] Keyboard focus is visible on links, buttons, inputs, selects, and cards with actions.
- [ ] Form labels remain visible.
- [ ] Image alt text is present for product, service, and merchant media.
- [ ] Badge text is readable against badge backgrounds.
- [ ] Buttons meet minimum tap target height.
