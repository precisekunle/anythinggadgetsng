-- Link products to deals
alter table public.products
add column if not exists deal_id uuid references public.deals;
-- Create an index for deal_id
create index if not exists products_deal_id_idx on public.products(deal_id);
-- Seeding a sample deal if none exists
insert into public.deals (title, end_time, is_active)
values ('Flash Sale', now() + interval '24 hours', true) on conflict do nothing;
-- Link some products to the flash sale
-- Using subquery to find the flash sale id
update public.products
set deal_id = (
        select id
        from public.deals
        where title = 'Flash Sale'
        limit 1
    )
where title ilike '%iPhone%'
    or title ilike '%Samsung%';
-- Function to get the CURRENT active deal with its products
create or replace function public.get_active_deal_with_products() returns json language plpgsql security definer as $$
declare current_deal record;
deal_products json;
begin -- Get the first active deal that hasn't expired
select * into current_deal
from public.deals
where is_active = true
    and end_time > now()
order by created_at desc
limit 1;
if not found then return null;
end if;
-- Get products linked to this deal
select json_agg(p.*) into deal_products
from public.products p
where p.deal_id = current_deal.id;
return json_build_object(
    'deal',
    row_to_json(current_deal),
    'products',
    deal_products
);
end;
$$;