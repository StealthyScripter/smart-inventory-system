# v1.3.6 Login UI QA Report

## Scope

Browser QA was performed against the seeded development database using
headless Google Chrome at a 1440-pixel desktop viewport. Each persona was
logged in through the rendered form, its landing redirect was verified, key
pages were visited, and the session was logged out before continuing.

## Accounts Tested

| Persona | Account | Verified landing |
| --- | --- | --- |
| Customer | `buyer.contractor@example.com` | `/catalog` |
| Individual merchant | `merchant.construction@example.com` | `/merchant` |
| Enterprise owner | `merchant.hardware@example.com` | `/merchant` |
| Enterprise employee | `merchant.hardware.employee@example.com` | `/merchant` |
| Admin | `admin@inventory.com` | `/` |

All accounts used the local demo credential documented in
`docs/demo_user_matrix.md`.

## Pages Visited

- Customer: `/`, `/catalog`, `/services`, `/search`, `/cart`, `/checkout`,
  `/customer/profile`, `/customer/orders`, `/customer/service_bookings`,
  `/customer/conversations`, and `/notifications`.
- Individual merchant: `/merchant`, `/merchant/profile`, `/merchant/catalog`,
  `/merchant/products`, `/merchant/inventory`, `/merchant/orders`,
  `/merchant/services`, `/merchant/service_bookings`, `/merchant/analytics`,
  `/merchant/conversations`, and `/notifications`.
- Enterprise owner: all merchant pages above plus `/merchant/members`,
  `/locations`, and `/merchant/account_settings/edit`.
- Enterprise employee: all listed merchant routes were checked, including
  direct access attempts to owner-only team, location, and account-setting
  routes.
- Admin: `/`, `/admin/analytics`, `/admin/reports`, and
  `/admin/moderation`.

The application’s canonical conversation indexes are
`/customer/conversations` and `/merchant/conversations`. Enterprise
management uses `/merchant/members` and `/locations`.

## Old Layouts and Defects Found

- Individual merchant, enterprise owner, and enterprise employee profiles
  still rendered the old oversized profile hero with an account-type badge,
  verbose account-type subtitle, metric pills, large empty space, and a card
  grid.
- Enterprise employees were shown profile and bottom-navigation links for
  catalog, products, services, and bookings even though those routes were
  forbidden for the seeded employee role.
- The admin shell body used row flex layout. This placed the top bar and page
  content beside one another, causing reports and moderation to render in a
  narrow, vertically stretched column.

## Fixes Applied

- Replaced all merchant profile variants with the compact profile hub used by
  customer accounts:
  - initials or merchant logo and company name only;
  - prominent Orders and Bookings actions when permitted;
  - concise vertical navigation list;
  - no account badge, verbose account subtitle, legacy card grid, or tab strip.
- Added permission-aware merchant profile links and bottom navigation.
- Kept Team, Locations, Access control, and enterprise Settings owner/admin
  only.
- Removed broken catalog, product, service, booking, and settings links from
  the enterprise employee profile.
- Corrected the admin shell flex direction so governance pages use the full
  available content width.
- Confirmed browser-rendered pages have no horizontal overflow and retain
  content padding beneath fixed bottom navigation.

## Screenshot Evidence

Screenshots are generated under the ignored `tmp/ui_qa_screenshots/`
directory and are not committed:

- `tmp/ui_qa_screenshots/customer-profile.png`
- `tmp/ui_qa_screenshots/individual-merchant-profile.png`
- `tmp/ui_qa_screenshots/enterprise-owner-profile.png`
- `tmp/ui_qa_screenshots/enterprise-employee-profile.png`
- `tmp/ui_qa_screenshots/admin-reports.png`
- `tmp/ui_qa_screenshots/admin-moderation.png`

## Tests Added or Updated

- Added seeded login and expected-landing coverage for all five personas.
- Updated customer and merchant profile assertions for the compact hub.
- Added exact individual and enterprise profile-list expectations.
- Added enterprise employee permission and bottom-navigation coverage.
- Added assertions that verbose account headings and legacy tab strips do not
  render.
- Updated existing merchant portal and navigation coverage for the new labels
  and layout.

## Final Verification

Final command results:

- RSpec: 337 examples, 0 failures.
- RuboCop: 252 files inspected, no offenses.
- Zeitwerk: eager loading passed.
- Brakeman: 0 security warnings, 1 existing ignored warning.
- Seed: completed successfully with 21 users, 12 accounts, 9 products,
  5 services, 2 orders, and 1 booking.

## Remaining UI TODOs

- Help and Contact us are intentionally visible but disabled until support
  destinations are implemented.
- A future release may add merchant-scoped aliases such as `/merchant/team`
  and `/merchant/locations`; v1.3.6 retains the established canonical routes.
