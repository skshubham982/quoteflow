-- QuoteFlow V3 additions
alter table public.businesses add column if not exists plan text not null default 'free';
alter table public.businesses add column if not exists subscription_status text not null default 'inactive';
alter table public.businesses add column if not exists subscription_ends_at timestamptz;

alter table public.quotations add column if not exists public_token text unique default encode(gen_random_bytes(12),'hex');
alter table public.quotations add column if not exists status text not null default 'draft';

create table if not exists public.subscriptions (
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null references auth.users(id) on delete cascade,
 plan text not null,
 status text not null default 'inactive',
 provider text,
 provider_customer_id text,
 provider_subscription_id text,
 current_period_end timestamptz,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);

alter table public.subscriptions enable row level security;
drop policy if exists "subscription owner access" on public.subscriptions;
create policy "subscription owner access" on public.subscriptions for all using(owner_id=auth.uid()) with check(owner_id=auth.uid());

create index if not exists subscriptions_owner_idx on public.subscriptions(owner_id);
create index if not exists quotations_public_token_idx on public.quotations(public_token);
