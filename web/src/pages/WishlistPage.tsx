import React, { useEffect, useState } from 'react';
import Navbar from '../components/Navbar';
import ProductCard from '../components/ProductCard';
import { Product } from '../types/product';
import { WishlistService } from '../api/wishlistService';
import { useAuth } from '../context/AuthContext';
import { useCart } from '../context/CartContext';
import { useNavigate } from 'react-router-dom';
import { Heart } from 'lucide-react';

const WishlistPage: React.FC = () => {
    const { user } = useAuth();
    const { addToCart } = useCart();
    const navigate = useNavigate();
    const [wishlistItems, setWishlistItems] = useState<Product[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchWishlist = async () => {
            if (!user) {
                setLoading(false);
                return;
            }
            try {
                const data = await WishlistService.getWishlist(user.id);
                setWishlistItems(data);
            } catch (error) {
                console.error("Failed to fetch wishlist", error);
            } finally {
                setLoading(false);
            }
        };

        fetchWishlist();
    }, [user]);

    if (!user) {
        return (
            <div className="min-h-screen bg-gray-50 flex flex-col items-center justify-center text-center p-4">
                <Navbar />
                <h2 className="text-2xl font-bold text-gray-900 mb-4">Please login to view your wishlist</h2>
                <button
                    onClick={() => navigate('/login')}
                    className="bg-brand-blue text-white px-8 py-3 rounded-lg font-bold"
                >
                    Login Now
                </button>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-white">
            <Navbar />
            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <div className="mb-8 border-b border-gray-100 pb-6">
                    <h1 className="text-3xl font-bold text-gray-900 flex items-center gap-3">
                        <Heart className="text-red-500" fill="currentColor" /> My Wishlist
                    </h1>
                    <p className="text-gray-500 mt-2">{wishlistItems.length} items saved</p>
                </div>

                {loading ? (
                    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-6">
                        {[1, 2, 3, 4, 5].map(i => <div key={i} className="aspect-[4/5] bg-gray-200 rounded-xl animate-pulse"></div>)}
                    </div>
                ) : wishlistItems.length === 0 ? (
                    <div className="text-center py-20 grayscale opacity-50">
                        <Heart size={64} className="mx-auto mb-4 text-gray-400" />
                        <h2 className="text-xl font-medium text-gray-900 mb-2">Wishlist is empty</h2>
                        <p className="text-gray-500 mb-8">Save products you're interested in for later.</p>
                        <button onClick={() => navigate('/shop')} className="text-brand-blue font-bold hover:underline">Start Shopping</button>
                    </div>
                ) : (
                    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-6">
                        {wishlistItems.map((product) => (
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
                )}
            </main>
        </div>
    );
};

export default WishlistPage;
