import React from 'react';
import { useCart } from '../context/CartContext';
import Navbar from '../components/Navbar';
import { Trash2, Plus, Minus, ArrowLeft } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const CartPage: React.FC = () => {
    const { items, removeFromCart, updateQuantity, totalAmount, clearCart, itemCount } = useCart();
    const navigate = useNavigate();

    const formatCurrency = (amount: number) => {
        return new Intl.NumberFormat('en-NG', {
            style: 'currency',
            currency: 'NGN',
            minimumFractionDigits: 0,
        }).format(amount);
    };

    if (items.length === 0) {
        return (
            <div className="min-h-screen bg-gray-50 flex flex-col">
                <Navbar />
                <div className="flex-grow flex flex-col items-center justify-center p-4">
                    <div className="bg-white p-8 rounded-2xl shadow-sm text-center max-w-md w-full">
                        <div className="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-6">
                            <span className="text-4xl">🛒</span>
                        </div>
                        <h2 className="text-2xl font-bold text-gray-900 mb-2">Your cart is empty</h2>
                        <p className="text-gray-500 mb-8">Looks like you haven't added anything to your cart yet.</p>
                        <button
                            onClick={() => navigate('/')}
                            className="w-full bg-brand-blue hover:bg-blue-600 text-white font-bold py-3 px-6 rounded-lg transition-colors"
                        >
                            Start Shopping
                        </button>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-gray-50 font-sans text-brand-grey">
            <Navbar />

            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <div className="flex items-center gap-4 mb-8">
                    <button onClick={() => navigate(-1)} className="p-2 hover:bg-gray-200 rounded-full">
                        <ArrowLeft size={20} />
                    </button>
                    <h1 className="text-2xl font-bold text-gray-900">Shopping Cart ({itemCount} items)</h1>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    {/* Cart Items List */}
                    <div className="lg:col-span-2 space-y-4">
                        {items.map((item) => (
                            <div key={item.product.id} className="bg-white p-4 rounded-xl shadow-sm flex gap-4 border border-gray-100">
                                <div className="w-24 h-24 bg-gray-50 rounded-lg flex-shrink-0 p-2">
                                    <img
                                        src={item.product.image_url}
                                        alt={item.product.title}
                                        className="w-full h-full object-contain"
                                    />
                                </div>
                                <div className="flex-grow flex flex-col justify-between">
                                    <div className="flex justify-between items-start">
                                        <h3 className="font-semibold text-gray-900 line-clamp-2 pr-4">{item.product.title}</h3>
                                        <button
                                            onClick={() => removeFromCart(item.product.id)}
                                            className="text-gray-400 hover:text-red-500 transition-colors"
                                        >
                                            <Trash2 size={18} />
                                        </button>
                                    </div>
                                    <div className="flex justify-between items-end mt-2">
                                        <div className="flex items-center border border-gray-200 rounded-lg">
                                            <button
                                                onClick={() => updateQuantity(item.product.id, item.quantity - 1)}
                                                className="p-1.5 hover:bg-gray-50 text-gray-600"
                                            >
                                                <Minus size={14} />
                                            </button>
                                            <span className="w-8 text-center text-sm font-medium">{item.quantity}</span>
                                            <button
                                                onClick={() => updateQuantity(item.product.id, item.quantity + 1)}
                                                className="p-1.5 hover:bg-gray-50 text-gray-600"
                                            >
                                                <Plus size={14} />
                                            </button>
                                        </div>
                                        <div className="text-right">
                                            <div className="font-bold text-lg text-brand-grey">
                                                {formatCurrency((item.product.discount_price ?? item.product.price) * item.quantity)}
                                            </div>
                                            {item.quantity > 1 && (
                                                <div className="text-xs text-gray-500">
                                                    {formatCurrency(item.product.discount_price ?? item.product.price)} each
                                                </div>
                                            )}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>

                    {/* Order Summary */}
                    <div className="lg:col-span-1">
                        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 sticky top-24">
                            <h2 className="text-lg font-bold text-gray-900 mb-4">Order Summary</h2>
                            <div className="space-y-3 mb-6">
                                <div className="flex justify-between text-gray-600">
                                    <span>Subtotal</span>
                                    <span>{formatCurrency(totalAmount)}</span>
                                </div>
                                <div className="flex justify-between text-gray-600">
                                    <span>Shipping</span>
                                    <span className="text-green-600 font-medium">Free</span>
                                </div>
                                <div className="border-t border-gray-100 pt-3 flex justify-between font-bold text-lg text-gray-900">
                                    <span>Total</span>
                                    <span>{formatCurrency(totalAmount)}</span>
                                </div>
                            </div>
                            <button
                                onClick={() => {
                                    navigate('/checkout');
                                }}
                                className="w-full bg-brand-blue hover:bg-blue-600 text-white font-bold py-3 px-6 rounded-lg transition-colors shadow-lg shadow-blue-500/20"
                            >
                                Proceed to Checkout
                            </button>
                            <button
                                onClick={clearCart}
                                className="w-full mt-3 text-sm text-gray-500 hover:text-red-500 underline"
                            >
                                Clear Cart
                            </button>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    );
};

export default CartPage;
