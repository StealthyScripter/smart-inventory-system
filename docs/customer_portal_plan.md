# Customer Portal Plan

## Current Customer State

The `customer` role exists, but customer users currently receive broad read-only access to authenticated inventory screens. There is no public storefront, customer profile, order history, cart, saved items, or recommendation system.

## Target Capabilities

- Public storefront.
- Product detail pages.
- Search and filtering.
- Customer signup/login.
- Cart.
- Checkout.
- Order history.
- Saved items.
- Recommendations.

## Route Direction

Add customer/public routes inside the monolith:

- Public catalog: `catalog#index`, `catalog#show`.
- Customer account: `customer/dashboard`, `customer/orders`, `customer/saved_items`.
- Cart and checkout: `cart`, `checkout`.

## Data Direction

- Keep `User` for identity.
- Add customer profile fields only when needed.
- Add `Cart`, `CartItem`, `Order`, `OrderItem`, and `SavedItem` models.
- Reuse `products`, `categories`, `suppliers`, and `stock_levels` for catalog availability.

## Recommendations

- Separate back-office inventory views from customer storefront routes.
- Do not expose cost fields such as `unit_cost` publicly.
- Use `selling_price` as the initial storefront price.
- Base availability on `current_quantity - reserved_quantity`.

