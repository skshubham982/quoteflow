# QuoteFlow V3

Commercial SaaS foundation for lead management, follow-ups and quotations.

## Structure
- `index.html` — V3 marketing/landing page
- `app.html` — working cloud application carried forward from V2.1
- `supabase/schema_v3.sql` — V3 subscription/public-quotation database additions

## Pricing
- Free — ₹0
- Pro — ₹499/month
- Business — ₹999/month

## Deployment
Deploy the repository root to Vercel. The landing page opens at `/`; the existing app is available at `/app.html`.

Review and run `supabase/schema_v3.sql` in the existing Supabase project.

Payment processing is not fabricated: connecting real subscriptions requires a payment provider account and secure server-side webhook handling.

Never commit Supabase secret/service-role keys.
