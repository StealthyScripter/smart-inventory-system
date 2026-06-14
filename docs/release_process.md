# Release Process

## Pre-Release Checks

Run:

```sh
docker-compose run --rm -e RAILS_ENV=test app bundle exec rspec
docker-compose run --rm -e RAILS_ENV=test app bin/rubocop
docker-compose run --rm -e RAILS_ENV=test app bundle exec rails zeitwerk:check
docker-compose run --rm -e RAILS_ENV=test app bundle exec rails db:migrate:status
docker-compose run --rm app bundle exec brakeman
docker-compose run --rm app bin/rails db:seed
```

Confirm CI passes on the release branch.

## Version Tagging

Use annotated release notes in the repository or GitHub release, then tag from `main`:

```sh
git tag v1.0.0-freeze
```

Push the branch and tag together:

```sh
git push origin main
git push origin v1.0.0-freeze
```

## Rollback Notes

- Keep the previous release tag deployable.
- Restore database and uploaded file backups together.
- Roll back code first, then data only if the new release has written incompatible records.

## Changelog Process

Document:

- User-visible changes.
- Migrations.
- New operational requirements.
- Security fixes.
- Known TODOs and deferred integrations.
