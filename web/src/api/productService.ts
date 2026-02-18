import { Product } from '../types/product';
import { supabase } from '../supabaseClient';

export const ProductService = {
    getProducts: async (): Promise<Product[]> => {
        const { data, error } = await supabase
            .from('products')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) throw error;
        return data || [];
    },

    getDeals: async (): Promise<Product[]> => {
        // Fetch deals logic, for now return all products or a subset
        const { data, error } = await supabase
            .from('products')
            .select('*')
            .limit(5);

        if (error) throw error;
        return data || [];
    },

    getProductsByCategory: async (category: string): Promise<Product[]> => {
        const { data, error } = await supabase
            .from('products')
            .select('*')
            .eq('category', category);

        if (error) throw error;
        return data || [];
    },

    getProductById: async (id: string): Promise<Product | undefined> => {
        const { data, error } = await supabase
            .from('products')
            .select('*')
            .eq('id', id)
            .single();

        if (error) return undefined;
        return data;
    },

    searchProducts: async (queryText: string): Promise<Product[]> => {
        const { data, error } = await supabase.rpc('search_products_fts', {
            search_query: queryText
        });

        if (error) throw error;
        return data || [];
    },

    getRelatedProducts: async (productId: string, limit: number = 4): Promise<Product[]> => {
        const { data, error } = await supabase.rpc('get_related_products', {
            p_id: productId,
            p_limit: limit
        });

        if (error) throw error;
        return data || [];
    },

    filterProducts: async (filters: {
        category?: string;
        minPrice?: number;
        maxPrice?: number;
        sortBy?: string;
    }): Promise<Product[]> => {
        let query = supabase.from('products').select('*');

        if (filters.category) {
            query = query.eq('category', filters.category);
        }
        if (filters.minPrice !== undefined) {
            query = query.gte('price', filters.minPrice);
        }
        if (filters.maxPrice !== undefined) {
            query = query.lte('price', filters.maxPrice);
        }

        if (filters.sortBy) {
            const [column, order] = filters.sortBy.split(':');
            query = query.order(column, { ascending: order === 'asc' });
        } else {
            query = query.order('created_at', { ascending: false });
        }

        const { data, error } = await query;
        if (error) throw error;
        return data || [];
    }
};
