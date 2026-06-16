# v1.2.3 Account Navigation Plan

## Scope

- Keep marketplace, order, payment, inventory math, ownership, and authorization behavior intact.
- Change account-specific navigation, profile presentation, merchant marketplace previews, and small account-aware theme styling.
- Add only nullable merchant profile metadata fields needed to capture company information.

## Implementation Plan

1. Extract account-aware navigation and theme helpers so customer, individual merchant, and enterprise merchant menus render from one source.
2. Add customer and merchant profile pages as lightweight hubs. Customer profile prioritizes Orders and Bookings. Merchant profile displays company information and links to permitted merchant tools.
3. Add a merchant catalog preview page scoped to the logged-in merchant's products and marketplace listing records.
4. Update merchant services to read as a public marketplace preview with status and visibility badges.
5. Clarify merchant products as internal product records with linked marketplace status and product/listing actions.
6. Update merchant inventory to group quantities by product and location, with marketplace/private choices backed by product listing scope and marketplace status.
7. Keep enterprise-only team/settings links behind enterprise account checks and existing membership permissions.
8. Add request specs for navigation, profile prominence, merchant preview scoping, enterprise-only links, inventory listing controls, and theme body classes.

## Verification

- Run focused request specs while developing.
- Finish with Docker-based RSpec, RuboCop, Zeitwerk, and Brakeman checks.
