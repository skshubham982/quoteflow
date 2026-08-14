-- QuoteFlow V3.2: billing + plan enforcement

alter table public.businesses add column if not exists plan text not null default 'free';
alter table public.businesses add column if not exists subscription_status text not null default 'inactive';
alter table public.businesses add column if not exists subscription_ends_at timestamptz;

create table if not exists public.subscriptions (
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null references auth.users(id) on delete cascade,
 plan text not null check (plan in ('pro','business')),
 status text not null default 'created',
 provider text not null default 'razorpay',
 provider_customer_id text,
 provider_subscription_id text unique,
 current_period_end timestamptz,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);

alter table public.subscriptions enable row level security;
drop policy if exists "subscription owner access" on public.subscriptions;
create policy "subscription owner access" on public.subscriptions for all using(owner_id=auth.uid()) with check(owner_id=auth.uid());

create index if not exists subscriptions_owner_idx on public.subscriptions(owner_id);

create or replace function public.enforce_quoteflow_plan_limits()
returns trigger
language plpgsql
security definer
set search_path=public
as $$
declare p text; n integer; m integer;
begin
  select coalesce(plan,'free') into p from public.businesses where id=NEW.business_id and owner_id=NEW.owner_id;
  if p='free' then
    if TG_TABLE_NAME='leads' then
      select count(*) into n from public.leads where owner_id=NEW.owner_id;
      if n >= 25 then raise exception 'FREE_PLAN_LEAD_LIMIT: Upgrade to Pro for unlimited leads.'; end if;
    elsif TG_TABLE_NAME='quotations' then
      select count(*) into m from public.quotations where owner_id=NEW.owner_id and date_trunc('month',created_at)=date_trunc('month',now());
      if m >= 10 then raise exception 'FREE_PLAN_QUOTE_LIMIT: Upgrade to Pro for unlimited quotations.'; end if;
    end if;
  end if;
  return NEW;
end $$;

drop trigger if exists quoteflow_lead_plan_limit on public.leads;
create trigger quoteflow_lead_plan_limit before insert on public.leads for each row execute function public.enforce_quoteflow_plan_limits();

drop trigger if exists quoteflow_quote_plan_limit on public.quotations;
create trigger quoteflow_quote_plan_limit before insert on public.quotations for each row execute function public.enforce_quoteflow_plan_limits();
