-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- PRODUCTS TABLE
create table public.products (
  id uuid default uuid_generate_v4() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  title text not null,
  price numeric not null, -- Stores the raw price (e.g., 2150000)
  discount_price numeric, -- Nullable, raw price
  image_url text not null,
  category text not null, -- e.g., 'Phones', 'Laptops'
  stock_status boolean default true,
  description text,
  specs jsonb -- Flexible column for technical specs (screen size, processor, etc.)
);

-- RLS (Row Level Security) for Products - Public Read
alter table public.products enable row level security;
create policy "Products are viewable by everyone" on public.products
  for select using (true);

-- DEALS TABLE (For Deal of the Day)
create table public.deals (
  id uuid default uuid_generate_v4() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  title text not null, -- e.g., "Flash Sale"
  end_time timestamp with time zone not null,
  is_active boolean default true
);

-- RLS for Deals - Public Read
alter table public.deals enable row level security;
create policy "Deals are viewable by everyone" on public.deals
  for select using (true);

-- Sample Data Seeding (Optional)
insert into public.products (title, price, discount_price, image_url, category, stock_status) values 
('iPhone 15 Pro Max 256GB', 2150000, 1850000, 'https://fdn2.gsmarena.com/vv/pics/apple/apple-iphone-15-pro-max-1.jpg', 'Phones', true),
('MacBook Air M2 13"', 1600000, 1450000, 'https://fdn2.gsmarena.com/vv/pics/apple/apple-macbook-air-m2-2022-1.jpg', 'Laptops', true),
('Sony WH-1000XM5', 550000, 450000, 'https://m.media-amazon.com/images/I/41D5CgWzC4L._AC_SY879_.jpg', 'Audio', true),
('Samsung S24 Ultra', 2000000, 1900000, 'https://fdn2.gsmarena.com/vv/pics/samsung/samsung-galaxy-s24-ultra-5g-1.jpg', 'Phones', true);
