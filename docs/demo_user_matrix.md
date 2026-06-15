# Demo User Matrix

Demo seeds use `DEMO_SEED_CREDENTIAL` when set. In local and staging-only demo
environments the fallback credential is `password123`. Do not use demo
credentials in production.

## Platform Users

| Email | Type | Purpose |
| --- | --- | --- |
| `admin@inventory.com` | Admin | Admin moderation, reports, and user governance |
| `customer@inventory.com` | Customer | Basic seeded buyer account |
| `buyer.contractor@example.com` | Customer | Marketplace order, notification, and review QA |
| `buyer.designer@example.com` | Customer | Pending order and buyer navigation QA |

## Individual Merchants

| Email | Merchant | Purpose |
| --- | --- | --- |
| `merchant.construction@example.com` | Triangle Construction Supply | Product listings, inventory, orders |
| `merchant.interiors@example.com` | Modern Nest Interiors | Service listings and bookings |
| `merchant.electrical@example.com` | BrightLine Electrical Contractors | Product/service marketplace QA |
| `merchant.plumbing@example.com` | BluePipe Plumbing Company | Product/service marketplace QA |
| `merchant.ac@example.com` | CoolAir AC Services | Service marketplace QA |

## Enterprise Merchant

| Email | Merchant | Expected Membership |
| --- | --- | --- |
| `merchant.hardware@example.com` | Oak City Hardware | owner |
| `merchant.hardware.employee@example.com` | Oak City Hardware | employee |

The enterprise account exists because the legacy `SupplierUser` seed links two
users to Oak City Hardware and `AccountBackfill` maps that supplier to an
enterprise merchant account.
