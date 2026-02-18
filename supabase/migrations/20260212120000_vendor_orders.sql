-- Index for performance
create index if not exists products_shop_id_idx on public.products(shop_id);
create index if not exists order_items_product_id_idx on public.order_items(product_id);
-- Function for vendors to fetch orders containing THEIR products
create or replace function public.get_vendor_orders() returns setof public.orders language plpgsql security definer as $$ begin return query
select distinct o.*
from public.orders o
    join public.order_items oi on o.id = oi.order_id
    join public.products p on oi.product_id = p.id
    join public.shops s on p.shop_id = s.id
where s.owner_id = auth.uid();
end;
$$;
-- Allow vendors to update order status if it contains their products
-- This logic assumes that if a vendor owns a product in the order, they can update the status.
-- In a multi-vendor order, this might need refinement (e.g., vendor-specific status),
-- but for MVP, we allow the vendor to mark as 'processing', 'shipped', etc.
create policy "Vendors can update orders containing their products" on public.orders for
update using (
        exists (
            select 1
            from public.order_items oi
                join public.products p on oi.product_id = p.id
                join public.shops s on p.shop_id = s.id
            where oi.order_id = public.orders.id
                and s.owner_id = auth.uid()
        )
    ) with check (
        exists (
            select 1
            from public.order_items oi
                join public.products p on oi.product_id = p.id
                join public.shops s on p.shop_id = s.id
            where oi.order_id = public.orders.id
                and s.owner_id = auth.uid()
        )
    );