import { supabase } from '../supabaseClient';
import { Review } from '../types/review';

export const ReviewService = {
    getProductReviews: async (productId: string): Promise<Review[]> => {
        const { data, error } = await supabase
            .from('reviews')
            .select('*')
            .eq('product_id', productId)
            .order('created_at', { ascending: false });

        if (error) throw error;
        return data || [];
    },

    submitReview: async (review: Omit<Review, 'id' | 'created_at'>): Promise<void> => {
        const { error } = await supabase
            .from('reviews')
            .upsert(review);

        if (error) throw error;
    },

    uploadReviewImage: async (file: File): Promise<string> => {
        const fileExt = file.name.split('.').pop();
        const fileName = `${Math.random()}.${fileExt}`;
        const filePath = `reviews/${fileName}`;

        const { error: uploadError } = await supabase.storage
            .from('review-images')
            .upload(filePath, file);

        if (uploadError) {
            throw uploadError;
        }

        const { data } = supabase.storage
            .from('review-images')
            .getPublicUrl(filePath);

        return data.publicUrl;
    },

    getAverageRating: async (productId: string): Promise<number> => {
        const { data, error } = await supabase
            .from('reviews')
            .select('rating')
            .eq('product_id', productId);

        if (error) throw error;
        if (!data || data.length === 0) return 0;

        const total = data.reduce((sum, item) => sum + item.rating, 0);
        return total / data.length;
    }
};
