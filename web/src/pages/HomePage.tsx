import React, { useEffect, useState } from 'react';
import Navbar from '../components/Navbar';
import ProductCard from '../components/ProductCard';
import CountdownTimer from '../components/CountdownTimer';
import Toast from '../components/Toast';
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
    const [toast, setToast] = useState<string | null>(null);
    const navigate = useNavigate();
    const { addToCart } = useCart();

    useEffect(() => {
        const fetchHomeData = async () => {
            try {
                const dealData = await DealsService.getActiveDeal();
                if (dealData) {
                    setActiveDeal(dealData.deal);
                    setProducts(dealData.products);
                } else {
                    const fallbackData = await ProductService.getDeals();
                    setProducts(fallbackData);
                }

                const recentIds = JSON.parse(localStorage.getItem('recentlyViewed') || '[]');
                if (recentIds.length > 0) {
                    const recentProducts = await Promise.all(
                        recentIds.slice(0, 4).map((id: string) => ProductService.getProductById(id).catch(() => null))
                    );
                    setRecentlyViewed(recentProducts.filter(p => p !== null) as Product[]);
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
        <div className="min-h-screen bg-gray-50 text-brand-grey pb-10">
            <Navbar />

            {toast && <Toast message={toast} onClose={() => setToast(null)} />}

            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 space-y-10">

                <div className="relative overflow-hidden rounded-2xl bg-gray-900 text-white h-[200px] sm:h-[300px] md:h-[400px]">
                    <div className="absolute inset-0">
                        <img
                            src="https://images.pexels.com/photos/356056/pexels-photo-356056.jpeg?auto=compress&cs=tinysrgb&w=1920&q=80"
                            alt="Hero Tech Background"
                            className="w-full h-full object-cover opacity-50"
                        />
                        <div className="absolute inset-0 bg-gradient-to-r from-black/90 via-black/50 to-transparent"></div>
                    </div>

                    <div className="relative z-10 h-full flex flex-col justify-center px-6 sm:px-12 max-w-2xl">
                        <p className="text-brand-blue text-xs sm:text-sm font-semibold uppercase tracking-widest mb-3">Premium Tech Store</p>
                        <h1 className="text-2xl sm:text-4xl md:text-5xl font-extrabold leading-tight tracking-tight mb-3 sm:mb-5">
                            Step into the <br />
                            <span className="text-brand-blue">Gadget Revolution</span>
                        </h1>
                        <p className="text-gray-300 text-sm sm:text-base mb-6 max-w-sm hidden sm:block leading-relaxed">
                            Discover the latest tech with our curated collection of premium devices.
                        </p>
                        <div>
                            <button
                                onClick={() => navigate('/shop')}
                                className="bg-brand-blue hover:bg-blue-600 text-white font-semibold py-2.5 sm:py-3 px-6 sm:px-8 rounded-xl transition-all hover:scale-105 shadow-lg shadow-blue-500/30 text-sm sm:text-base"
                            >
                                Shop Now
                            </button>
                        </div>
                    </div>
                </div>

                <div className="flex justify-start sm:justify-center gap-4 sm:gap-10 overflow-x-auto pb-2 scrollbar-hide">
                    {CATEGORIES.map((cat) => (
                        <button
                            key={cat.label}
                            onClick={() => navigate(`/category/${cat.label}`)}
                            className="flex flex-col items-center gap-2.5 min-w-[72px] group"
                        >
                            <div className="w-14 h-14 sm:w-16 sm:h-16 rounded-2xl bg-white border border-gray-200 shadow-sm flex items-center justify-center text-gray-600 group-hover:text-brand-blue group-hover:border-brand-blue group-hover:shadow-md transition-all">
                                <cat.icon size={22} />
                            </div>
                            <span className="text-xs sm:text-sm font-medium text-gray-600 group-hover:text-brand-blue transition-colors whitespace-nowrap">
                                {cat.label}
                            </span>
                        </button>
                    ))}
                </div>

                <section>
                    <div className="flex items-center justify-between mb-5">
                        <div className="flex items-center gap-3 flex-wrap">
                            <h2 className="text-xl sm:text-2xl font-bold text-gray-900">{activeDeal?.title || "Deal of the Day"}</h2>
                            {activeDeal?.end_time && (
                                <CountdownTimer endTime={new Date(activeDeal.end_time)} />
                            )}
                        </div>
                        <button
                            onClick={() => navigate('/shop')}
                            className="text-brand-blue font-semibold text-sm hover:underline flex items-center gap-1 flex-shrink-0"
                        >
                            View All <ArrowRight size={15} />
                        </button>
                    </div>

                    {loading ? (
                        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4 sm:gap-5 animate-pulse">
                            {[1, 2, 3, 4].map(i => (
                                <div key={i} className="aspect-[4/5] bg-gray-200 rounded-xl"></div>
                            ))}
                        </div>
                    ) : (
                        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4 sm:gap-5">
                            {products.length > 0 ? products.map((product) => (
                                <ProductCard
                                    key={product.id}
                                    product={product}
                                    onTap={() => navigate(`/product/${product.id}`)}
                                    onAddToCart={() => {
                                        addToCart(product);
                                        setToast('Added to cart');
                                    }}
                                />
                            )) : (
                                <div className="col-span-full py-10 text-center text-gray-400">No active deals right now.</div>
                            )}
                        </div>
                    )}
                </section>

                {recentlyViewed.length > 0 && (
                    <section className="bg-white rounded-2xl p-5 sm:p-6 border border-gray-100 shadow-sm">
                        <div className="flex items-center gap-2 mb-5 text-gray-900">
                            <History size={18} className="text-brand-blue" />
                            <h2 className="text-lg sm:text-xl font-bold">Jump Back In</h2>
                        </div>
                        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 sm:gap-5">
                            {recentlyViewed.map((product) => (
                                <div
                                    key={product.id}
                                    className="group cursor-pointer"
                                    onClick={() => navigate(`/product/${product.id}`)}
                                >
                                    <div className="aspect-square bg-gray-50 rounded-xl p-3 mb-2.5 flex items-center justify-center transition-transform group-hover:scale-[1.03]">
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
