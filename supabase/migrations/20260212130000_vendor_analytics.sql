-- Function to get high-level stats for a vendor
create or replace function public.get_vendor_stats() returns json language plpgsql security definer as $$
declare total_sales numeric;
total_orders bigint;
low_stock_count bigint;
begin -- Total sales from orders containing vendor products
select coalesce(sum(oi.price_at_purchase * oi.quantity), 0) into total_sales
from public.order_items oi
    join public.products p on oi.product_id = p.id
    join public.shops s on p.shop_id = s.id
where s.owner_id = auth.uid();
-- Total unique orders
select count(distinct oi.order_id) into total_orders
from public.order_items oi
    join public.products p on oi.product_id = p.id
    join public.shops s on p.shop_id = s.id
where s.owner_id = auth.uid();
-- Products with stock < 10
select count(*) into low_stock_count
from public.products p
    join public.shops s on p.shop_id = s.id
where s.owner_id = auth.uid()
    and p.stock_quantity < 10;
return json_build_object(
    'total_sales',
    total_sales,
    'total_orders',
    total_orders,
    'low_stock_count',
    low_stock_count
);
end;
$$;