import React, { useEffect, useState } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';
import Navbar from '../components/Navbar';
import ProductCard from '../components/ProductCard';
import { Product } from '../types/product';
import { ProductService } from '../api/productService';
import { useCart } from '../context/CartContext';

const SearchResultsPage: React.FC = () => {
    const [searchParams] = useSearchParams();
    const query = searchParams.get('q') || '';
    const [products, setProducts] = useState<Product[]>([]);
    const [loading, setLoading] = useState(true);
    const navigate = useNavigate();
    const { addToCart } = useCart();

    useEffect(() => {
        const fetchResults = async () => {
            setLoading(true);
            try {
                const data = await ProductService.searchProducts(query);
                setProducts(data);
            } catch (error) {
                console.error("Search failed", error);
            } finally {
                setLoading(false);
            }
        };

        if (query) {
            fetchResults();
        }
    }, [query]);

    return (
        <div className="min-h-screen bg-gray-50">
            <Navbar />
            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <div className="mb-6">
                    <h1 className="text-2xl font-bold text-gray-900">
                        Search Results for <span className="text-brand-blue">"{query}"</span>
                    </h1>
                    <p className="text-gray-500 text-sm">{products.length} items found</p>
                </div>

                {loading ? (
                    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-6">
                        {[1, 2, 3, 4, 5].map(i => (
                            <div key={i} className="aspect-[4/5] bg-gray-200 rounded-xl animate-pulse"></div>
                        ))}
                    </div>
                ) : products.length > 0 ? (
                    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-6">
                        {products.map((product) => (
                            <ProductCard
                                key={product.id}
                                product={product}
                                onTap={() => navigate(`/product/${product.id}`)}
                                onAddToCart={() => addToCart(product)}
                            />
                        ))}
                    </div>
                ) : (
                    <div className="text-center py-20">
                        <div className="text-gray-400 mb-4">
                            <svg className="mx-auto w-16 h-16 fill-current" viewBox="0 0 24 24">
                                <path d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0016 9.5 6.5 6.5 0 109.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z" />
                            </svg>
                        </div>
                        <h2 className="text-xl font-medium text-gray-900 mb-2">No results found</h2>
                        <p className="text-gray-500">We couldn't find anything matching your search. Try different keywords.</p>
                    </div>
                )}
            </main>
        </div>
    );
};

export default SearchResultsPage;
