import React, { useState } from 'react';
import { useCart } from '../context/CartContext';
import { useAuth } from '../context/AuthContext';
import { supabase } from '../supabaseClient';
import { useNavigate } from 'react-router-dom';
import Navbar from '../components/Navbar';
import { usePaystackPayment } from 'react-paystack';

const CheckoutPage: React.FC = () => {
    const { items, totalAmount, clearCart } = useCart();
    const { user } = useAuth();
    const navigate = useNavigate();

    const [address, setAddress] = useState('');
    const [city, setCity] = useState('');
    const [zip, setZip] = useState('');
    const [phone, setPhone] = useState('');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);

    // Paystack Configuration
    const config = {
        reference: (new Date()).getTime().toString(),
        email: user?.email || "",
        amount: totalAmount * 100, // Paystack uses Kobo
        publicKey: 'pk_test_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    };

    const initializePayment = usePaystackPayment(config);

    const onSuccess = async (reference: any) => {
        // This function is called after successful payment
        try {
            setLoading(true);

            // 1. Create Order
            const { data: orderData, error: orderError } = await supabase
                .from('orders')
                .insert({
                    user_id: user?.id,
                    total_amount: totalAmount,
                    status: 'processing',
                    shipping_address: {
                        address,
                        city,
                        zip,
                        phone,
                    },
                    payment_status: 'paid',
                    payment_reference: reference.reference
                })
                .select()
                .single();

            if (orderError) throw orderError;

            const orderId = orderData.id;

            // 2. Create Order Items
            const orderItemsData = items.map(item => ({
                order_id: orderId,
                product_id: item.product.id,
                quantity: item.quantity,
                price_at_purchase: item.product.discount_price || item.product.price,
            }));

            const { error: itemsError } = await supabase
                .from('order_items')
                .insert(orderItemsData);

            if (itemsError) throw itemsError;

            // 3. Clear Cart and Redirect
            clearCart();
            alert('Payment successful and order placed!');
            navigate('/orders');

        } catch (err: any) {
            console.error('Error post-payment:', err);
            setError(err.message || 'Payment was successful but order record failed. Please contact support.');
        } finally {
            setLoading(false);
        }
    };

    const onClose = () => {
        console.log('closed');
        setLoading(false);
    };

    const handleCheckoutInit = (e: React.FormEvent) => {
        e.preventDefault();
        if (!user) {
            navigate('/login');
            return;
        }

        if (!address || !city || !zip || !phone) {
            setError("Please fill in all shipping details");
            return;
        }

        setLoading(true);
        // @ts-ignore
        initializePayment(onSuccess, onClose);
    };

    if (items.length === 0) {
        return (
            <div className="min-h-screen bg-gray-50 font-sans text-brand-grey">
                <Navbar />
                <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 text-center">
                    <h2 className="text-2xl font-bold mb-4">Your cart is empty</h2>
                    <button onClick={() => navigate('/shop')} className="text-brand-blue hover:underline">
                        Go back to shop
                    </button>
                </main>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-gray-50 font-sans text-brand-grey">
            <Navbar />
            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <h1 className="text-3xl font-bold mb-8">Checkout</h1>
                <div className="flex flex-col lg:flex-row gap-8">
                    {/* Shipping Form */}
                    <div className="flex-1">
                        <div className="bg-white p-6 rounded-lg shadow-sm">
                            <h2 className="text-xl font-semibold mb-6">Shipping Information</h2>
                            <form onSubmit={handleCheckoutInit} className="space-y-4">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700">Address</label>
                                    <input
                                        type="text"
                                        required
                                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-brand-blue focus:ring-brand-blue sm:text-sm p-2 border"
                                        value={address}
                                        onChange={(e) => setAddress(e.target.value)}
                                    />
                                </div>
                                <div className="grid grid-cols-2 gap-4">
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700">City</label>
                                        <input
                                            type="text"
                                            required
                                            className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-brand-blue focus:ring-brand-blue sm:text-sm p-2 border"
                                            value={city}
                                            onChange={(e) => setCity(e.target.value)}
                                        />
                                    </div>
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700">ZIP Code</label>
                                        <input
                                            type="text"
                                            required
                                            className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-brand-blue focus:ring-brand-blue sm:text-sm p-2 border"
                                            value={zip}
                                            onChange={(e) => setZip(e.target.value)}
                                        />
                                    </div>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700">Phone</label>
                                    <input
                                        type="tel"
                                        required
                                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-brand-blue focus:ring-brand-blue sm:text-sm p-2 border"
                                        value={phone}
                                        onChange={(e) => setPhone(e.target.value)}
                                    />
                                </div>

                                {error && <div className="text-red-500 text-sm">{error}</div>}

                                <button
                                    type="submit"
                                    disabled={loading}
                                    className="w-full bg-brand-blue text-white py-3 px-4 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-brand-blue disabled:opacity-50 font-bold"
                                >
                                    {loading ? 'Processing...' : `Pay & Place Order (₦${totalAmount.toLocaleString()})`}
                                </button>
                            </form>
                        </div>
                    </div>

                    {/* Order Summary */}
                    <div className="lg:w-96">
                        <div className="bg-white p-6 rounded-lg shadow-sm sticky top-24">
                            <h2 className="text-xl font-semibold mb-4">Order Summary</h2>
                            <div className="space-y-4 max-h-96 overflow-auto">
                                {items.map((item) => (
                                    <div key={item.product.id} className="flex gap-4">
                                        <div className="w-16 h-16 bg-gray-100 rounded-md flex-shrink-0">
                                            <img
                                                src={item.product.image_url}
                                                alt={item.product.title}
                                                className="w-full h-full object-contain p-2"
                                            />
                                        </div>
                                        <div className="flex-1">
                                            <h3 className="text-sm font-medium line-clamp-2">{item.product.title}</h3>
                                            <p className="text-sm text-gray-500">Qty: {item.quantity}</p>
                                            <p className="text-sm font-medium text-brand-blue">
                                                ₦{(item.product.discount_price || item.product.price).toLocaleString()}
                                            </p>
                                        </div>
                                    </div>
                                ))}
                            </div>
                            <div className="border-t pt-4 mt-6">
                                <div className="flex justify-between text-base font-medium text-gray-900">
                                    <p>Total</p>
                                    <p>₦{totalAmount.toLocaleString()}</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    );
};

export default CheckoutPage;
