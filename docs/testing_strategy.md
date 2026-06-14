# Testing Strategy

## Current Test Stack

- RSpec Rails.
- Request specs for authentication, dashboard, inventory, products, suppliers, locations.
- Model spec coverage for user role normalization and scoped-role validation.
- `rails-controller-testing` enables `assigns` in request specs.
- Transactional fixtures are enabled.

## Covered Areas

- Login/logout and protected-route redirects.
- Dashboard access.
- Product listing/show/create/update/delete.
- Product stock-level initialization.
- Supplier listing/show.
- Location listing/create and stock-level backfill.
- Inventory stock adjustment and movement creation.
- Basic product permission denial for department managers.
- User role normalization and location requirement.

## Missing Areas

- Authorization matrix coverage for all roles and all guarded actions.
- Supplier create/update/delete edge cases.
- Location manager validation and update failures.
- Category behavior.
- Stock movement enum behavior and reference relationships.
- Dashboard data correctness for each role.
- JSON product endpoint.
- Dormant tables have no model coverage because models do not exist.
- System/browser tests are disabled and absent.
- Security regression tests for signup role assignment and user-management boundaries are limited.

## Coverage Measurement

No coverage tool such as SimpleCov is configured, so numeric coverage cannot be measured from the repository as-is.

## Marketplace Testing Direction

Preserve request specs as the primary confidence layer. Add model and service specs when workflows move out of controllers, especially checkout, stock reservation, payment webhook processing, fulfillment, RFQs, auctions, and analytics calculations.

