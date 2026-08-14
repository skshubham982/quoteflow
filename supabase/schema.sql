create extension if not exists "pgcrypto";

create table if not exists public.businesses (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  phone text, email text, address text, logo_url text, terms text,
  created_at timestamptz not null default now()
);

create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  business_id uuid references public.businesses(id) on delete cascade,
  customer_name text not null, phone text, project text not null,
  quotation_amount numeric(14,2) default 0,
  quotation_date date, follow_up_date date,
  status text not null default 'New Lead',
  next_action text, notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.quotations (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  business_id uuid references public.businesses(id) on delete cascade,
  lead_id uuid references public.leads(id) on delete set null,
  quotation_number text not null,
  valid_until date,
  tax_percent numeric(6,2) default 0,
  items jsonb not null default '[]'::jsonb,
  subtotal numeric(14,2) default 0,
  tax_amount numeric(14,2) default 0,
  total numeric(14,2) default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.businesses enable row level security;
alter table public.leads enable row level security;
alter table public.quotations enable row level security;

create policy "business owner access" on public.businesses
for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create policy "lead owner access" on public.leads
for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create policy "quotation owner access" on public.quotations
for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create index if not exists leads_owner_followup_idx on public.leads(owner_id, follow_up_date);
create index if not exists leads_owner_status_idx on public.leads(owner_id, status);
create index if not exists quotations_owner_idx on public.quotations(owner_id);
