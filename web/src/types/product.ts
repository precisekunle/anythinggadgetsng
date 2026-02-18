export interface Product {
    id: string; // uuid
    title: string;
    price: number; // numeric
    discount_price?: number; // numeric, nullable
    image_url: string;
    category: string;
    stock_status: boolean;
    stock_quantity: number;
    shop_id?: string;
    description?: string;
    specs?: any;
    deal_id?: string;
}
