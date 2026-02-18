import React from 'react';
import { Product } from '../types/product';

interface ProductCardProps {
    product: Product;
    onAddToCart?: () => void;
    onTap?: () => void;
}

const ProductCard: React.FC<ProductCardProps> = ({ product, onAddToCart, onTap }) => {
    const formatCurrency = (amount: number) => {
        return new Intl.NumberFormat('en-NG', {
            style: 'currency',
            currency: 'NGN',
            minimumFractionDigits: 0,
        }).format(amount);
    };

    const discountPercent =
        product.discount_price && product.price > 0
            ? Math.round(((product.price - product.discount_price) / product.price) * 100)
            : null;

    return (
        <div
            className="group relative bg-white rounded-xl border border-gray-100 flex flex-col h-full overflow-hidden hover:shadow-lg transition-shadow duration-300 cursor-pointer"
            onClick={() => onTap?.()}
        >
            {/* Image Section */}
            <div className="relative aspect-[4/5] w-full bg-white p-4">
                <img
                    src={product.image_url}
                    alt={product.title}
                    className="h-full w-full object-contain object-center group-hover:scale-105 transition-transform duration-300"
                    loading="lazy"
                />

                {/* Discount Badge */}
                {discountPercent !== null && (
                    <div className="absolute top-3 left-3 bg-brand-blue text-white text-[10px] font-bold px-2 py-1 rounded">
                        -{discountPercent}%
                    </div>
                )}
            </div>

            {/* Details Section */}
            <div className="p-3 flex flex-col flex-grow">
                <h3 className="text-brand-grey text-sm font-semibold line-clamp-2 min-h-[40px] mb-1.5 leading-tight">
                    {product.title}
                </h3>

                {/* Rating Row */}
                <div className="flex items-center gap-1 mb-2">
                    <svg className="w-3.5 h-3.5 text-amber-400 fill-current" viewBox="0 0 20 20">
                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                    </svg>
                    <span className="text-xs text-gray-400">4.8 (120)</span>
                </div>

                <div className="mt-auto">
                    {/* Price Row */}
                    <div className="flex items-baseline gap-2 mb-3">
                        <span className="text-[15px] font-extrabold text-brand-grey">
                            {formatCurrency(product.discount_price ?? product.price)}
                        </span>
                    </div>

                    {/* Add to Cart Button */}
                    <button
                        onClick={(e) => {
                            e.preventDefault();
                            e.stopPropagation();
                            onAddToCart?.();
                        }}
                        className="w-full bg-[#F5F5F5] hover:bg-gray-200 text-brand-grey text-xs font-semibold py-2.5 rounded-lg transition-colors"
                    >
                        Add to Cart
                    </button>
                </div>
            </div>
        </div>
    );
};

export default ProductCard;
