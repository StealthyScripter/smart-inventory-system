# Technology Stack

## Runtime

- Ruby: `3.4.4` from `.ruby-version`, Dockerfile, and workspace instructions.
- Rails: `8.1.1` in `Gemfile.lock`; `Gemfile` specifies `~> 8.1.1`.
- Database: SQLite via `sqlite3 2.7.4`.
- Web server: Puma `7.1.0`.
- Deployment tooling: Kamal and Thruster are present.

## Rails Frameworks

- Active Record
- Active Job
- Action Controller
- Action View
- Action Mailer
- Action Cable
- Active Storage
- Action Text
- Action Mailbox

Rails test unit is disabled in `config/application.rb`; RSpec is used instead.

## Frontend

- Server-rendered ERB views.
- Turbo Rails `2.0.20`.
- Stimulus Rails `1.3.4`.
- Importmap Rails `2.2.2`.
- Propshaft `1.3.1`.
- CSS is primarily in `app/views/layouts/application.html.erb`, `app/views/layouts/_styles.html.erb`, and `app/assets/stylesheets/application.css`.

There is no `package.json`; JavaScript dependencies are importmap-managed.

## Background Infrastructure

- Solid Queue `1.2.4`.
- Solid Cache `1.0.8`.
- Solid Cable `3.0.12`.
- Queue, cache, and cable schemas exist.
- Only the base `ApplicationJob` exists; no domain jobs exist yet.

## Security and Quality Tooling

- `bcrypt 3.1.20` for `has_secure_password`.
- Brakeman `7.1.0`.
- RuboCop Rails Omakase `1.1.0`.
- RSpec Rails `8.0.2`.
- `rails-controller-testing` is used for `assigns` in request specs.

## Development Environment

Development commands are intended to run from the outer workspace using Docker Compose. The compose service mounts the application into `/workspace`, stores bundle gems in the `smart_inventory_bundle` volume, and stores SQLite/log/tmp files under the outer `.dev/` directory.

