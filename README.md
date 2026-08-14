# QuoteFlow V3.2

Commercial SaaS billing foundation built on Supabase + Razorpay Subscriptions.

## Included
- V3.1 public quotations preserved
- Free / Pro / Business plan UI
- Free-plan limits: 25 leads and 10 quotations/month
- Database triggers enforce those limits server-side
- Razorpay subscription checkout integration
- Secure server-side subscription creation via Supabase Edge Function
- Razorpay webhook verification and automatic plan activation/downgrade

## Required setup
Run `supabase/schema_v3_2.sql` in Supabase SQL Editor.

Deploy the two Edge Functions:
- `create-razorpay-subscription`
- `razorpay-webhook`

Set these function secrets:
- `RAZORPAY_KEY_ID`
- `RAZORPAY_KEY_SECRET`
- `RAZORPAY_PRO_PLAN_ID`
- `RAZORPAY_BUSINESS_PLAN_ID`
- `RAZORPAY_WEBHOOK_SECRET`

The Supabase function runtime already provides `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY`.

In Razorpay, create the monthly plans for ₹499 and ₹999, then copy their plan IDs into the secrets. Configure the webhook URL as:
`https://<your-project-ref>.supabase.co/functions/v1/razorpay-webhook`

Subscribe to the relevant subscription events, especially authenticated, activated, charged, pending, halted, cancelled, paused and resumed. Razorpay recommends webhooks for server-side subscription state and payment verification.

Do not commit Razorpay secrets to GitHub.
