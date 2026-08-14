# QuoteFlow V3.1

Commercial upgrade focused on the first customer-facing revenue feature: public quotations.

## New
- Public quotation URL: `/app.html?quote=TOKEN`
- Customer can view quotation without logging in
- Customer can Accept / Reject
- Response is saved to Supabase
- Quotation list has Copy link
- V3.1 landing page

## Deploy
Deploy the repository root to Vercel. `index.html` is the landing page and `app.html` is the application.

## Database
Run `supabase/schema_v3_1.sql` in the existing Supabase SQL Editor.

## Important security note
The public quotation RPC intentionally exposes only the quotation, business information, and lead customer/project fields needed to display the quote. Do not expose secret keys. The publishable Supabase key may be present in a browser app; never use the service-role key in frontend code.

## Next
Real subscription payments and server-side webhook verification.
