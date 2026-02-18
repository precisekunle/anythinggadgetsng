-- WISHLIST TABLE
CREATE TABLE public.wishlist (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    user_id uuid REFERENCES auth.users(id) NOT NULL,
    product_id uuid REFERENCES public.products(id) NOT NULL,
    CONSTRAINT one_wishlist_item_per_user_per_product UNIQUE (user_id, product_id)
);
-- RLS for Wishlist
ALTER TABLE public.wishlist ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own wishlist." ON public.wishlist FOR
SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can add to their own wishlist." ON public.wishlist FOR
INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can remove from their own wishlist." ON public.wishlist FOR DELETE USING (auth.uid() = user_id);