import React, { useEffect, useState, useRef } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import Navbar from '../components/Navbar';
import { Product } from '../types/product';
import { Review } from '../types/review';
import { ProductService } from '../api/productService';
import { ReviewService } from '../api/reviewService';
import { WishlistService } from '../api/wishlistService';
import { Share2, Heart, ShoppingCart, ArrowLeft, Star, Camera, X } from 'lucide-react';
import { useCart } from '../context/CartContext';
import { useAuth } from '../context/AuthContext';

const ProductDetailsPage: React.FC = () => {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();
    const { user } = useAuth();
    const [product, setProduct] = useState<Product | null>(null);
    const [relatedProducts, setRelatedProducts] = useState<Product[]>([]);
    const [reviews, setReviews] = useState<Review[]>([]);
    const [loading, setLoading] = useState(true);
    const [loadingReviews, setLoadingReviews] = useState(true);
    const [isWishlisted, setIsWishlisted] = useState(false);
    const [avgRating, setAvgRating] = useState(0);
    const [quantity, setQuantity] = useState(1);
    const [showReviewForm, setShowReviewForm] = useState(false);
    const [userRating, setUserRating] = useState(5);
    const [userComment, setUserComment] = useState('');
    const [selectedFiles, setSelectedFiles] = useState<File[]>([]);
    const [uploading, setUploading] = useState(false);
    const fileInputRef = useRef<HTMLInputElement>(null);
    const { addToCart } = useCart();

    useEffect(() => {
        const fetchProductData = async () => {
            if (!id) return;
            try {
                setLoading(true);
                const data = await ProductService.getProductById(id);
                setProduct(data || null);

                if (data) {
                    const related = await ProductService.getRelatedProducts(data.id);
                    setRelatedProducts(related);

                    const recentlyViewed = JSON.parse(localStorage.getItem('recentlyViewed') || '[]');
                    const updated = [data.id, ...recentlyViewed.filter((rid: string) => rid !== data.id)].slice(0, 5);
                    localStorage.setItem('recentlyViewed', JSON.stringify(updated));
                }

                if (user && data) {
                    const isInWishlist = await WishlistService.isInWishlist(user.id, data.id);
                    setIsWishlisted(isInWishlist);
                }

                const [reviewData, avg] = await Promise.all([
                    ReviewService.getProductReviews(id),
                    ReviewService.getAverageRating(id)
                ]);
                setReviews(reviewData);
                setAvgRating(avg);
            } catch (error) {
                console.error("Failed to fetch data", error);
            } finally {
                setLoading(false);
                setLoadingReviews(false);
            }
        };

        fetchProductData();
        window.scrollTo(0, 0);
    }, [id, user]);

    const handleAddToCart = () => {
        if (product) {
            for (let i = 0; i < quantity; i++) {
                addToCart(product);
            }
            alert("Added to cart");
        }
    };

    const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.files) {
            setSelectedFiles(prev => [...prev, ...Array.from(e.target.files!)]);
        }
    };

    const removeFile = (index: number) => {
        setSelectedFiles(prev => prev.filter((_, i) => i !== index));
    };

    const handleSubmitReview = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!user || !product) return;

        setUploading(true);
        try {
            // 1. Upload images first
            const image_urls: string[] = [];
            for (const file of selectedFiles) {
                const url = await ReviewService.uploadReviewImage(file);
                image_urls.push(url);
            }

            // 2. Submit review
            await ReviewService.submitReview({
                user_id: user.id,
                product_id: product.id,
                rating: userRating,
                comment: userComment,
                image_urls: image_urls
            });

            setShowReviewForm(false);
            setUserComment('');
            setSelectedFiles([]);
            const [newData, newAvg] = await Promise.all([
                ReviewService.getProductReviews(product.id),
                ReviewService.getAverageRating(product.id)
            ]);
            setReviews(newData);
            setAvgRating(newAvg);
        } catch (error) {
            console.error("Review failed", error);
            alert("Already reviewed or error");
        } finally {
            setUploading(false);
        }
    };

    if (loading) {
        return (
            <div className="min-h-screen bg-gray-50 flex items-center justify-center">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-brand-blue"></div>
            </div>
        );
    }

    if (!product) return null;

    const formatCurrency = (amount: number) => {
        return new Intl.NumberFormat('en-NG', { style: 'currency', currency: 'NGN', minimumFractionDigits: 0 }).format(amount);
    };

    return (
        <div className="min-h-screen bg-white font-sans text-brand-grey pb-20">
            <Navbar />
            <main>
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                    <button onClick={() => navigate(-1)} className="flex items-center text-gray-500 hover:text-brand-blue transition-colors">
                        <ArrowLeft size={20} className="mr-2" /> Back
                    </button>
                </div>

                {/* Product Info Section (Same as before but with specs support) */}
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 grid grid-cols-1 md:grid-cols-2 gap-8 lg:gap-12">
                    <div className="bg-gray-50 rounded-2xl p-8 flex items-center justify-center aspect-square md:h-[500px]">
                        <img src={product.image_url} alt={product.title} className="max-h-full max-w-full object-contain mix-blend-multiply" />
                    </div>

                    <div className="flex flex-col">
                        <div className="flex justify-between items-start mb-4">
                            <h1 className="text-2xl sm:text-3xl font-bold text-gray-900 leading-tight">{product.title}</h1>
                            <div className="flex gap-2">
                                <button className={`p-2 rounded-full transition-colors ${isWishlisted ? 'text-red-500 bg-red-50' : 'text-gray-400 hover:text-red-500'}`}>
                                    <Heart size={24} fill={isWishlisted ? "currentColor" : "none"} />
                                </button>
                                <Share2 size={24} className="p-2 cursor-pointer text-gray-400 hover:text-brand-blue" />
                            </div>
                        </div>

                        <div className="flex items-center gap-2 mb-6">
                            <Star size={16} className="text-amber-400" fill="currentColor" />
                            <span className="text-sm text-gray-900 font-bold">{avgRating.toFixed(1)}</span>
                            <span className="text-sm text-gray-500">({reviews.length} reviews)</span>
                        </div>

                        <div className="mb-8">
                            <span className="text-3xl font-extrabold text-brand-blue">{formatCurrency(product.discount_price ?? product.price)}</span>
                        </div>

                        <div className="prose prose-sm text-gray-600 mb-8 border-t border-gray-100 py-6">
                            <h3 className="text-lg font-semibold text-gray-900 mb-2">Description</h3>
                            <p>{product.description || "Premium performance and reliability."}</p>
                        </div>

                        <div className="mt-auto flex gap-4">
                            <button onClick={handleAddToCart} className="flex-1 bg-brand-blue text-white font-bold py-3 rounded-lg flex items-center justify-center gap-2">
                                <ShoppingCart size={20} /> Add to Cart
                            </button>
                        </div>
                    </div>
                </div>

                {/* Related Products */}
                {relatedProducts.length > 0 && (
                    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 border-t border-gray-100 mt-12">
                        <h2 className="text-2xl font-bold text-gray-900 mb-8">Related Products</h2>
                        <div className="grid grid-cols-2 sm:grid-cols-4 gap-6">
                            {relatedProducts.map(p => (
                                <Link to={`/product/${p.id}`} key={p.id} className="group">
                                    <div className="bg-gray-50 rounded-xl p-4 aspect-square mb-3 flex items-center justify-center group-hover:scale-105 transition-transform">
                                        <img src={p.image_url} alt={p.title} className="max-h-full max-w-full object-contain" />
                                    </div>
                                    <h3 className="font-semibold text-sm line-clamp-1">{p.title}</h3>
                                    <p className="text-brand-blue font-bold">{formatCurrency(p.discount_price ?? p.price)}</p>
                                </Link>
                            ))}
                        </div>
                    </div>
                )}

                {/* Reviews */}
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 border-t border-gray-100 mt-12">
                    <div className="flex items-center justify-between mb-8">
                        <h2 className="text-2xl font-bold">Customer Reviews</h2>
                        <button onClick={() => setShowReviewForm(!showReviewForm)} className="border border-gray-300 px-6 py-2 rounded-lg font-semibold hover:bg-gray-50">
                            Write a Review
                        </button>
                    </div>

                    {showReviewForm && (
                        <div className="bg-gray-50 p-6 rounded-xl mb-8">
                            <form onSubmit={handleSubmitReview} className="space-y-4">
                                <div>
                                    <label className="block text-sm font-medium mb-2">Rating</label>
                                    <div className="flex gap-2">
                                        {[1, 2, 3, 4, 5].map(i => (
                                            <Star key={i} size={24} className={i <= userRating ? 'text-amber-400' : 'text-gray-300'} fill={i <= userRating ? "currentColor" : "none"} onClick={() => setUserRating(i)} />
                                        ))}
                                    </div>
                                </div>
                                <textarea
                                    required
                                    value={userComment}
                                    onChange={(e) => setUserComment(e.target.value)}
                                    className="w-full p-3 border border-gray-300 rounded-lg outline-none"
                                    rows={4}
                                    placeholder="Add a comment..."
                                />

                                {/* Image Upload */}
                                <div>
                                    <div className="flex items-center gap-4 mb-4">
                                        <button type="button" onClick={() => fileInputRef.current?.click()} className="flex items-center gap-2 text-brand-blue font-medium bg-blue-50 px-4 py-2 rounded-lg hover:bg-blue-100">
                                            <Camera size={20} /> Add Photos
                                        </button>
                                        <input type="file" ref={fileInputRef} multiple accept="image/*" onChange={handleFileChange} className="hidden" />
                                    </div>
                                    <div className="flex gap-2 flex-wrap">
                                        {selectedFiles.map((f, i) => (
                                            <div key={i} className="relative w-20 h-20 bg-gray-200 rounded-lg overflow-hidden">
                                                <img src={URL.createObjectURL(f)} alt="review" className="w-full h-full object-cover" />
                                                <button type="button" onClick={() => removeFile(i)} className="absolute top-1 right-1 bg-black/50 text-white rounded-full p-1"><X size={12} /></button>
                                            </div>
                                        ))}
                                    </div>
                                </div>

                                <button type="submit" disabled={uploading} className="bg-brand-blue text-white px-8 py-3 rounded-lg font-bold disabled:opacity-50">
                                    {uploading ? 'Uploading...' : 'Post Review'}
                                </button>
                            </form>
                        </div>
                    )}

                    <div className="space-y-8">
                        {reviews.map(r => (
                            <div key={r.id} className="border-b border-gray-100 pb-8">
                                <div className="flex items-center gap-4 mb-3">
                                    <div className="w-10 h-10 bg-brand-blue/10 rounded-full flex items-center justify-center text-brand-blue font-bold">
                                        {r.user_id.substring(0, 1).toUpperCase()}
                                    </div>
                                    <div>
                                        <div className="flex text-amber-400 mb-1">
                                            {[1, 2, 3, 4, 5].map(i => <Star key={i} size={14} fill={i <= r.rating ? "currentColor" : "none"} />)}
                                        </div>
                                        <p className="text-sm text-gray-500">{new Date(r.created_at).toLocaleDateString()}</p>
                                    </div>
                                </div>
                                <p className="text-gray-700">{r.comment}</p>

                                {/* Review Images Gallery */}
                                {r.image_urls && r.image_urls.length > 0 && (
                                    <div className="flex gap-2 mt-4 overflow-x-auto pb-2">
                                        {r.image_urls.map((url, i) => (
                                            <img key={i} src={url} alt={`Review ${i}`} className="w-24 h-24 object-cover rounded-lg cursor-pointer hover:opacity-90" onClick={() => window.open(url, '_blank')} />
                                        ))}
                                    </div>
                                )}
                            </div>
                        ))}
                    </div>
                </div>
            </main>
        </div>
    );
};

export default ProductDetailsPage;
