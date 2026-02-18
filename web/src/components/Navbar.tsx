import React from 'react';
import { ShoppingCart, User, Search, Bell, Menu, X, Home, ShoppingBag, Tag, Heart, Package, LayoutDashboard } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { useCart } from '../context/CartContext';
import { useNavigate, Link, useLocation } from 'react-router-dom';

const Navbar: React.FC = () => {
    const { itemCount } = useCart();
    const { user, signOut } = useAuth();
    const navigate = useNavigate();
    const location = useLocation();
    const [searchQuery, setSearchQuery] = React.useState('');
    const [mobileMenuOpen, setMobileMenuOpen] = React.useState(false);

    const handleSearch = (e: React.FormEvent) => {
        e.preventDefault();
        if (searchQuery.trim()) {
            navigate(`/search?q=${encodeURIComponent(searchQuery.trim())}`);
            setMobileMenuOpen(false);
        }
    };

    const isActive = (path: string) => location.pathname === path;

    const navLinks = [
        { path: '/', label: 'Home', icon: Home },
        { path: '/shop', label: 'Shop', icon: ShoppingBag },
        { path: '/categories', label: 'Categories', icon: Tag },
    ];

    return (
        <>
            <nav className="sticky top-0 z-50 bg-white border-b border-gray-100 shadow-sm">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex justify-between items-center h-16 gap-4">

                        <div className="flex items-center gap-2 lg:gap-8">
                            <button
                                className="lg:hidden p-2 -ml-2 text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-lg transition-colors"
                                onClick={() => setMobileMenuOpen(o => !o)}
                                aria-label="Toggle menu"
                            >
                                {mobileMenuOpen ? <X size={22} /> : <Menu size={22} />}
                            </button>
                            <div
                                className="flex items-center gap-2 text-brand-blue font-bold text-xl cursor-pointer flex-shrink-0"
                                onClick={() => navigate('/')}
                            >
                                <svg className="w-6 h-6 fill-current" viewBox="0 0 24 24">
                                    <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z" />
                                </svg>
                                <span className="hidden sm:inline tracking-tight">AnythingGadgets</span>
                                <span className="sm:hidden font-extrabold">AG</span>
                            </div>

                            <div className="hidden lg:flex items-center gap-1 text-sm font-medium">
                                {navLinks.map(link => (
                                    <Link
                                        key={link.path}
                                        to={link.path}
                                        className={`px-3 py-2 rounded-lg transition-colors ${
                                            isActive(link.path)
                                                ? 'text-brand-blue bg-blue-50 font-semibold'
                                                : 'text-gray-600 hover:text-gray-900 hover:bg-gray-50'
                                        }`}
                                    >
                                        {link.label}
                                    </Link>
                                ))}
                            </div>
                        </div>

                        <form onSubmit={handleSearch} className="flex-1 max-w-xl hidden md:block">
                            <div className="relative group">
                                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                    <Search size={16} className="text-gray-400 group-focus-within:text-brand-blue transition-colors" />
                                </div>
                                <input
                                    type="text"
                                    value={searchQuery}
                                    onChange={(e) => setSearchQuery(e.target.value)}
                                    placeholder="Search for laptops, phones..."
                                    className="block w-full pl-9 pr-3 py-2.5 bg-gray-100 border border-transparent rounded-xl text-sm focus:ring-2 focus:ring-brand-blue/20 focus:border-brand-blue focus:bg-white transition-all text-gray-900 placeholder-gray-500 outline-none"
                                />
                            </div>
                        </form>

                        <div className="flex items-center gap-1">
                            <button className="p-2 text-gray-500 hover:bg-gray-100 rounded-xl transition-colors relative">
                                <Bell size={20} />
                                <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-red-500 rounded-full border-2 border-white"></span>
                            </button>
                            <button
                                onClick={() => navigate('/cart')}
                                className="p-2 text-gray-500 hover:bg-gray-100 rounded-xl transition-colors relative"
                            >
                                <ShoppingCart size={20} />
                                {itemCount > 0 && (
                                    <span className="absolute -top-0.5 -right-0.5 w-5 h-5 bg-brand-blue text-white text-[10px] font-bold flex items-center justify-center rounded-full border-2 border-white">
                                        {itemCount > 9 ? '9+' : itemCount}
                                    </span>
                                )}
                            </button>
                            <div className="hidden sm:flex items-center gap-3 pl-2 ml-1 border-l border-gray-200">
                                {user ? (
                                    <div className="flex items-center gap-2">
                                        <div className="hidden xl:block text-right">
                                            <div
                                                className="text-xs font-semibold text-gray-900 cursor-pointer hover:text-brand-blue transition-colors"
                                                onClick={() => navigate('/profile')}
                                            >
                                                {user.user_metadata.full_name || 'User'}
                                            </div>
                                            <button onClick={() => signOut()} className="text-xs text-gray-400 hover:text-red-500 transition-colors">Sign Out</button>
                                        </div>
                                        <button
                                            onClick={() => navigate('/profile')}
                                            className="w-9 h-9 bg-brand-blue/10 rounded-xl flex items-center justify-center hover:bg-brand-blue/20 transition-colors"
                                        >
                                            <User size={18} className="text-brand-blue" />
                                        </button>
                                    </div>
                                ) : (
                                    <Link to="/login" className="flex items-center gap-2 group">
                                        <div className="hidden xl:block text-right">
                                            <div className="text-xs font-semibold text-gray-900 group-hover:text-brand-blue transition-colors">Sign In</div>
                                            <div className="text-xs text-gray-400">My Account</div>
                                        </div>
                                        <div className="w-9 h-9 bg-gray-100 rounded-xl flex items-center justify-center group-hover:bg-brand-blue/10 transition-colors">
                                            <User size={18} className="text-gray-500 group-hover:text-brand-blue transition-colors" />
                                        </div>
                                    </Link>
                                )}
                            </div>
                        </div>
                    </div>

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
                                className="block w-full pl-9 pr-3 py-2.5 bg-gray-100 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-brand-blue/20 border border-transparent focus:bg-white transition-all"
                            />
                        </div>
                    </form>
                </div>
            </nav>

            {mobileMenuOpen && (
                <div className="lg:hidden fixed inset-0 z-40 bg-black/40" onClick={() => setMobileMenuOpen(false)}>
                    <div
                        className="absolute top-0 left-0 w-72 h-full bg-white shadow-2xl flex flex-col"
                        onClick={e => e.stopPropagation()}
                    >
                        <div className="flex items-center gap-2 px-5 py-5 border-b border-gray-100">
                            <svg className="w-6 h-6 fill-current text-brand-blue" viewBox="0 0 24 24">
                                <path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z" />
                            </svg>
                            <span className="text-brand-blue font-bold text-lg tracking-tight">AnythingGadgets</span>
                        </div>

                        <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
                            {navLinks.map(link => {
                                const Icon = link.icon;
                                return (
                                    <Link
                                        key={link.path}
                                        to={link.path}
                                        onClick={() => setMobileMenuOpen(false)}
                                        className={`flex items-center gap-3 px-4 py-3 rounded-xl transition-colors font-medium ${
                                            isActive(link.path)
                                                ? 'bg-brand-blue text-white'
                                                : 'text-gray-700 hover:bg-gray-100'
                                        }`}
                                    >
                                        <Icon size={20} />
                                        {link.label}
                                    </Link>
                                );
                            })}
                            <Link
                                to="/wishlist"
                                onClick={() => setMobileMenuOpen(false)}
                                className="flex items-center gap-3 px-4 py-3 rounded-xl text-gray-700 hover:bg-gray-100 transition-colors font-medium"
                            >
                                <Heart size={20} />
                                Wishlist
                            </Link>
                            <Link
                                to="/orders"
                                onClick={() => setMobileMenuOpen(false)}
                                className="flex items-center gap-3 px-4 py-3 rounded-xl text-gray-700 hover:bg-gray-100 transition-colors font-medium"
                            >
                                <Package size={20} />
                                My Orders
                            </Link>
                            {user && (
                                <Link
                                    to="/vendor-dashboard"
                                    onClick={() => setMobileMenuOpen(false)}
                                    className="flex items-center gap-3 px-4 py-3 rounded-xl text-gray-700 hover:bg-gray-100 transition-colors font-medium"
                                >
                                    <LayoutDashboard size={20} />
                                    Vendor Dashboard
                                </Link>
                            )}
                        </nav>

                        <div className="px-4 py-5 border-t border-gray-100">
                            {user ? (
                                <div className="space-y-3">
                                    <div className="flex items-center gap-3 px-1">
                                        <div className="w-10 h-10 bg-brand-blue/10 rounded-xl flex items-center justify-center">
                                            <User size={20} className="text-brand-blue" />
                                        </div>
                                        <div>
                                            <p className="text-sm font-semibold text-gray-900">{user.user_metadata.full_name || 'User'}</p>
                                            <p className="text-xs text-gray-500 truncate max-w-[160px]">{user.email}</p>
                                        </div>
                                    </div>
                                    <button
                                        onClick={() => { signOut(); setMobileMenuOpen(false); }}
                                        className="w-full text-sm font-semibold text-red-500 hover:bg-red-50 py-2.5 rounded-xl transition-colors"
                                    >
                                        Sign Out
                                    </button>
                                </div>
                            ) : (
                                <Link
                                    to="/login"
                                    onClick={() => setMobileMenuOpen(false)}
                                    className="block w-full text-center bg-brand-blue text-white font-semibold py-3 rounded-xl hover:bg-blue-600 transition-colors"
                                >
                                    Sign In
                                </Link>
                            )}
                        </div>
                    </div>
                </div>
            )}
        </>
    );
};

export default Navbar;
