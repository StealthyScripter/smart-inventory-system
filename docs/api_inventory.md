# API Inventory

## Summary

The application is primarily server-rendered. It does not expose a dedicated JSON API namespace.

## JSON Endpoints

### `GET /products/:id.json`

Controller: `ProductsController#show`.

Authentication: login required by `ApplicationController`.

Response fields:

```json
{
  "id": 1,
  "name": "Product name",
  "sku": "SKU",
  "unit_cost": "10.0",
  "selling_price": "12.0"
}
```

The endpoint uses `@product.as_json(only: [...])`; there is no serializer, Jbuilder view, versioning, pagination, or error envelope.

## Non-API Form Endpoints

All other write operations are form-backed HTML endpoints using Rails strong parameters, redirects, flash messages, and CSRF protection.

## API Readiness Gaps

- No `/api` namespace.
- No token authentication.
- No JSON error contract.
- No pagination.
- No serializers.
- No public catalog API.
- No webhook receiver endpoints.

