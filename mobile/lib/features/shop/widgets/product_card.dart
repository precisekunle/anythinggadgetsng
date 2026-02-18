import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/product.dart';
import '../../core/theme/app_theme.dart';
import '../screens/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onAddToCart;
  final VoidCallback? onTap;

  const ProductCard({
    Key? key,
    required this.product,
    this.onAddToCart,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0);

    // Calculate discount percentage if applicable
    int? discountPercent;
    if (product.discountPrice != null && product.price > 0) {
      discountPercent = ((product.price - product.discountPrice!) / product.price * 100).round();
    }

    return GestureDetector(
      onTap: onTap ?? () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundColor,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Stack for Badge
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0), // Padding inside card for image breathing room
                      child: Image.network(
                        product.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.contain, // Contain to show full product like in design
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[100],
                          child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                  if (discountPercent != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-$discountPercent%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Details Section
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.secondaryColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Mock Rating Row
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "4.8 (120)",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      // Price
                      Text(
                        currencyFormat.format(product.discountPrice ?? product.price),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Add to Cart Button (Full width style light grey)
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: onAddToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F5F5), // Light grey bg
                        foregroundColor: AppTheme.secondaryColor, // Dark text
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        "Add to Cart",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
