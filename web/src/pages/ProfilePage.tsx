import React from 'react';
import { useAuth } from '../context/AuthContext';
import { useNavigate } from 'react-router-dom';
import Navbar from '../components/Navbar';
import {
    ShoppingBag,
    Heart,
    MapPin,
    Bell,
    Shield,
    HelpCircle,
    LogOut,
    ChevronRight,
    User
} from 'lucide-react';

const ProfilePage: React.FC = () => {
    const { user, signOut } = useAuth();
    const navigate = useNavigate();

    const handleSignOut = async () => {
        await signOut();
        navigate('/login');
    };

    if (!user) {
        navigate('/login');
        return null;
    }

    return (
        <div className="min-h-screen bg-gray-50 font-sans text-brand-grey">
            <Navbar />

            <main className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <h1 className="text-2xl font-bold text-center mb-8">Profile</h1>

                {/* Profile Header */}
                <div className="bg-white p-8 rounded-2xl shadow-sm mb-8 flex flex-col items-center text-center">
                    <div className="w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center mb-4 overflow-hidden border-4 border-gray-50">
                        {user.user_metadata.avatar_url ? (
                            <img src={user.user_metadata.avatar_url} alt="Profile" className="w-full h-full object-cover" />
                        ) : (
                            <User size={40} className="text-gray-400" />
                        )}
                    </div>
                    <h2 className="text-xl font-bold text-gray-900">{user.user_metadata.full_name || 'Guest User'}</h2>
                    <p className="text-gray-500">{user.email}</p>
                </div>

                {/* Menu Sections */}
                <div className="space-y-6">
                    <section>
                        <h3 className="text-xs font-bold text-gray-400 uppercase mb-3 ml-2 tracking-wider">Shopping</h3>
                        <div className="bg-white rounded-xl shadow-sm overflow-hidden divide-y divide-gray-100">
                            <MenuItem icon={ShoppingBag} iconColor="text-blue-500" bg="bg-blue-50" label="My Orders" onClick={() => navigate('/orders')} />
                            <MenuItem icon={Heart} iconColor="text-blue-500" bg="bg-blue-50" label="Wishlist" onClick={() => navigate('/wishlist')} />
                            <MenuItem icon={MapPin} iconColor="text-blue-500" bg="bg-blue-50" label="Delivery Addresses" onClick={() => navigate('/addresses')} />
                        </div>
                    </section>

                    <section>
                        <h3 className="text-xs font-bold text-gray-400 uppercase mb-3 ml-2 tracking-wider">Settings</h3>
                        <div className="bg-white rounded-xl shadow-sm overflow-hidden divide-y divide-gray-100">
                            <MenuItem icon={Bell} iconColor="text-gray-700" bg="bg-gray-100" label="Notifications" onClick={() => { }} />
                            <MenuItem icon={Shield} iconColor="text-gray-700" bg="bg-gray-100" label="Security" onClick={() => { }} />
                            <MenuItem icon={HelpCircle} iconColor="text-gray-700" bg="bg-gray-100" label="Help & Support" onClick={() => { }} />
                        </div>
                    </section>

                    <button
                        onClick={handleSignOut}
                        className="w-full bg-red-50 text-red-600 font-bold py-4 rounded-xl hover:bg-red-100 transition-colors flex items-center justify-center gap-2"
                    >
                        Log Out
                    </button>
                </div>
            </main>
        </div>
    );
};

interface MenuItemProps {
    icon: React.ElementType;
    iconColor: string;
    bg: string;
    label: string;
    onClick: () => void;
}

const MenuItem: React.FC<MenuItemProps> = ({ icon: Icon, iconColor, bg, label, onClick }) => (
    <button
        onClick={onClick}
        className="w-full px-4 py-4 flex items-center justify-between hover:bg-gray-50 transition-colors group"
    >
        <div className="flex items-center gap-4">
            <div className={`p-2 rounded-lg ${bg}`}>
                <Icon size={20} className={iconColor} />
            </div>
            <span className="font-medium text-gray-700 group-hover:text-gray-900">{label}</span>
        </div>
        <ChevronRight size={20} className="text-gray-300 group-hover:text-gray-400" />
    </button>
);

export default ProfilePage;
