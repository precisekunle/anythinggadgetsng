-- ORDERS TABLE
create table public.orders (
    id uuid default gen_random_uuid() primary key,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    user_id uuid references auth.users not null,
    total_amount numeric not null,
    status text check (
        status in (
            'pending',
            'processing',
            'shipped',
            'delivered',
            'cancelled'
        )
    ) default 'pending',
    shipping_address jsonb not null,
    -- Stores full address object
    payment_status text default 'pending'
);
-- RLS for Orders
alter table public.orders enable row level security;
create policy "Users can view their own orders." on orders for
select using (auth.uid() = user_id);
create policy "Users can create their own orders." on orders for
insert with check (auth.uid() = user_id);
-- ORDER ITEMS TABLE
create table public.order_items (
    id uuid default gen_random_uuid() primary key,
    order_id uuid references public.orders not null,
    product_id uuid references public.products not null,
    quantity integer not null check (quantity > 0),
    price_at_purchase numeric not null -- Store price at time of purchase to handle price changes
);
-- RLS for Order Items
alter table public.order_items enable row level security;
create policy "Users can view their own order items." on order_items for
select using (
        exists (
            select 1
            from public.orders
            where id = order_items.order_id
                and user_id = auth.uid()
        )
    );
create policy "Users can create their own order items." on order_items for
insert with check (
        exists (
            select 1
            from public.orders
            where id = order_items.order_id
                and user_id = auth.uid()
        )
    );