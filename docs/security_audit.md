# Security Audit

## Existing Controls

- `has_secure_password` with bcrypt.
- Session reset on login and logout.
- Default login requirement in `ApplicationController`.
- Strong parameters in controllers.
- Role normalization and validation.
- Location requirement for scoped inventory roles.
- Controller-level authorization guards.
- Parameter filtering includes password, email, token, secret, key, certificate, OTP, SSN, CVV, and CVC patterns.
- Brakeman is available in development/test.

## Weaknesses

1. Content Security Policy is commented out.
2. Authorization is helper-based and controller-local; there is no centralized policy object or complete role/action test matrix.
3. Read access to product, supplier, location, and inventory screens is broad for all logged-in users, including customer and guest roles.
4. Signup creates `guest` users, but there is no account verification, invitation, approval, rate limiting, or email confirmation.
5. Admin user update allows email changes without reauthentication or audit persistence.
6. Role changes are logged only to Rails logs, not to a durable audit table.
7. JSON product endpoint is authenticated but has no explicit authorization policy or API contract.
8. No lockout, throttling, MFA, password reset, or session management UI exists.
9. `config/master.key` exists in the repository tree and should be reviewed carefully before production use.
10. Marketplace payments/webhooks are not implemented; future webhook endpoints must verify provider signatures.

## Recommendations

- Add policy/service tests for every role and guarded action before expanding permissions.
- Enable and tune CSP.
- Add durable audit logging for role changes, inventory changes, payments, refunds, and order lifecycle events.
- Separate marketplace customer/merchant permissions from inventory back-office permissions.
- Add account lifecycle controls before public signup becomes marketplace signup.
- Keep Brakeman in CI once CI exists.

