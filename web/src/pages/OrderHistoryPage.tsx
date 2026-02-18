import React, { useEffect, useState } from 'react';
import Navbar from '../components/Navbar';
import { Order } from '../api/orderService';
import { OrderService } from '../api/orderService';
import { useAuth } from '../context/AuthContext';
import { supabase } from '../supabaseClient';
import { Package, ChevronDown, ChevronUp, Clock, CheckCircle2, Truck, Home, CreditCard } from 'lucide-react';

const OrderHistoryPage: React.FC = () => {
    const { user } = useAuth();
    const [orders, setOrders] = useState<Order[]>([]);
    const [loading, setLoading] = useState(true);
    const [expandedOrder, setExpandedOrder] = useState<string | null>(null);

    const fetchOrders = async () => {
        if (!user) return;
        try {
            const data = await OrderService.getOrders(user.id);
            setOrders(data);
        } catch (error) {
            console.error("Failed to fetch orders", error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        if (!user) return;
        fetchOrders();

        const channel = supabase
            .channel('order_status_updates')
            .on(
                'postgres_changes',
                {
                    event: '*',
                    schema: 'public',
                    table: 'orders',
                    filter: `user_id=eq.${user.id}`
                },
                (payload) => {
                    fetchOrders();
                }
            )
            .subscribe();

        return () => {
            supabase.removeChannel(channel);
        };
    }, [user]);

    const formatCurrency = (amount: number) => {
        return new Intl.NumberFormat('en-NG', { style: 'currency', currency: 'NGN', minimumFractionDigits: 0 }).format(amount);
    };

    const getOrderTimeline = (status: string) => {
        const stages = [
            { id: 'pending', label: 'Ordered', icon: CreditCard },
            { id: 'processing', label: 'Processing', icon: Package },
            { id: 'shipped', label: 'Shipped', icon: Truck },
            { id: 'delivered', label: 'Delivered', icon: Home },
        ];

        const currentIndex = stages.findIndex(s => s.id === status);

        return (
            <div className="flex items-center justify-between mt-6 mb-8 relative">
                <div className="absolute top-1/2 left-0 w-full h-0.5 bg-gray-100 -translate-y-1/2 z-0"></div>
                {stages.map((stage, index) => {
                    const isCompleted = index <= currentIndex;
                    const Icon = stage.icon;
                    return (
                        <div key={stage.id} className="relative z-10 flex flex-col items-center">
                            <div className={`w-10 h-10 rounded-full flex items-center justify-center border-2 ${isCompleted ? 'bg-brand-blue border-brand-blue text-white' : 'bg-white border-gray-200 text-gray-300'}`}>
                                <Icon size={18} />
                            </div>
                            <span className={`text-[10px] mt-2 font-bold uppercase tracking-tighter ${isCompleted ? 'text-brand-blue' : 'text-gray-400'}`}>
                                {stage.label}
                            </span>
                        </div>
                    );
                })}
            </div>
        );
    };

    const getDeliveryEstimate = (createdAt: string) => {
        const date = new Date(createdAt);
        const start = new Date(date);
        const end = new Date(date);
        start.setDate(date.getDate() + 3);
        end.setDate(date.getDate() + 5);

        const options: Intl.DateTimeFormatOptions = { month: 'short', day: 'numeric' };
        return `Estimated: ${start.toLocaleDateString(undefined, options)} - ${end.toLocaleDateString(undefined, options)}`;
    };

    if (loading) return <div className="min-h-screen flex items-center justify-center"><div className="animate-spin h-10 w-10 border-b-2 border-brand-blue rounded-full"></div></div>;

    return (
        <div className="min-h-screen bg-gray-50 pb-20">
            <Navbar />
            <main className="max-w-4xl mx-auto px-4 py-8">
                <h1 className="text-3xl font-bold mb-8">My Orders</h1>
                {orders.length === 0 ? (
                    <div className="text-center py-20 bg-white rounded-2xl shadow-sm">
                        <Package size={64} className="mx-auto text-gray-300 mb-4" />
                        <p className="text-gray-500">You haven't placed any orders yet.</p>
                    </div>
                ) : (
                    <div className="space-y-4">
                        {orders.map((order) => (
                            <div key={order.id} className="bg-white rounded-xl shadow-sm overflow-hidden border border-gray-100 transition-all">
                                <div
                                    className="p-6 flex items-center justify-between cursor-pointer hover:bg-gray-50"
                                    onClick={() => setExpandedOrder(expandedOrder === order.id ? null : order.id)}
                                >
                                    <div className="flex items-center gap-4">
                                        <div className="p-3 bg-brand-blue/10 rounded-lg text-brand-blue">
                                            <Package size={24} />
                                        </div>
                                        <div>
                                            <p className="font-bold text-gray-900">Order #{order.id.split('-')[0].toUpperCase()}</p>
                                            <p className="text-xs text-brand-blue font-semibold">{getDeliveryEstimate(order.created_at)}</p>
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-6">
                                        <div className="text-right">
                                            <p className="font-bold text-gray-900">{formatCurrency(order.total_amount)}</p>
                                            <span className={`text-[10px] font-bold px-2 py-0.5 rounded uppercase ${order.status === 'completed' || order.status === 'delivered' ? 'bg-green-100 text-green-700' :
                                                order.status === 'pending' ? 'bg-orange-100 text-orange-700' : 'bg-blue-100 text-blue-700'
                                                }`}>
                                                {order.status}
                                            </span>
                                        </div>
                                        {expandedOrder === order.id ? <ChevronUp size={20} /> : <ChevronDown size={20} />}
                                    </div>
                                </div>

                                {expandedOrder === order.id && (
                                    <div className="px-6 pb-6 border-t border-gray-50 pt-6 animate-in slide-in-from-top-2 duration-200">
                                        {/* Status Timeline */}
                                        <div className="max-w-md mx-auto">
                                            {getOrderTimeline(order.status)}
                                        </div>

                                        <h4 className="text-xs font-bold text-gray-900 mb-4 uppercase tracking-wider flex items-center gap-2">
                                            <div className="w-1 h-4 bg-brand-blue rounded-full"></div> Order Items
                                        </h4>
                                        <div className="space-y-4">
                                            {order.order_items?.map((item) => (
                                                <div key={item.id} className="flex items-center justify-between">
                                                    <div className="flex items-center gap-4">
                                                        <div className="w-12 h-12 bg-gray-50 rounded flex items-center justify-center border border-gray-100">
                                                            <img src={item.products?.image_url} alt="" className="max-h-full max-w-full object-contain" />
                                                        </div>
                                                        <div>
                                                            <p className="font-medium text-gray-900 text-sm">{item.products?.title}</p>
                                                            <p className="text-xs text-gray-500">Quantity: {item.quantity}</p>
                                                        </div>
                                                    </div>
                                                    <p className="font-bold text-gray-900 text-sm">{formatCurrency(item.price_at_purchase)}</p>
                                                </div>
                                            ))}
                                        </div>

                                        <div className="mt-8 pt-6 border-t border-gray-100 grid grid-cols-1 md:grid-cols-2 gap-6">
                                            <div>
                                                <p className="text-[10px] text-gray-400 uppercase font-black mb-1">Shipping Details</p>
                                                <p className="text-sm font-semibold text-gray-800">{order.shipping_address?.fullName}</p>
                                                <p className="text-xs text-gray-500">{order.shipping_address?.street}, {order.shipping_address?.city}</p>
                                            </div>
                                            <div className="md:text-right">
                                                <p className="text-[10px] text-gray-400 uppercase font-black mb-1">Payment Summary</p>
                                                <div className="flex justify-between md:justify-end gap-4">
                                                    <span className="text-xs text-gray-500">Order Total:</span>
                                                    <span className="text-lg font-black text-brand-blue">{formatCurrency(order.total_amount)}</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                )}
                            </div>
                        ))}
                    </div>
                )}
            </main>
        </div>
    );
};

export default OrderHistoryPage;
