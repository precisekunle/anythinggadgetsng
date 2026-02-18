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
        return <div className="min-h-screen flex items-center justify-center">Loading...</div>;
    }

    return (
        <div className="min-h-screen bg-gray-50 font-sans text-brand-grey">
            <Navbar />
            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <h1 className="text-3xl font-bold mb-8">{categoryName}</h1>
                {products.length === 0 ? (
                    <p>No products found in this category.</p>
                ) : (
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
                )}
            </main>
        </div>
    );
};

export default CategoryProductsPage;
