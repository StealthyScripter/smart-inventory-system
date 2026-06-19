# Manual Test Scripts

## Guest

1. Visit `/`.
2. Confirm the catalog renders public marketplace listings.
3. Search for `cement`.
4. Open a product detail page and confirm SKU, unit cost, internal stock, and
   private inventory notes are not shown.
5. Visit `/services` and open a public service.
6. Visit `/merchants/:id` for Oak City Hardware.
7. Confirm merchant, inventory, and admin tools are not visible.

## Customer

1. Sign in at `/customers/sign_in` as `buyer.contractor@example.com`.
2. Confirm redirect/default navigation is catalog-first.
3. Add a public product to the cart.
4. Complete checkout with the manual/test payment flow.
5. View order history and tracking.
6. Book `Interior Design Consultation`.
7. Open customer bookings and verify status/history.
8. Start or view a conversation with a merchant.
9. Leave a review only for a completed purchase or booking.
10. Confirm merchant dashboard, inventory routes, enterprise settings, and admin
    pages are blocked.

## Individual Merchant

1. Sign in at `/merchants/sign_in` as `merchant.construction@example.com`.
2. Confirm landing on `/merchant`.
3. Update shop profile.
4. Create or edit an inventory product.
5. Create or edit the related marketplace listing.
6. Hide the listing and confirm inventory remains intact.
7. Process an order item.
8. Review analytics, messages, services, and bookings.
9. Confirm team-management routes are unavailable.

## Enterprise Merchant

1. Sign in at `/merchants/sign_in` as `merchant.hardware@example.com` using
   `password123` in local demo environments.
2. Confirm Team and Settings are visible.
3. Add an existing user as a member and confirm default role is employee.
4. Promote and demote a member.
5. Disable and re-enable member access.
6. Confirm the last owner/admin cannot be removed.
7. Sign in as `merchant.hardware.employee@example.com`.
8. Confirm employee permissions are limited immediately.

## Admin

1. Sign in at `/login` as `admin@inventory.com` using `password123` in local
   demo environments.
2. Visit `/admin/moderation`.
3. Hide and approve a listing.
4. Hide and approve a review.
5. Suspend and approve a merchant.
6. Review reports.
7. Confirm non-admin users cannot access admin routes.

## Payments

1. Complete a manual/test checkout.
2. Submit a valid simulated manual webhook.
3. Submit an invalid webhook signature and confirm it is rejected.
4. Submit the same valid webhook twice and confirm the duplicate is ignored.
5. Attempt Stripe payment without credentials and confirm it fails safely.
