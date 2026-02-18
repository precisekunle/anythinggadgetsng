import React, { useEffect, useState } from 'react';
import Navbar from '../components/Navbar';
import { UserAddress } from '../types/user_address';
import { AddressService } from '../api/addressService';
import { useAuth } from '../context/AuthContext';
import { MapPin, Plus, Trash2, Edit3, CheckCircle } from 'lucide-react';

const AddressPage: React.FC = () => {
    const { user } = useAuth();
    const [addresses, setAddresses] = useState<UserAddress[]>([]);
    const [loading, setLoading] = useState(true);
    const [showForm, setShowForm] = useState(false);
    const [editingId, setEditingId] = useState<string | null>(null);
    const [formData, setFormData] = useState<Omit<UserAddress, 'id' | 'created_at'>>({
        user_id: user?.id || '',
        label: 'Home',
        full_name: '',
        phone_number: '',
        street: '',
        city: '',
        state: '',
        is_default: false
    });

    useEffect(() => {
        if (user) fetchAddresses();
    }, [user]);

    const fetchAddresses = async () => {
        if (!user) return;
        try {
            const data = await AddressService.getAddresses(user.id);
            setAddresses(data);
        } catch (error) {
            console.error("Fetch addresses failed", error);
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!user) return;
        try {
            if (editingId) {
                await AddressService.updateAddress({ ...formData, id: editingId, created_at: '' } as UserAddress);
            } else {
                await AddressService.addAddress({ ...formData, user_id: user.id });
            }
            setShowForm(false);
            setEditingId(null);
            fetchAddresses();
        } catch (error) {
            console.error("Save address failed", error);
        }
    };

    const handleDelete = async (id: string) => {
        if (!window.confirm("Delete this address?")) return;
        try {
            await AddressService.deleteAddress(id);
            fetchAddresses();
        } catch (error) {
            console.error("Delete failed", error);
        }
    };

    const handleSetDefault = async (id: string) => {
        if (!user) return;
        try {
            await AddressService.setDefaultAddress(user.id, id);
            fetchAddresses();
        } catch (error) {
            console.error("Set default failed", error);
        }
    };

    if (loading) return <div className="min-h-screen flex items-center justify-center">Loading...</div>;

    return (
        <div className="min-h-screen bg-gray-50 pb-20">
            <Navbar />
            <main className="max-w-4xl mx-auto px-4 py-8">
                <div className="flex justify-between items-center mb-8">
                    <h1 className="text-3xl font-bold">My Addresses</h1>
                    <button
                        onClick={() => { setShowForm(true); setEditingId(null); }}
                        className="bg-brand-blue text-white px-6 py-2 rounded-lg font-bold flex items-center gap-2"
                    >
                        <Plus size={20} /> Add New
                    </button>
                </div>

                {showForm && (
                    <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 mb-8 animate-in fade-in slide-in-from-top-4">
                        <h3 className="text-xl font-bold mb-6">{editingId ? 'Edit Address' : 'New Address'}</h3>
                        <form onSubmit={handleSubmit} className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <input placeholder="Label (e.g. Home)" className="p-3 border rounded-lg" value={formData.label} onChange={e => setFormData({ ...formData, label: e.target.value })} required />
                            <input placeholder="Full Name" className="p-3 border rounded-lg" value={formData.full_name} onChange={e => setFormData({ ...formData, full_name: e.target.value })} required />
                            <input placeholder="Phone" className="p-3 border rounded-lg" value={formData.phone_number} onChange={e => setFormData({ ...formData, phone_number: e.target.value })} required />
                            <input placeholder="Street" className="p-3 border rounded-lg" value={formData.street} onChange={e => setFormData({ ...formData, street: e.target.value })} required />
                            <input placeholder="City" className="p-3 border rounded-lg" value={formData.city} onChange={e => setFormData({ ...formData, city: e.target.value })} required />
                            <input placeholder="State" className="p-3 border rounded-lg" value={formData.state} onChange={e => setFormData({ ...formData, state: e.target.value })} required />
                            <div className="md:col-span-2 flex gap-4 mt-4">
                                <button type="submit" className="bg-brand-blue text-white px-8 py-3 rounded-lg font-bold">Save Address</button>
                                <button type="button" onClick={() => setShowForm(false)} className="px-8 py-3 font-bold text-gray-500">Cancel</button>
                            </div>
                        </form>
                    </div>
                )}

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    {addresses.map((addr) => (
                        <div key={addr.id} className={`bg-white p-6 rounded-2xl border-2 transition-all ${addr.is_default ? 'border-brand-blue ring-4 ring-brand-blue/5' : 'border-transparent shadow-sm'}`}>
                            <div className="flex justify-between items-start mb-4">
                                <div className="flex items-center gap-2">
                                    <div className={`p-2 rounded-lg ${addr.is_default ? 'bg-brand-blue text-white' : 'bg-gray-100 text-gray-500'}`}>
                                        <MapPin size={20} />
                                    </div>
                                    <span className="font-bold text-gray-900">{addr.label}</span>
                                    {addr.is_default && <span className="text-[10px] bg-brand-blue/10 text-brand-blue font-bold px-2 py-0.5 rounded uppercase">Default</span>}
                                </div>
                                <div className="flex gap-2">
                                    <button onClick={() => { setEditingId(addr.id); setFormData(addr); setShowForm(true); }} className="p-2 text-gray-400 hover:text-brand-blue"><Edit3 size={18} /></button>
                                    <button onClick={() => handleDelete(addr.id)} className="p-2 text-gray-400 hover:text-red-500"><Trash2 size={18} /></button>
                                </div>
                            </div>
                            <div className="space-y-1 text-gray-600">
                                <p className="font-bold text-gray-900">{addr.full_name}</p>
                                <p>{addr.street}</p>
                                <p>{addr.city}, {addr.state}</p>
                                <p className="text-sm pt-2">{addr.phone_number}</p>
                            </div>
                            {!addr.is_default && (
                                <button
                                    onClick={() => handleSetDefault(addr.id)}
                                    className="mt-6 text-sm font-bold text-brand-blue hover:underline flex items-center gap-1"
                                >
                                    <CheckCircle size={14} /> Set as Default
                                </button>
                            )}
                        </div>
                    ))}
                </div>
            </main>
        </div>
    );
};

export default AddressPage;
