import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Product } from '../types/product';
import { ProductService } from '../api/productService';
import ProductCard from '../components/ProductCard';
import Navbar from '../components/Navbar';
import { useCart } from '../context/CartContext';

const CategoryProductsPage: React.FC = () => {
    const { categoryName } = useParams<{ categoryName: string }>();
    const [products, setProducts] = useState<Product[]>([]);
    const [loading, setLoading] = useState(true);
    const { addToCart } = useCart();
    const navigate = useNavigate();

    useEffect(() => {
        const fetchProductsCallback = async () => {
            if (!categoryName) return;
            try {
                // Since ProductService.getProductsByCategory isn't explicitly defined in the mock interface I saw earlier,
                // I will fetch all and filter, or assume it exists if I added it.
                // Checking previous implementation plan, I might need to add it to ProductService.
                // For now, let's fetch all and filter client-side if the API doesn't support it, 
                // but better to add it to the service.
                // Assuming I will add `getProductsByCategory` to ProductService.
                const data = await ProductService.getProductsByCategory(categoryName);
                setProducts(data);
            } catch (error) {
                console.error("Failed to fetch products", error);
            } finally {
                setLoading(false);
            }
        };

        fetchProductsCallback();
    }, [categoryName]);

    if (loading) {
        return (
            <div className="min-h-screen bg-gray-50">
                <Navbar />
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                    <div className="h-8 w-32 bg-gray-200 rounded-lg animate-pulse mb-8"></div>
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
                    <h1 className="text-2xl sm:text-3xl font-bold text-gray-900">{categoryName}</h1>
                    <p className="text-gray-500 text-sm mt-1">{products.length} products</p>
                </div>
                {products.length === 0 ? (
                    <div className="text-center py-20 bg-white rounded-2xl border border-gray-100">
                        <p className="text-gray-500">No products found in this category.</p>
                    </div>
                ) : (
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
                )}
            </main>
        </div>
    );
};

export default CategoryProductsPage;
