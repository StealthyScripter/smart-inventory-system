# Feature Inventory

## Status Legend

- COMPLETE: usable end-to-end for the current inventory scope.
- PARTIAL: implemented but limited or missing important workflow pieces.
- DORMANT: database or scaffold remnants exist, but no active application surface.
- NOT STARTED: no meaningful repository support.

## Inventory Management Features

| Feature | Status | Evidence |
| --- | --- | --- |
| Products | COMPLETE | `Product`, `ProductsController`, views, request specs, SKU uniqueness, category/supplier links |
| Categories | PARTIAL | `Category` model/table exists; no dedicated controller or management UI |
| Stock levels | COMPLETE | `StockLevel`, inventory index, product/location initialization |
| Stock movements | PARTIAL | `StockMovement` records inventory adjustments; no standalone movement UI or transfer workflow |
| Warehouses/locations | COMPLETE | `Location`, `LocationsController`, views, manager assignment |
| Suppliers | COMPLETE for inventory | `Supplier`, `SuppliersController`, views; passive supplier records only |
| Users | COMPLETE for inventory roles | Signup, login, admin user management, role hierarchy |
| Notifications | NOT STARTED | Only flash messages and placeholder PWA service worker comments |
| Reports | PARTIAL | Dashboard summary only; no report builder/export |
| Dashboards | PARTIAL | Inventory dashboard exists with counts, value, low stock, recent movements |
| Forecasting | DORMANT | `demand_forecasts` table only |
| Purchase orders | DORMANT | `purchase_orders` and `purchase_order_items` tables only |
| Sales transactions | DORMANT | `sales_transactions` table only |
| Audit logs | PARTIAL | `stock_movements` audit inventory adjustments; user role changes logged to Rails logger only |

## Marketplace Features

| Feature | Status | Evidence |
| --- | --- | --- |
| Merchants | PARTIAL | `supplier` role and `suppliers` table exist, but no merchant account ownership |
| Customers | PARTIAL | `customer` role exists, but no storefront, orders, addresses, or profiles |
| Public catalog | NOT STARTED | Product catalog requires login |
| Search/filtering | NOT STARTED | No query/filter UI beyond basic listing |
| Cart | NOT STARTED | No cart tables/controllers |
| Checkout | NOT STARTED | No checkout workflow |
| Payments | NOT STARTED | No payment models or integrations |
| Fulfillment | NOT STARTED | No shipment/fulfillment models |
| Delivery | NOT STARTED | No delivery models |
| Reviews/ratings | NOT STARTED | No review schema or UI |
| RFQs | NOT STARTED | No RFQ schema or workflow |
| Auctions | NOT STARTED | No auction schema or workflow |
| Analytics | PARTIAL | Dashboard metrics exist, no marketplace analytics |

