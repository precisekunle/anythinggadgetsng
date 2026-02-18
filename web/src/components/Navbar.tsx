import React from 'react';
import { ShoppingCart, User, Search, Bell, Menu } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { useCart } from '../context/CartContext';
import { useNavigate, Link } from 'react-router-dom';

const Navbar: React.FC = () => {
    const { itemCount } = useCart();
    const { user, signOut } = useAuth();
    const navigate = useNavigate();
    const [searchQuery, setSearchQuery] = React.useState('');

    const handleSearch = (e: React.FormEvent) => {
        e.preventDefault();
        if (searchQuery.trim()) {
            navigate(`/search?q=${encodeURIComponent(searchQuery.trim())}`);
        }
    };

    return (
        <nav className="sticky top-0 z-50 bg-white border-b border-gray-100">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div className="flex justify-between items-center h-16 gap-4">

                    {/* Logo & Menu Toggle */}
                    <div className="flex items-center gap-2 lg:gap-8">
                        <button className="lg:hidden p-2 -ml-2 text-gray-500">
                            <Menu size={24} />
                        </button>
                        <div
                            className="flex items-center gap-2 text-brand-blue font-bold text-xl cursor-pointer"
                            onClick={() => navigate('/')}
                        >
                            <svg className="w-6 h-6 fill-current" viewBox="0 0 24 24">
                                <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z" />
                            </svg>
                            <span className="hidden sm:inline">AnythingGadgets</span>
                            <span className="sm:hidden">AG</span>
                        </div>

                        {/* Desktop Links */}
                        <div className="hidden lg:flex items-center gap-6 text-sm font-medium text-gray-600">
                            <button onClick={() => navigate('/')} className="text-brand-blue">Home</button>
                            <Link to="/shop" className="text-gray-700 hover:text-brand-blue font-medium transition-colors">Shop</Link>
                            <Link to="/categories" className="text-gray-700 hover:text-brand-blue font-medium transition-colors">Categories</Link>
                            <a href="#" className="hover:text-brand-blue transition-colors">Deals</a>
                        </div>
                    </div>

                    {/* Search Bar - Desktop */}
                    <form onSubmit={handleSearch} className="flex-1 max-w-2xl hidden md:block">
                        <div className="relative group">
                            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <Search size={18} className="text-gray-400 group-focus-within:text-brand-blue transition-colors" />
                            </div>
                            <input
                                type="text"
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                placeholder="Search for laptops, phones..."
                                className="block w-full pl-10 pr-3 py-2 bg-gray-50 border-none rounded-lg text-sm focus:ring-2 focus:ring-brand-blue/10 focus:bg-white transition-all text-gray-900 placeholder-gray-500"
                            />
                        </div>
                    </form>

                    {/* Icons */}
                    <div className="flex items-center gap-2 sm:gap-4">
                        <button className="p-2 text-gray-500 hover:bg-gray-50 rounded-full transition-colors relative">
                            <Bell size={20} />
                            <span className="absolute top-2 right-2 w-2 h-2 bg-red-500 rounded-full border border-white"></span>
                        </button>
                        <button
                            onClick={() => navigate('/cart')}
                            className="p-2 text-gray-500 hover:bg-gray-50 rounded-full transition-colors relative"
                        >
                            <ShoppingCart size={20} />
                            {itemCount > 0 && (
                                <span className="absolute top-0 right-0 w-4 h-4 bg-red-500 text-white text-[10px] font-bold flex items-center justify-center rounded-full border-2 border-white">
                                    {itemCount}
                                </span>
                            )}
                        </button>
                        <div className="hidden sm:flex items-center gap-3 pl-2 border-l border-gray-200">
                            {user ? (
                                <div className="flex items-center gap-3">
                                    <div className="text-right hidden xl:block">
                                        <div
                                            className="text-xs font-medium text-gray-900 cursor-pointer hover:text-brand-blue"
                                            onClick={() => navigate('/profile')}
                                        >
                                            {user.user_metadata.full_name || 'User'}
                                        </div>
                                        <button onClick={() => signOut()} className="text-xs text-red-500 hover:underline">Sign Out</button>
                                    </div>
                                    <div
                                        className="p-1 bg-brand-blue/10 rounded-full cursor-pointer hover:bg-brand-blue/20"
                                        onClick={() => navigate('/profile')}
                                    >
                                        <User size={20} className="text-brand-blue m-1" />
                                    </div>
                                </div>
                            ) : (
                                <Link to="/login" className="flex items-center gap-2 group">
                                    <div className="text-right hidden xl:block">
                                        <div className="text-xs font-medium text-gray-900 group-hover:text-brand-blue">Hello, Sign In</div>
                                        <div className="text-xs text-gray-500">My Account</div>
                                    </div>
                                    <div className="p-1 bg-gray-100 group-hover:bg-brand-blue/10 rounded-full transition-colors">
                                        <User size={20} className="text-gray-600 group-hover:text-brand-blue m-1" />
                                    </div>
                                </Link>
                            )}
                        </div>
                    </div>

                </div>

                {/* Mobile Search Bar (Below Header) */}
                <form onSubmit={handleSearch} className="md:hidden pb-3">
                    <div className="relative">
                        <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <Search size={16} className="text-gray-400" />
                        </div>
                        <input
                            type="text"
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                            placeholder="Search products..."
                            className="block w-full pl-9 pr-3 py-2 bg-gray-50 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-brand-blue"
                        />
                    </div>
                </form>
            </div>
        </nav>
    );
};

export default Navbar;
