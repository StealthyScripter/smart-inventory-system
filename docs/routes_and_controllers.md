# Routes And Controllers

## Route Map

| Method | Path | Controller action | Auth |
| --- | --- | --- | --- |
| GET | `/up` | `rails/health#show` | Public |
| GET | `/signup` | `users#new` | Public |
| POST | `/signup` | `users#create` | Public |
| GET | `/login` | `sessions#new` | Public |
| POST | `/login` | `sessions#create` | Public |
| DELETE | `/logout` | `sessions#destroy` | Login required |
| GET | `/admin/users` | `admin/users#index` | User management permission |
| GET | `/admin/users/:id/edit` | `admin/users#edit` | User management permission |
| PATCH/PUT | `/admin/users/:id` | `admin/users#update` | User management permission |
| CRUD | `/products` | `products` | Login required; writes restricted |
| CRUD | `/suppliers` | `suppliers` | Login required; writes restricted |
| CRUD | `/locations` | `locations` | Login required; writes restricted |
| GET | `/dashboard` | `dashboard#index` | Login required |
| GET | `/` | `dashboard#index` | Login required |
| GET | `/inventory` | `inventory#index` | Login required |
| POST | `/inventory/adjust` | `inventory#adjust_stock` | Inventory adjustment permission |

## Controllers

### `ApplicationController`

Provides login enforcement, `current_user`, and `logged_in?`.

### `SessionsController`

Handles login/logout with session reset on successful login and logout.

### `UsersController`

Handles public signup. New users are created without accepting a role parameter, so `User` defaults them to `guest`.

### `Admin::UsersController`

Allows admins and regional managers to manage user roles and locations. Regional managers cannot manage admins or other regional managers.

### `DashboardController`

Displays inventory metrics, inventory value, low-stock products, and recent movements. Location-scoped users see scoped movement data.

### `ProductsController`

Full CRUD for products. Product creation initializes stock levels for all locations. `show` supports HTML and a small JSON representation.

### `SuppliersController`

Full CRUD for passive supplier records. Suppliers with products cannot be deleted.

### `LocationsController`

Full CRUD for stock locations. Location creation initializes stock levels for all existing products.

### `InventoryController`

Displays stock levels and performs stock adjustments. Adjustments update `StockLevel` and create a `StockMovement` in one transaction.

## Namespaces

Only `admin` exists. There are no API, merchant, customer, or public namespaces yet.

