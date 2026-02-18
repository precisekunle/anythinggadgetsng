-- SHOPS TABLE
create table public.shops (
    id uuid default gen_random_uuid() primary key,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    owner_id uuid references auth.users not null,
    -- The user who manages this shop
    name text not null,
    description text,
    logo_url text,
    banner_url text,
    address text,
    phone text,
    rating numeric default 0 check (
        rating >= 0
        and rating <= 5
    ),
    is_verified boolean default false
);
-- RLS for Shops
alter table public.shops enable row level security;
create policy "Shops are viewable by everyone." on shops for
select using (true);
create policy "Users can modify their own shop." on shops for all using (auth.uid() = owner_id);
-- UPDATE PRODUCTS TABLE
alter table public.products
add column shop_id uuid references public.shops;