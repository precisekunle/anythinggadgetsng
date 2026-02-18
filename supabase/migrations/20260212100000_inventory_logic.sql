-- Add stock_quantity to products
alter table public.products
add column if not exists stock_quantity integer default 50;
-- Function to decrement stock when an order item is created
create or replace function public.decrement_stock_on_order() returns trigger language plpgsql security definer as $$ begin
update public.products
set stock_quantity = stock_quantity - new.quantity
where id = new.product_id;
-- Optional: Update stock_status if quantity hits 0
update public.products
set stock_status = false
where id = new.product_id
    and stock_quantity <= 0;
return new;
end;
$$;
-- Trigger to execute after inserting into order_items
create trigger on_order_item_created
after
insert on public.order_items for each row execute function public.decrement_stock_on_order();