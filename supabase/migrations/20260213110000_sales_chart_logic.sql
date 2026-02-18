-- Function to get sales stats over the last 7 days for a vendor
create or replace function public.get_vendor_daily_sales() returns json language plpgsql security definer as $$ begin return (
        select json_agg(t)
        from (
                select date_trunc('day', o.created_at)::date as date,
                    sum(oi.price_at_purchase * oi.quantity) as sales
                from public.orders o
                    join public.order_items oi on o.id = oi.order_id
                    join public.products p on oi.product_id = p.id
                    join public.shops s on p.shop_id = s.id
                where s.owner_id = auth.uid()
                    and o.created_at > now() - interval '7 days'
                group by 1
                order by 1
            ) t
    );
end;
$$;