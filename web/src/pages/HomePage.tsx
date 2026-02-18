import React, { useEffect, useState } from 'react';
import Navbar from '../components/Navbar';
import ProductCard from '../components/ProductCard';
import CountdownTimer from '../components/CountdownTimer';
import { useCart } from '../context/CartContext';
import { Product } from '../types/product';
import { ProductService } from '../api/productService';
import { DealsService, Deal } from '../api/dealsService';
import { Laptop, Smartphone, Watch, Headphones, ArrowRight, History } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const CATEGORIES = [
    { label: 'Laptops', icon: Laptop },
    { label: 'Phones', icon: Smartphone },
    { label: 'Wearables', icon: Watch },
    { label: 'Audio', icon: Headphones },
];

const HomePage: React.FC = () => {
    const [products, setProducts] = useState<Product[]>([]);
    const [recentlyViewed, setRecentlyViewed] = useState<Product[]>([]);
    const [activeDeal, setActiveDeal] = useState<Deal | null>(null);
    const [loading, setLoading] = useState(true);
    const [loadingRecent, setLoadingRecent] = useState(false);
    const navigate = useNavigate();
    const { addToCart } = useCart();

    useEffect(() => {
        const fetchHomeData = async () => {
            try {
                // Fetch dynamic deal
                const dealData = await DealsService.getActiveDeal();
                if (dealData) {
                    setActiveDeal(dealData.deal);
                    setProducts(dealData.products);
                } else {
                    // Fallback to general deals/products
                    const fallbackData = await ProductService.getDeals();
                    setProducts(fallbackData);
                }

                // Fetch recently viewed
                const recentIds = JSON.parse(localStorage.getItem('recentlyViewed') || '[]');
                if (recentIds.length > 0) {
                    setLoadingRecent(true);
                    const recentProducts = await Promise.all(
                        recentIds.slice(0, 4).map((id: string) => ProductService.getProductById(id).catch(() => null))
                    );
                    setRecentlyViewed(recentProducts.filter(p => p !== null) as Product[]);
                    setLoadingRecent(false);
                }
            } catch (error) {
                console.error("Failed to fetch home data", error);
            } finally {
                setLoading(false);
            }
        };

        fetchHomeData();
    }, []);

    return (
        <div className="min-h-screen bg-gray-50 font-sans text-brand-grey pb-10">
            <Navbar />

            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 space-y-10">

                {/* Hero Section */}
                <div className="relative overflow-hidden rounded-2xl bg-gray-900 text-white h-[200px] sm:h-[300px] md:h-[400px]">
                    <div className="absolute inset-0">
                        <img
                            src="https://images.unsplash.com/photo-1550009158-9ebf69173e03?ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80"
                            alt="Hero Tech Background"
                            className="w-full h-full object-cover opacity-60"
                        />
                        <div className="absolute inset-0 bg-gradient-to-r from-black/80 to-transparent"></div>
                    </div>

                    <div className="relative z-10 h-full flex flex-col justify-center px-6 sm:px-12 max-w-2xl">
                        <h1 className="text-3xl sm:text-5xl font-extrabold leading-tight tracking-tight mb-4">
                            Step into the <br />
                            <span className="text-brand-blue">Gadget Revolution</span>
                        </h1>
                        <p className="text-gray-300 text-sm sm:text-lg mb-6 max-w-md hidden sm:block">
                            Experience the latest technology with our curated collection of premium devices.
                        </p>
                        <div>
                            <button className="bg-brand-blue hover:bg-blue-600 text-white font-semibold py-3 px-8 rounded-lg transition-all transform hover:scale-105 shadow-lg shadow-blue-500/30">
                                Shop Now
                            </button>
                        </div>
                    </div>
                </div>

                {/* Categories Grid */}
                <div className="flex justify-between sm:justify-center gap-4 sm:gap-12 overflow-x-auto pb-4 sm:pb-0 scrollbar-hide">
                    {CATEGORIES.map((cat) => (
                        <div key={cat.label} className="flex flex-col items-center gap-3 min-w-[70px] cursor-pointer group">
                            <div className="w-14 h-14 sm:w-16 sm:h-16 rounded-full bg-white border border-gray-100 shadow-sm flex items-center justify-center text-gray-700 group-hover:text-brand-blue group-hover:border-brand-blue transition-all">
                                <cat.icon size={24} />
                            </div>
                            <span className="text-xs sm:text-sm font-medium text-gray-600 group-hover:text-brand-blue transition-colors">
                                {cat.label}
                            </span>
                        </div>
                    ))}
                </div>

                {/* Deal of the Day Section */}
                <section>
                    <div className="flex items-center justify-between mb-6">
                        <div className="flex items-center gap-4">
                            <h2 className="text-xl sm:text-2xl font-bold text-gray-900">{activeDeal?.title || "Deal of the Day"}</h2>
                            {activeDeal?.end_time && (
                                <CountdownTimer endTime={new Date(activeDeal.end_time)} />
                            )}
                        </div>
                        <a href="#" className="text-brand-blue font-semibold text-sm hover:underline flex items-center gap-1">
                            View All <ArrowRight size={16} />
                        </a>
                    </div>

                    {loading ? (
                        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4 sm:gap-6 animate-pulse">
                            {[1, 2, 3, 4].map(i => (
                                <div key={i} className="aspect-[4/5] bg-gray-200 rounded-xl"></div>
                            ))}
                        </div>
                    ) : (
                        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4 sm:gap-6">
                            {products.length > 0 ? products.map((product) => (
                                <ProductCard
                                    key={product.id}
                                    product={product}
                                    onTap={() => navigate(`/product/${product.id}`)}
                                    onAddToCart={() => {
                                        addToCart(product);
                                        alert("Added to cart");
                                    }}
                                />
                            )) : (
                                <div className="col-span-full py-10 text-center text-gray-400">No active deals right now.</div>
                            )}
                        </div>
                    )}
                </section>

                {/* Recently Viewed Section */}
                {recentlyViewed.length > 0 && (
                    <section className="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
                        <div className="flex items-center gap-2 mb-6 text-gray-900">
                            <History size={20} className="text-brand-blue" />
                            <h2 className="text-xl font-bold">Jump Back In</h2>
                        </div>
                        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 sm:gap-6">
                            {recentlyViewed.map((product) => (
                                <div
                                    key={product.id}
                                    className="group cursor-pointer"
                                    onClick={() => navigate(`/product/${product.id}`)}
                                >
                                    <div className="aspect-square bg-gray-50 rounded-xl p-4 mb-3 flex items-center justify-center transition-transform group-hover:scale-[1.03]">
                                        <img
                                            src={product.image_url}
                                            alt={product.title}
                                            className="max-h-full max-w-full object-contain mix-blend-multiply"
                                        />
                                    </div>
                                    <h3 className="text-sm font-semibold text-gray-900 line-clamp-1 group-hover:text-brand-blue transition-colors">{product.title}</h3>
                                    <p className="text-brand-blue font-bold text-sm mt-1">
                                        {new Intl.NumberFormat('en-NG', { style: 'currency', currency: 'NGN', minimumFractionDigits: 0 }).format(product.discount_price ?? product.price)}
                                    </p>
                                </div>
                            ))}
                        </div>
                    </section>
                )}

            </main>
        </div>
    );
};

export default HomePage;
