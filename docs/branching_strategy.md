# Branching Strategy

## `main`

Stable release branch. Only merge code that passes CI and is ready for deployment or tagging.

## `develop`

Integration branch for approved stabilization work. Use this for tested improvements before promoting to `main`.

## `staging`

Pre-release validation branch. Deploy this branch to staging environments for release candidate verification.

## `experimental`

Short-lived exploration branch for prototypes. Do not treat this branch as production-ready, and do not merge it directly to `main` without review and tests.

## Rules

- Protect `main` with CI checks.
- Use pull requests for non-trivial changes.
- Keep feature work out of code-freeze branches.
- Tag releases from `main` after verification.
