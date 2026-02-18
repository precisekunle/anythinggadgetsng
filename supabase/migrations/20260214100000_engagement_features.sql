-- 1. Add image_urls to reviews
alter table public.reviews
add column if not exists image_urls text [] default '{}';
-- 2. Add estimated_delivery_at to orders
alter table public.orders
add column if not exists estimated_delivery_at timestamp with time zone;
-- 3. Function to get related products
-- Recommendations based on category, excluding current product, limited by count.
create or replace function public.get_related_products(p_id uuid, p_limit int default 4) returns json language plpgsql security definer as $$
declare target_category text;
related_products json;
begin -- Find the category of the target product
select category into target_category
from public.products
where id = p_id;
-- Fetch related products in the same category
select json_agg(p.*) into related_products
from (
        select *
        from public.products
        where category = target_category
            and id != p_id
            and stock_status = true
        limit p_limit
    ) p;
return related_products;
end;
$$;
-- 4. Storage Bucket for Review Images (Requires storage extension)
-- Note: This assumes the storage schema exists.
insert into storage.buckets (id, name, public)
values ('review-images', 'review-images', true) on conflict (id) do nothing;
-- Set up storage policies for review images
-- Everyone can view review images
create policy "Review images are publicly accessible" on storage.objects for
select using (bucket_id = 'review-images');
-- Authenticated users can upload their own images
create policy "Users can upload review images" on storage.objects for
insert with check (
        bucket_id = 'review-images'
        and auth.role() = 'authenticated'
    );