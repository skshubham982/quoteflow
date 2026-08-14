# QuoteFlow

Cloud-based quotation and lead follow-up SaaS for small businesses.

## Live demo
https://quoteflowv21cloud.vercel.app/

## Features
- Supabase email/password authentication
- Cloud-saved leads and quotations
- User-isolated data with Row Level Security
- Sales dashboard and pipeline
- Follow-up tracking
- Quotation builder and tax calculation
- WhatsApp follow-up
- Business settings
- Print / Save quotation as PDF
- Responsive interface

## Tech stack
HTML5 · CSS3 · JavaScript · Supabase · PostgreSQL · Vercel

## Project structure
```text
quoteflow/
├── index.html
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── .gitignore
├── .env.example
└── supabase/
    └── schema.sql
```

## Supabase setup
1. Create a Supabase project.
2. Run `supabase/schema.sql` in SQL Editor.
3. Enable Email authentication.
4. Configure Authentication → URL Configuration with your production URL.
5. Never commit a Supabase secret/service-role key.

## Deployment
Import this repository into Vercel or another static host. After deployment, set the Supabase Site URL to the production URL.

## Roadmap
- V2.2: quotation templates, customer profiles, quotation statuses, follow-up history
- V3: subscriptions, payments, teams, analytics, automated reminders, public quotation links

## License
MIT
