import React, { useEffect, useState } from 'react';
import Navbar from '../components/Navbar';
import { Product } from '../types/product';
import { ProductService } from '../api/productService';
import { Order, OrderService } from '../api/orderService';
import { useAuth } from '../context/AuthContext';
import { Plus, Edit, Trash, Package, Truck, CheckCircle, Clock, BarChart3, TrendingUp, AlertTriangle } from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

const VendorDashboardPage: React.FC = () => {
    const { user } = useAuth();
    const [products, setProducts] = useState<Product[]>([]);
    const [orders, setOrders] = useState<Order[]>([]);
    const [dailySales, setDailySales] = useState<{ date: string; sales: number }[]>([]);
    const [stats, setStats] = useState({ total_sales: 0, total_orders: 0, low_stock_count: 0 });
    const [loading, setLoading] = useState(true);
    const [activeTab, setActiveTab] = useState<'overview' | 'products' | 'orders'>('overview');

    const fetchData = async () => {
        setLoading(true);
        try {
            const productData = await ProductService.getProducts();
            setProducts(productData);

            const orderData = await OrderService.getVendorOrders();
            setOrders(orderData);

            const statsData = await OrderService.getVendorStats();
            setStats(statsData);

            const salesData = await OrderService.getDailySales();
            setDailySales(salesData);
        } catch (error) {
            console.error("Fetch data failed", error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchData();
    }, [user]);

    const handleUpdateStatus = async (orderId: string, status: string) => {
        try {
            await OrderService.updateOrderStatus(orderId, status);
            fetchData();
        } catch (error) {
            alert("Failed to update status");
        }
    };

    if (loading) return <div className="min-h-screen flex items-center justify-center">Loading...</div>;

    return (
        <div className="min-h-screen bg-gray-50 pb-20">
            <Navbar />
            <main className="max-w-7xl mx-auto px-4 py-8">
                <div className="flex justify-between items-center mb-8">
                    <h1 className="text-3xl font-bold">Vendor Dashboard</h1>
                    {activeTab === 'products' && (
                        <button className="bg-brand-blue text-white px-6 py-2 rounded-lg font-bold flex items-center gap-2">
                            <Plus size={20} /> Add Product
                        </button>
                    )}
                </div>

                {/* Stats Grid */}
                {activeTab === 'overview' && (
                    <>
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                            <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                                <div className="flex items-center gap-4 mb-2 text-green-600">
                                    <TrendingUp size={24} />
                                    <span className="font-bold uppercase tracking-wider text-xs">Total Sales</span>
                                </div>
                                <p className="text-3xl font-bold">₦{stats.total_sales.toLocaleString()}</p>
                            </div>
                            <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                                <div className="flex items-center gap-4 mb-2 text-blue-600">
                                    <BarChart3 size={24} />
                                    <span className="font-bold uppercase tracking-wider text-xs">Total Orders</span>
                                </div>
                                <p className="text-3xl font-bold">{stats.total_orders}</p>
                            </div>
                            <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                                <div className="flex items-center gap-4 mb-2 text-orange-600">
                                    <AlertTriangle size={24} />
                                    <span className="font-bold uppercase tracking-wider text-xs">Low Stock Alerts</span>
                                </div>
                                <p className="text-3xl font-bold">{stats.low_stock_count}</p>
                            </div>
                        </div>

                        {/* Sales Chart Section */}
                        <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 mb-8">
                            <h3 className="text-lg font-bold mb-6">Sales Performance (7 Days)</h3>
                            <div className="h-[300px] w-full">
                                <ResponsiveContainer width="100%" height="100%">
                                    <LineChart data={dailySales}>
                                        <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f0f0f0" />
                                        <XAxis
                                            dataKey="date"
                                            tick={{ fontSize: 12 }}
                                            tickFormatter={(val) => new Date(val).toLocaleDateString(undefined, { weekday: 'short' })}
                                        />
                                        <YAxis tick={{ fontSize: 12 }} />
                                        <Tooltip
                                            contentStyle={{ borderRadius: '12px', border: 'none', shadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                                            formatter={(val: number) => [`₦${val.toLocaleString()}`, 'Sales']}
                                        />
                                        <Line
                                            type="monotone"
                                            dataKey="sales"
                                            stroke="#1D4ED8"
                                            strokeWidth={3}
                                            dot={{ r: 6, fill: '#1D4ED8' }}
                                            activeDot={{ r: 8 }}
                                        />
                                    </LineChart>
                                </ResponsiveContainer>
                            </div>
                        </div>
                    </>
                )}

                {/* Tabs */}
                <div className="flex gap-4 mb-8">
                    <button
                        onClick={() => setActiveTab('overview')}
                        className={`px-6 py-2 rounded-lg font-bold transition-all ${activeTab === 'overview' ? 'bg-brand-blue text-white shadow-md' : 'bg-white text-gray-600 hover:bg-gray-100'}`}
                    >
                        Overview
                    </button>
                    <button
                        onClick={() => setActiveTab('products')}
                        className={`px-6 py-2 rounded-lg font-bold transition-all ${activeTab === 'products' ? 'bg-brand-blue text-white shadow-md' : 'bg-white text-gray-600 hover:bg-gray-100'}`}
                    >
                        Inventory
                    </button>
                    <button
                        onClick={() => setActiveTab('orders')}
                        className={`px-6 py-2 rounded-lg font-bold transition-all ${activeTab === 'orders' ? 'bg-brand-blue text-white shadow-md' : 'bg-white text-gray-600 hover:bg-gray-100'}`}
                    >
                        Fulfillment
                    </button>
                </div>

                <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
                    {activeTab === 'overview' && (
                        <div className="p-8 text-center text-gray-500">
                            Select Inventory or Fulfillment to manage your shop.
                        </div>
                    )}

                    {activeTab === 'products' && (
                        <table className="w-full text-left">
                            <thead className="bg-gray-50 border-b border-gray-100">
                                <tr>
                                    <th className="px-6 py-4 font-bold text-gray-900">Product</th>
                                    <th className="px-6 py-4 font-bold text-gray-900">Price</th>
                                    <th className="px-6 py-4 font-bold text-gray-900">Stock</th>
                                    <th className="px-6 py-4 font-bold text-gray-900 text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-gray-100">
                                {products.map((p) => (
                                    <tr key={p.id} className="hover:bg-gray-50 transition-colors">
                                        <td className="px-6 py-4 flex items-center gap-4">
                                            <img src={p.image_url} alt="" className="w-12 h-12 object-contain bg-gray-50 rounded" />
                                            <span className="font-medium text-gray-900">{p.title}</span>
                                        </td>
                                        <td className="px-6 py-4 text-gray-600">₦{p.price.toLocaleString()}</td>
                                        <td className="px-6 py-4 text-gray-600">{p.stock_quantity}</td>
                                        <td className="px-6 py-4 text-right flex justify-end gap-2">
                                            <button className="p-2 text-gray-400 hover:text-brand-blue"><Edit size={18} /></button>
                                            <button className="p-2 text-gray-400 hover:text-red-500"><Trash size={18} /></button>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    )}

                    {activeTab === 'orders' && (
                        <div className="divide-y divide-gray-100">
                            {orders.length === 0 ? (
                                <div className="p-12 text-center text-gray-500">No fulfillment orders yet.</div>
                            ) : (
                                orders.map((order) => (
                                    <div key={order.id} className="p-6">
                                        <div className="flex justify-between items-start mb-4">
                                            <div>
                                                <p className="font-bold text-gray-900">Order #{order.id.split('-')[0]}</p>
                                                <p className="text-sm text-gray-500">{new Date(order.created_at).toLocaleString()}</p>
                                            </div>
                                            <select
                                                value={order.status}
                                                onChange={(e) => handleUpdateStatus(order.id, e.target.value)}
                                                className="bg-gray-50 border border-gray-200 rounded-lg px-4 py-2 text-sm font-bold uppercase"
                                            >
                                                <option value="pending">Pending</option>
                                                <option value="processing">Processing</option>
                                                <option value="shipped">Shipped</option>
                                                <option value="delivered">Delivered</option>
                                                <option value="cancelled">Cancelled</option>
                                            </select>
                                        </div>
                                        <div className="bg-gray-50 rounded-lg p-4 grid grid-cols-2 md:grid-cols-4 gap-4">
                                            {order.order_items?.map(item => (
                                                <div key={item.id} className="flex items-center gap-2">
                                                    <img src={item.products?.image_url} alt="" className="w-8 h-8 object-contain" />
                                                    <span className="text-sm text-gray-600 truncate">{item.products?.title} (x{item.quantity})</span>
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                ))
                            )}
                        </div>
                    )}
                </div>
            </main>
        </div>
    );
};

export default VendorDashboardPage;
