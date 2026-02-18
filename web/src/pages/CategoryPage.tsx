import React from 'react';
import Navbar from '../components/Navbar';
import { useNavigate } from 'react-router-dom';
import { Smartphone, Laptop, Headphones, Watch, Camera, Gamepad } from 'lucide-react';

const CategoryPage: React.FC = () => {
    const navigate = useNavigate();

    const categories = [
        { name: 'Phones', icon: Smartphone },
        { name: 'Laptops', icon: Laptop },
        { name: 'Audio', icon: Headphones },
        { name: 'Wearables', icon: Watch },
        { name: 'Cameras', icon: Camera },
        { name: 'Gaming', icon: Gamepad },
    ];

    return (
        <div className="min-h-screen bg-gray-50 text-brand-grey">
            <Navbar />
            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <div className="mb-8">
                    <h1 className="text-2xl sm:text-3xl font-bold text-gray-900">Categories</h1>
                    <p className="text-gray-500 text-sm mt-1">Browse products by category</p>
                </div>
                <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-3 gap-4 sm:gap-6">
                    {categories.map((category) => (
                        <button
                            key={category.name}
                            onClick={() => navigate(`/category/${category.name}`)}
                            className="bg-white p-6 sm:p-8 rounded-2xl border border-gray-100 shadow-sm hover:shadow-md hover:border-brand-blue/30 transition-all cursor-pointer flex flex-col items-center justify-center gap-4 group"
                        >
                            <div className="w-16 h-16 rounded-2xl bg-blue-50 group-hover:bg-brand-blue flex items-center justify-center transition-colors">
                                <category.icon size={28} className="text-brand-blue group-hover:text-white transition-colors" />
                            </div>
                            <h3 className="text-base font-semibold text-gray-900 group-hover:text-brand-blue transition-colors">{category.name}</h3>
                        </button>
                    ))}
                </div>
            </main>
        </div>
    );
};

export default CategoryPage;
