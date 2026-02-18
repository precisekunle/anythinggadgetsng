-- REVIEWS TABLE
CREATE TABLE public.reviews (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    user_id uuid REFERENCES auth.users(id) NOT NULL,
    product_id uuid REFERENCES public.products(id) NOT NULL,
    rating integer NOT NULL CHECK (
        rating >= 1
        AND rating <= 5
    ),
    comment text,
    CONSTRAINT one_review_per_user_per_product UNIQUE (user_id, product_id)
);
-- RLS for Reviews
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Reviews are viewable by everyone." ON public.reviews FOR
SELECT USING (true);
CREATE POLICY "Users can insert their own reviews." ON public.reviews FOR
INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own reviews." ON public.reviews FOR
UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own reviews." ON public.reviews FOR DELETE USING (auth.uid() = user_id);