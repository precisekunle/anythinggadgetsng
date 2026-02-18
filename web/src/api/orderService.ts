import { supabase } from '../supabaseClient';

export interface OrderItem {
    id: string;
    order_id: string;
    product_id: string;
    quantity: number;
    price_at_purchase: number;
    products?: {
        title: string;
        image_url: string;
    };
}

export interface Order {
    id: string;
    created_at: string;
    user_id: string;
    total_amount: number;
    status: string;
    shipping_address: any;
    payment_status: string;
    order_items?: OrderItem[];
}

export const OrderService = {
    getOrders: async (userId: string): Promise<Order[]> => {
        const { data, error } = await supabase
            .from('orders')
            .select('*, order_items(*, products(title, image_url))')
            .eq('user_id', userId)
            .order('created_at', { ascending: false });

        if (error) throw error;
        return data || [];
    },

    getOrderById: async (orderId: string): Promise<Order | undefined> => {
        const { data, error } = await supabase
            .from('orders')
            .select('*, order_items(*, products(title, image_url))')
            .eq('id', orderId)
            .single();

        if (error) return undefined;
        return data;
    },

    createOrder: async (order: Omit<Order, 'id' | 'created_at'>, items: Omit<OrderItem, 'id' | 'order_id'>[]): Promise<void> => {
        const { data: orderData, error: orderError } = await supabase
            .from('orders')
            .insert(order)
            .select()
            .single();

        if (orderError) throw orderError;

        const itemsWithOrderId = items.map(item => ({
            ...item,
            order_id: orderData.id
        }));

        const { error: itemsError } = await supabase
            .from('order_items')
            .insert(itemsWithOrderId);

        if (itemsError) throw itemsError;
    },

    getVendorOrders: async (): Promise<Order[]> => {
        const { data, error } = await supabase
            .rpc('get_vendor_orders')
            .select('*, order_items(*, products(title, image_url))');

        if (error) throw error;
        return data || [];
    },

    updateOrderStatus: async (orderId: string, status: string): Promise<void> => {
        const { error } = await supabase
            .from('orders')
            .update({ status })
            .eq('id', orderId);

        if (error) throw error;
    },

    getVendorStats: async (): Promise<{ total_sales: number; total_orders: number; low_stock_count: number }> => {
        const { data, error } = await supabase.rpc('get_vendor_stats');
        if (error) throw error;
        return data;
    },

    getDailySales: async (): Promise<{ date: string; sales: number }[]> => {
        const { data, error } = await supabase.rpc('get_vendor_daily_sales');
        if (error) throw error;
        return data || [];
    }
};
