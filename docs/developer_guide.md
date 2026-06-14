# Developer Guide

## Local Setup

Run commands from the outer `SmartInventoryFiles` workspace so Docker Compose can mount the Rails app and shared development storage correctly.

```sh
docker-compose up --build
docker-compose run --rm app bin/rails db:prepare
docker-compose run --rm app bin/rails db:seed
```

The application repository is `smart-inventory-system/`. Development and test SQLite databases, logs, and temporary files are stored outside the repository under `.dev/`.

## Common Commands

```sh
docker-compose run --rm app bin/rails db:migrate
docker-compose run --rm app bin/rails db:seed
docker-compose run --rm -e RAILS_ENV=test app bundle exec rspec
docker-compose run --rm -e RAILS_ENV=test app bin/rubocop
docker-compose run --rm -e RAILS_ENV=test app bundle exec rails zeitwerk:check
docker-compose run --rm app bundle exec brakeman
```

## Common Workflows

- Start with `git status` and keep application changes inside `smart-inventory-system/`.
- Use Rails migrations for schema changes and keep them backward-compatible.
- Prefer request specs for authorization and workflow coverage.
- Prefer model specs for validations, scopes, and data integrity.
- Keep marketplace behavior in existing Rails namespaces: `Merchant`, `Customer`, `Admin`, and public controllers.

## Marketplace Domain Overview

- Products: inventory-backed goods with marketplace visibility and supplier ownership.
- Services: merchant/provider service listings with booking support.
- Suppliers: merchant shops, profiles, media, and ownership boundary for merchant users.
- Customers: carts, orders, bookings, reviews, messages, and purchase analytics.
- Orders and payments: marketplace order lifecycle with manual/test payment abstraction only.
- Governance: reports, moderation actions, soft-delete/restore, and admin-only controls.
