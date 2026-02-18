import { supabase } from '../supabaseClient';
import { Product } from '../types/product';

export interface Deal {
    id: string;
    title: string;
    end_time: string;
    is_active: boolean;
}

export interface ActiveDealResponse {
    deal: Deal;
    products: Product[];
}

export const DealsService = {
    getActiveDeal: async (): Promise<ActiveDealResponse | null> => {
        const { data, error } = await supabase.rpc('get_active_deal_with_products');
        if (error) throw error;
        return data as ActiveDealResponse;
    }
};
