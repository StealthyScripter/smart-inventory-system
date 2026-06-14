# 01 Foundations

## Goals

- Stabilize the current inventory monolith.
- Document and test authorization.
- Separate marketplace-facing permissions from back-office inventory permissions.
- Prepare dormant schema decisions.

## Dependencies

- Existing users, roles, products, suppliers, locations, stock levels, stock movements.

## Models

- `User`
- `Supplier`
- `Product`
- `Category`
- `Location`
- `StockLevel`
- `StockMovement`

## Migrations

- Add durable audit log table.
- Add supplier-user ownership join when merchant work begins.

## Controllers

- Keep existing controllers.
- Add category controller if category management becomes required.

## Policies

- Formalize current `Authorization` behavior into tested permission methods before expanding roles.

## Services

- Extract stock adjustment service only if inventory operations expand beyond the current controller transaction.

## Jobs

- None required immediately.

## Routes

- Preserve existing inventory routes.

## Views

- Preserve current ERB views.

## Tests

- Add role/action matrix request specs.
- Add model specs for product, location, supplier, stock level, and stock movement.

