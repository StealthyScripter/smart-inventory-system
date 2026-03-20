# Smart Inventory System

This application is now scoped to inventory management only.

## Current Scope

- Product catalog management
- Location management
- Supplier management
- Stock visibility across locations
- Audited stock adjustments
- Inventory dashboard and low-stock monitoring
- User access management for inventory roles

POS, ecommerce, sales, and forecasting workflows are intentionally out of scope for this codebase.

## Role Hierarchy

From highest to lowest access:

1. `admin`
2. `regional_manager`
3. `location_manager`
4. `department_manager`
5. `employee`, `client`, `supplier`
6. `guest`, `customer`

## Access Rules

- `admin` and `regional_manager` can manage products, locations, suppliers, and users across all locations.
- `location_manager` and `department_manager` can adjust inventory, but only in their assigned location.
- `employee`, `client`, `supplier`, `guest`, and `customer` are read-only.

## Architecture

- Rails 8 app with server-rendered ERB views
- SQLite for development, test, and production persistence
- Solid Queue, Solid Cache, and Solid Cable configured for production
- Hotwire via Turbo and Stimulus with importmap

## Core Data Model

- `users`
- `locations`
- `categories`
- `suppliers`
- `products`
- `stock_levels`
- `stock_movements`

Legacy purchasing, sales, and forecasting tables still exist in the schema, but they are no longer part of the active application surface.
