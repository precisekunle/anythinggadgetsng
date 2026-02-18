export interface Shop {
    id: string;
    name: string;
    description?: string;
    logo_url?: string;
    banner_url?: string;
    address?: string;
    phone?: string;
    rating: number;
    is_verified: boolean;
}
