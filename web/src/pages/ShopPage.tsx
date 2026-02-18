import React, { useEffect, useState } from 'react';
import { Product } from '../types/product';
import { ProductService } from '../api/productService';
import ProductCard from '../components/ProductCard';
import Navbar from '../components/Navbar';
import { useCart } from '../context/CartContext';
import { useNavigate } from 'react-router-dom';

const ShopPage: React.FC = () => {
    const [products, setProducts] = useState<Product[]>([]);
    const [loading, setLoading] = useState(true);
    const { addToCart } = useCart();
    const navigate = useNavigate();

    useEffect(() => {
        const fetchProducts = async () => {
            try {
                const data = await ProductService.getProducts();
                setProducts(data);
            } catch (error) {
                console.error("Failed to fetch products", error);
            } finally {
                setLoading(false);
            }
        };

        fetchProducts();
    }, []);

    if (loading) {
        return (
            <div className="min-h-screen bg-gray-50">
                <Navbar />
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                    <div className="h-8 w-48 bg-gray-200 rounded-lg animate-pulse mb-8"></div>
                    <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4 sm:gap-5">
                        {[1,2,3,4,5,6,7,8].map(i => <div key={i} className="aspect-[4/5] bg-gray-200 rounded-xl animate-pulse"></div>)}
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-gray-50 text-brand-grey">
            <Navbar />
            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <div className="mb-6">
                    <h1 className="text-2xl sm:text-3xl font-bold text-gray-900">Shop All Products</h1>
                    <p className="text-gray-500 text-sm mt-1">{products.length} products available</p>
                </div>
                <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4 sm:gap-5">
                    {products.map((product) => (
                        <ProductCard
                            key={product.id}
                            product={product}
                            onTap={() => navigate(`/product/${product.id}`)}
                            onAddToCart={() => addToCart(product)}
                        />
                    ))}
                </div>
            </main>
        </div>
    );
};

export default ShopPage;
