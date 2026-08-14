-- QuoteFlow V3.1: public quotation flow
-- Run after the existing QuoteFlow schema.

alter table public.quotations add column if not exists public_token text unique default encode(gen_random_bytes(12),'hex');
alter table public.quotations add column if not exists status text not null default 'draft';

create or replace function public.get_public_quotation(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare r jsonb;
begin
  select jsonb_build_object(
    'quotation', to_jsonb(q),
    'business', to_jsonb(b),
    'customer_name', l.customer_name,
    'project', l.project
  ) into r
  from public.quotations q
  join public.businesses b on b.id=q.business_id
  left join public.leads l on l.id=q.lead_id
  where q.public_token=p_token;
  return r;
end $$;

create or replace function public.respond_public_quotation(p_token text,p_status text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare qid uuid;
begin
  if lower(p_status) not in ('accepted','rejected') then
    raise exception 'Invalid quotation status';
  end if;
  update public.quotations
  set status=lower(p_status), updated_at=now()
  where public_token=p_token
  returning id into qid;
  if qid is null then raise exception 'Quotation not found'; end if;
  return jsonb_build_object('id',qid,'status',lower(p_status));
end $$;

revoke all on function public.get_public_quotation(text) from public;
grant execute on function public.get_public_quotation(text) to anon, authenticated;
revoke all on function public.respond_public_quotation(text,text) from public;
grant execute on function public.respond_public_quotation(text,text) to anon, authenticated;
