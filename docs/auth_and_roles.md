# Authentication And Roles

## Authentication

Authentication is implemented in the Rails monolith with:

- `User.has_secure_password`.
- `bcrypt`.
- Session cookie state using `session[:user_id]`.
- Login/logout in `SessionsController`.
- Signup in `UsersController`.
- `ApplicationController#require_login` as the default guard.

Public unauthenticated routes:

- `GET /signup`
- `POST /signup`
- `GET /login`
- `POST /login`
- `GET /up`

Logout resets the Rails session.

## Authorization

Authorization is implemented through `app/controllers/concerns/authorization.rb`, not Pundit or CanCanCan.

The app uses controller helper methods and `before_action` guards:

- `require_user_management_permission`
- `require_product_management_permission`
- `require_location_management_permission`
- `require_supplier_management_permission`
- `require_inventory_adjustment_permission`
- `require_delete_permission`

There are no policy classes.

## Role Hierarchy

Defined in `User::ROLE_HIERARCHY`:

1. `guest`
2. `customer`
3. `supplier`
4. `client`
5. `employee`
6. `department_manager`
7. `location_manager`
8. `regional_manager`
9. `admin`

Legacy aliases:

- `manager` normalizes to `regional_manager`.
- `supervisor` normalizes to `location_manager`.
- `staff` normalizes to `employee`.

## Role Capabilities

| Capability | Roles |
| --- | --- |
| Manage users | `admin`, `regional_manager` |
| Manage products | `admin`, `regional_manager` |
| Manage locations | `admin`, `regional_manager` |
| Manage suppliers | `admin`, `regional_manager` |
| Adjust inventory | `admin`, `regional_manager`, `location_manager`, `department_manager` |
| Delete records | `admin`, `regional_manager` |
| Access any location | `admin`, `regional_manager` |
| Access assigned location | `location_manager`, `department_manager`, `employee` |
| Read-only inventory users | `employee`, `client`, `supplier`, `customer`, `guest` |

## Location Scoping

Location-scoped roles are:

- `location_manager`
- `department_manager`
- `employee`

These roles must have `location_id` assigned. Inventory adjustments are restricted to the current user's assigned location unless the user is an admin or regional manager.

## Marketplace Implication

The role list already contains `supplier` and `customer`, but those roles currently behave as read-only inventory users. Marketplace evolution should reuse these roles carefully while adding explicit account ownership and marketplace permissions.

