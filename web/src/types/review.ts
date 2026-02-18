export interface Review {
    id: string;
    created_at: string;
    user_id: string;
    product_id: string;
    rating: number;
    comment: string | null;
    image_urls?: string[];
}
