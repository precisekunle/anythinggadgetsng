import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { supabase } from '../supabaseClient';
import { Shop } from '../types/shop';
import { Product } from '../types/product';
import Navbar from '../components/Navbar';
import ProductCard from '../components/ProductCard';
import { MapPin, Star, Search, Phone, Navigation } from 'lucide-react';
import { useCart } from '../context/CartContext';
import { useNavigate } from 'react-router-dom';

const VendorPage: React.FC = () => {
    const { id } = useParams<{ id: string }>();
    const [shop, setShop] = useState<Shop | null>(null);
    const [products, setProducts] = useState<Product[]>([]);
    const [loading, setLoading] = useState(true);
    const { addToCart } = useCart();
    const navigate = useNavigate();

    useEffect(() => {
        if (id) {
            fetchShopData(id);
        }
    }, [id]);

    const fetchShopData = async (shopId: string) => {
        try {
            // Fetch Shop
            const { data: shopData, error: shopError } = await supabase
                .from('shops')
                .select('*')
                .eq('id', shopId)
                .single();

            if (shopError) throw shopError;
            setShop(shopData);

            // Fetch Products
            const { data: productsData, error: productsError } = await supabase
                .from('products')
                .select('*')
                .eq('shop_id', shopId);

            if (productsError) throw productsError;
            setProducts(productsData || []);

        } catch (error) {
            console.error('Error fetching shop data:', error);
        } finally {
            setLoading(false);
        }
    };

    if (loading) {
        return <div className="min-h-screen bg-gray-50 flex items-center justify-center">Loading...</div>;
    }

    if (!shop) {
        return <div className="min-h-screen bg-gray-50 flex items-center justify-center">Shop not found</div>;
    }

    return (
        <div className="min-h-screen bg-gray-50 font-sans text-brand-grey">
            <Navbar />

            {/* Banner & Header */}
            <div className="bg-white pb-6 border-b border-gray-200">
                <div className="h-48 md:h-64 bg-gray-200 relative">
                    {shop.banner_url && (
                        <img
                            src={shop.banner_url}
                            alt="Banner"
                            className="w-full h-full object-cover"
                        />
                    )}
                    <div className="absolute -bottom-10 left-4 md:left-8">
                        <div className="w-24 h-24 md:w-32 md:h-32 bg-white rounded-full border-4 border-white shadow-md overflow-hidden">
                            {shop.logo_url ? (
                                <img
                                    src={shop.logo_url}
                                    alt={shop.name}
                                    className="w-full h-full object-cover"
                                />
                            ) : (
                                <div className="w-full h-full flex items-center justify-center bg-gray-100 text-gray-400">
                                    <span className="text-2xl font-bold">{shop.name.charAt(0)}</span>
                                </div>
                            )}
                        </div>
                    </div>
                </div>

                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-12 md:mt-4">
                    <div className="md:ml-36 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                        <div>
                            <div className="flex items-center gap-3">
                                <h1 className="text-2xl md:text-3xl font-bold text-gray-900">{shop.name}</h1>
                                {shop.is_verified && (
                                    <span className="bg-blue-100 text-blue-800 text-xs font-semibold px-2 py-0.5 rounded">Verified</span>
                                )}
                                <div className="flex items-center gap-1 bg-amber-100 px-2 py-0.5 rounded text-sm font-medium text-amber-800">
                                    <Star size={14} className="fill-amber-800" />
                                    {shop.rating}
                                </div>
                            </div>
                            {shop.address && (
                                <div className="flex items-center gap-1 text-gray-500 mt-1">
                                    <MapPin size={16} />
                                    <span>{shop.address}</span>
                                </div>
                            )}
                            {shop.description && (
                                <p className="text-gray-600 mt-2 max-w-2xl">{shop.description}</p>
                            )}
                        </div>

                        <div className="flex gap-3 w-full md:w-auto">
                            <button className="flex-1 md:flex-none items-center justify-center gap-2 bg-brand-blue text-white px-6 py-2 rounded-lg font-medium hover:bg-blue-700 transition-colors flex">
                                <Phone size={18} />
                                Contact
                            </button>
                            <button className="flex-1 md:flex-none items-center justify-center gap-2 border border-gray-300 text-gray-700 px-6 py-2 rounded-lg font-medium hover:bg-gray-50 transition-colors flex">
                                <Navigation size={18} />
                                Directions
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                {/* Search Within Shop */}
                <div className="mb-8 relative max-w-md">
                    <input
                        type="text"
                        placeholder={`Search within ${shop.name}...`}
                        className="w-full pl-10 pr-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-brand-blue focus:border-transparent outline-none"
                    />
                    <Search className="absolute left-3 top-3.5 text-gray-400" size={20} />
                </div>

                {/* Categories Pills (Static for now) */}
                <div className="flex gap-3 overflow-x-auto pb-4 mb-6">
                    {['All Items', 'Phones', 'Laptops', 'Accessories'].map((cat, i) => (
                        <button
                            key={cat}
                            className={`px-4 py-2 rounded-full whitespace-nowrap text-sm font-medium transition-colors ${i === 0
                                    ? 'bg-gray-900 text-white'
                                    : 'bg-white border border-gray-200 text-gray-700 hover:bg-gray-50'
                                }`}
                        >
                            {cat}
                        </button>
                    ))}
                </div>

                {/* Products Grid */}
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                    {products.map((product) => (
                        <ProductCard
                            key={product.id}
                            product={product}
                            onTap={() => navigate(`/product/${product.id}`)}
                            onAddToCart={() => {
                                addToCart(product);
                                alert("Added to cart");
                            }}
                        />
                    ))}
                </div>
                {products.length === 0 && (
                    <div className="text-center py-12 text-gray-500">
                        No products found in this shop.
                    </div>
                )}
            </main>
        </div>
    );
};

export default VendorPage;
