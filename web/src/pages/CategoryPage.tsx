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
        <div className="min-h-screen bg-gray-50 font-sans text-brand-grey">
            <Navbar />
            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <h1 className="text-3xl font-bold mb-8">Categories</h1>
                <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
                    {categories.map((category) => (
                        <div
                            key={category.name}
                            onClick={() => navigate(`/category/${category.name}`)}
                            className="bg-white p-6 rounded-xl shadow-sm hover:shadow-md transition-shadow cursor-pointer flex flex-col items-center justify-center h-48 border border-gray-100"
                        >
                            <category.icon size={48} className="text-brand-blue mb-4" />
                            <h3 className="text-lg font-semibold text-gray-900">{category.name}</h3>
                        </div>
                    ))}
                </div>
            </main>
        </div>
    );
};

export default CategoryPage;
