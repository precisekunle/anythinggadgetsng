import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import HomePage from './pages/HomePage';
import ProductDetailsPage from './pages/ProductDetailsPage';
import CartPage from './pages/CartPage';
import ShopPage from './pages/ShopPage';
import CategoryPage from './pages/CategoryPage';
import CategoryProductsPage from './pages/CategoryProductsPage';
import { AuthProvider } from './context/AuthContext';
import { CartProvider } from './context/CartContext';
import LoginPage from './pages/LoginPage';
import SignupPage from './pages/SignupPage';
import CheckoutPage from './pages/CheckoutPage';
import VendorPage from './pages/VendorPage';
import ProfilePage from './pages/ProfilePage';
import SearchResultsPage from './pages/SearchResultsPage';
import WishlistPage from './pages/WishlistPage';
import OrderHistoryPage from './pages/OrderHistoryPage';
import AddressPage from './pages/AddressPage';
import VendorDashboardPage from './pages/VendorDashboardPage';

const App: React.FC = () => {
    return (
        <AuthProvider>
            <CartProvider>
                <Router future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
                    <Routes>
                        <Route path="/" element={<HomePage />} />
                        <Route path="/shop" element={<ShopPage />} />
                        <Route path="/search" element={<SearchResultsPage />} />
                        <Route path="/wishlist" element={<WishlistPage />} />
                        <Route path="/orders" element={<OrderHistoryPage />} />
                        <Route path="/addresses" element={<AddressPage />} />
                        <Route path="/vendor-dashboard" element={<VendorDashboardPage />} />
                        <Route path="/categories" element={<CategoryPage />} />
                        <Route path="/category/:categoryName" element={<CategoryProductsPage />} />
                        <Route path="/product/:id" element={<ProductDetailsPage />} />
                        <Route path="/cart" element={<CartPage />} />
                        <Route path="/login" element={<LoginPage />} />
                        <Route path="/signup" element={<SignupPage />} />
                        <Route path="/checkout" element={<CheckoutPage />} />
                        <Route path="/vendor/:id" element={<VendorPage />} />
                        <Route path="/profile" element={<ProfilePage />} />
                    </Routes>
                </Router>
            </CartProvider>
        </AuthProvider>
    );
};

export default App;
