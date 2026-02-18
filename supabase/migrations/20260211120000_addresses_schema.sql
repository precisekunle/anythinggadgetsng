-- ADDRESSES TABLE
create table public.addresses (
    id uuid default gen_random_uuid() primary key,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    user_id uuid references auth.users(id) not null,
    label text not null,
    -- e.g., 'Home', 'Office'
    full_name text not null,
    phone_number text not null,
    street text not null,
    city text not null,
    state text not null,
    is_default boolean default false
);
-- RLS for Addresses
alter table public.addresses enable row level security;
create policy "Users can view their own addresses." on public.addresses for
select using (auth.uid() = user_id);
create policy "Users can insert their own addresses." on public.addresses for
insert with check (auth.uid() = user_id);
create policy "Users can update their own addresses." on public.addresses for
update using (auth.uid() = user_id);
create policy "Users can delete their own addresses." on public.addresses for delete using (auth.uid() = user_id);