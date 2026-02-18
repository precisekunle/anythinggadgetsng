-- Add a generated search vector column to products
alter table public.products
add column if not exists fts tsvector generated always as (
        to_tsvector(
            'english',
            title || ' ' || coalesce(description, '')
        )
    ) stored;
-- Create an index for the FTS column
create index if not exists products_fts_idx on public.products using gin(fts);
-- Create a search function that uses the FTS index
create or replace function public.search_products_fts(search_query text) returns setof public.products language sql as $$
select *
from public.products
where fts @@ websearch_to_tsquery('english', search_query)
order by ts_rank(
        fts,
        websearch_to_tsquery('english', search_query)
    ) desc;
$$;