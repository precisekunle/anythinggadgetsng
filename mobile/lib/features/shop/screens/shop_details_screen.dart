import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/shop.dart';
import '../../../../data/models/product.dart';
import '../../../../data/repositories/shop_repository.dart';
import '../widgets/product_card.dart';

class ShopScreen extends StatefulWidget {
  final String shopId;

  const ShopScreen({super.key, required this.shopId});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ShopRepository _shopRepository = ShopRepository();
  Shop? _shop;
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShopData();
  }

  Future<void> _loadShopData() async {
    try {
      final shop = await _shopRepository.getShopById(widget.shopId);
      final products = await _shopRepository.getShopProducts(widget.shopId);
      if (mounted) {
        setState(() {
          _shop = shop;
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load shop: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_shop == null) {
      return const Scaffold(
        body: Center(child: Text('Shop not found')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_shop!.name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner & Logo Area
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                   // Banner
                   Container(
                     height: 150,
                     width: double.infinity,
                     decoration: BoxDecoration(
                       color: Colors.grey.shade200,
                       image: _shop!.bannerUrl != null
                           ? DecorationImage(
                               image: NetworkImage(_shop!.bannerUrl!),
                               fit: BoxFit.cover,
                             )
                           : null,
                     ),
                   ),
                   // Logo
                   Positioned(
                     bottom: 0,
                     left: 16,
                     child: Container(
                       width: 80,
                       height: 80,
                       decoration: BoxDecoration(
                         color: Colors.white,
                         shape: BoxShape.circle,
                         border: Border.all(color: Colors.white, width: 4),
                         image: _shop!.logoUrl != null
                             ? DecorationImage(
                                 image: NetworkImage(_shop!.logoUrl!),
                                 fit: BoxFit.cover,
                               )
                             : null,
                         boxShadow: [
                           BoxShadow(
                             color: Colors.black.withOpacity(0.1),
                             blurRadius: 8,
                           )
                         ],
                       ),
                     ),
                   ),
                ],
              ),
            ),
            
            // Shop Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _shop!.name,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              _shop!.rating.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_shop!.address != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _shop!.address!,
                          style: GoogleFonts.inter(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                  if (_shop!.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _shop!.description!,
                      style: GoogleFonts.inter(color: Colors.green),
                    ),
                  ],
                  const SizedBox(height: 16),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone),
                          label: const Text("Contact"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.near_me),
                          label: const Text("Directions"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search within ${_shop!.name}...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            // Categories Filter (Placeholder)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip("All Items", true),
                  _buildFilterChip("Phones", false),
                  _buildFilterChip("Laptops", false),
                  _buildFilterChip("Accessories", false),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // Products Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: _products[index]);
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        backgroundColor: isSelected ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isSelected ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
