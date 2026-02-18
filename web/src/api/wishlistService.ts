import { supabase } from '../supabaseClient';
import { Product } from '../types/product';

export const WishlistService = {
    getWishlist: async (userId: string): Promise<Product[]> => {
        const { data, error } = await supabase
            .from('wishlist')
            .select('products (*)')
            .eq('user_id', userId);

        if (error) throw error;
        return data?.map((item: any) => item.products) || [];
    },

    addToWishlist: async (userId: string, productId: string): Promise<void> => {
        const { error } = await supabase
            .from('wishlist')
            .upsert({ user_id: userId, product_id: productId });

        if (error) throw error;
    },

    removeFromWishlist: async (userId: string, productId: string): Promise<void> => {
        const { error } = await supabase
            .from('wishlist')
            .delete()
            .eq('user_id', userId)
            .eq('product_id', productId);

        if (error) throw error;
    },

    isInWishlist: async (userId: string, productId: string): Promise<boolean> => {
        const { data, error } = await supabase
            .from('wishlist')
            .select('*')
            .eq('user_id', userId)
            .eq('product_id', productId)
            .maybeSingle();

        if (error) throw error;
        return !!data;
    }
};
