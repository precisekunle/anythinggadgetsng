import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product.dart';
import '../../../data/models/review.dart';
import '../../../core/services/cart_service.dart';
import '../../../data/repositories/supabase_review_repository.dart';
import '../../../data/repositories/supabase_wishlist_repository.dart';
import '../../../data/repositories/supabase_product_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final _reviewRepository = SupabaseReviewRepository();
  final _wishlistRepository = SupabaseWishlistRepository();
  final _productRepository = SupabaseProductRepository();
  final _client = Supabase.instance.client;
  final _picker = ImagePicker();
  
  List<Review> _reviews = [];
  List<Product> _relatedProducts = [];
  bool _isLoadingReviews = true;
  bool _isLoadingRelated = true;
  bool _isInWishlist = false;
  double _avgRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _trackRecentlyViewed();
  }

  Future<void> _trackRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recentlyViewed = prefs.getStringList('recently_viewed') ?? [];
    
    // Remove if already exists and add to front
    recentlyViewed.remove(widget.product.id);
    recentlyViewed.insert(0, widget.product.id);
    
    // Keep only last 10
    if (recentlyViewed.length > 10) recentlyViewed.removeLast();
    
    await prefs.setStringList('recently_viewed', recentlyViewed);
  }

  Future<void> _loadData() async {
    final userId = _client.auth.currentUser?.id;
    if (userId != null) {
      final isFav = await _wishlistRepository.isInWishlist(userId, widget.product.id);
      if (mounted) setState(() => _isInWishlist = isFav);
    }

    final reviews = await _reviewRepository.getProductReviews(widget.product.id);
    final avg = await _reviewRepository.getAverageRating(widget.product.id);
    final related = await _productRepository.getRelatedProducts(widget.product.id);
    
    if (mounted) {
      setState(() {
        _reviews = reviews;
        _avgRating = avg;
        _relatedProducts = related;
        _isLoadingReviews = false;
        _isLoadingRelated = false;
      });
    }
  }

  Future<void> _toggleWishlist() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to use wishlist")),
      );
      return;
    }

    try {
      if (_isInWishlist) {
        await _wishlistRepository.removeFromWishlist(userId, widget.product.id);
      } else {
        await _wishlistRepository.addToWishlist(userId, widget.product.id);
      }
      setState(() => _isInWishlist = !_isInWishlist);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _showAddReviewDialog() {
    int innerRating = 5;
    final commentController = TextEditingController();
    List<XFile> selectedImages = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text("Rate ${widget.product.title}", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < innerRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () => setStateDialog(() => innerRating = index + 1),
                    );
                  }),
                ),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: "Write your experience...",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () async {
                      final images = await _picker.pickMultiImage();
                      if (images.isNotEmpty) {
                        setStateDialog(() => selectedImages.addAll(images));
                      }
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Add Photos"),
                  ),
                ),
                if (selectedImages.isNotEmpty)
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedImages.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(File(selectedImages[index].path), width: 80, height: 80, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => setStateDialog(() => selectedImages.removeAt(index)),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final userId = _client.auth.currentUser?.id;
                if (userId == null) return;

                // 1. Upload images
                List<String> imageUrls = [];
                for (var image in selectedImages) {
                  final url = await _reviewRepository.uploadReviewImage(image.path);
                  imageUrls.add(url);
                }

                // 2. Submit review
                final review = Review(
                  id: '', 
                  createdAt: DateTime.now(),
                  userId: userId,
                  productId: widget.product.id,
                  rating: innerRating,
                  comment: commentController.text,
                  imageUrls: imageUrls,
                );

                await _reviewRepository.submitReview(review);
                if (context.mounted) Navigator.pop(context);
                _loadData();
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Details",
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              _isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: _isInWishlist ? Colors.red : Colors.black,
            ),
            onPressed: _toggleWishlist,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  Container(
                    height: 300,
                    width: double.infinity,
                    color: const Color(0xFFF9FAFB),
                    child: Center(
                      child: Image.network(
                        widget.product.imageUrl,
                        fit: BoxFit.contain,
                        height: 250,
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.title,
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  _avgRating.toStringAsFixed(1),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(" (${_reviews.length})", style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              currencyFormat.format(widget.product.discountPrice ?? widget.product.price),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            if (widget.product.discountPrice != null) ...[
                               const SizedBox(width: 8),
                               Text(
                                currencyFormat.format(widget.product.price),
                                style: const TextStyle(
                                  fontSize: 16,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Description
                        const Text(
                          "Description",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.description ?? "Experience specific details about ${widget.product.title}.",
                          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Related Products
                        if (!_isLoadingRelated && _relatedProducts.isNotEmpty) ...[
                          const Text(
                            "You may also like",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _relatedProducts.length,
                              itemBuilder: (context, index) {
                                final p = _relatedProducts[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p)),
                                    );
                                  },
                                  child: Container(
                                    width: 130,
                                    margin: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 100,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Image.network(p.imageUrl, fit: BoxFit.contain),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                        Text(currencyFormat.format(p.discountPrice ?? p.price),
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Reviews Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Customer Reviews", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            TextButton(onPressed: _showAddReviewDialog, child: const Text("Write Review")),
                          ],
                        ),
                        if (_isLoadingReviews)
                          const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                        else if (_reviews.isEmpty)
                          const Text("No reviews yet. Be the first to rate!")
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _reviews.length,
                            itemBuilder: (context, index) {
                              final r = _reviews[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: List.generate(5, (i) => Icon(
                                        i < r.rating ? Icons.star : Icons.star_border,
                                        size: 14,
                                        color: Colors.amber,
                                      )),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(r.comment ?? "", style: const TextStyle(fontSize: 13)),
                                    if (r.imageUrls.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 60,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: r.imageUrls.length,
                                          itemBuilder: (context, i) => Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(r.imageUrls[i], width: 60, height: 60, fit: BoxFit.cover),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat.yMMMd().format(r.createdAt),
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                    const Divider(),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        CartService().addToCart(widget.product);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${widget.product.title} added to cart")));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Add to Cart", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
