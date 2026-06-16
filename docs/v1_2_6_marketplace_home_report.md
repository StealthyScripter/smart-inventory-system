# v1.2.6 Marketplace Home Experience Report

## Homepage changes
- Rebuilt the root marketplace page as a long, sectioned landing page.
- Added a prominent marketplace hero with CTA buttons and featured product/service/merchant previews.
- Added multiple curated sections: popular goods, building materials, electrical and plumbing, services near you, top merchants, recommended for projects, home and interior services, and recently added.
- Kept private, local, draft, archived, and otherwise non-public listings out of the public landing page.

## Header changes
- Added a dedicated Home header for guests and signed-in customers.
- Included logo/brand, centered search, account area, and cart link in the top row.
- Hid the standard account top bar on Home to avoid duplicate header chrome.
- Removed the old cluttered title/search stack from the landing page.

## Menu strip changes
- Added a horizontal category strip below the header.
- Included quick links for departments, services, deals, trending, building materials, electrical, plumbing, paint, interior design, AC services, hardware, and merchants.
- Enabled horizontal scrolling behavior for smaller widths.

## Sections added
- Popular goods
- Building materials
- Electrical and plumbing
- Services near you
- Top merchants
- Recommended for projects
- Home and interior services
- Recently added

## Card layout improvements
- Added dedicated marketplace card partials for products, services, and merchants.
- Varied card density and media aspect ratios for a less repetitive page.
- Added sale price presentation when listing data includes it.
- Added clearer actions such as View, Book, and View shop.

## Roboto / font decision
- Applied a Roboto-first font stack with system fallbacks:
  - `Roboto, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif`
- No font files were added or bundled.

## Accessibility / ADA notes
- Search input has an accessible label.
- Cart and account links have accessible labels.
- Focus visibility remains enabled through the shared focus ring.
- Card and menu targets remain keyboard-accessible.
- Section hierarchy uses semantic headings and supporting subtitles.
- Color contrast remains driven by shared theme tokens and card borders.

## Responsive testing notes
- Verified the homepage request specs for guest and authenticated customer access.
- Verified the full Rails test suite, RuboCop, Zeitwerk, and Brakeman.
- Responsive behavior was implemented through breakpoint rules for header, hero, menu strip, card rails, and mixed grids.
- No live browser screenshot capture was available in this environment, so visual QA was validated through the layout structure and automated coverage.

## Remaining UI TODOs
- Real production data should be used to confirm the best ordering of section content.
- If future seed data changes, the category-specific sections may need minor retuning.
- A browser screenshot pass on Linux/Chrome would still be useful against real content density.
