import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/cart_item.dart';
import '../../shop/screens/checkout_screen.dart'; // Import CheckoutScreen

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Shopping Cart",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
               CartService().clearCart();
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: CartService().cartItemsNotifier,
        builder: (context, cartItems, child) {
          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                   const SizedBox(height: 16),
                   Text(
                     "Your cart is empty",
                     style: GoogleFonts.inter(fontSize: 18, color: Colors.grey),
                   ),
                   const SizedBox(height: 24),
                   ElevatedButton(
                     onPressed: () => Navigator.pop(context),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: AppTheme.primaryColor,
                       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                     ),
                     child: const Text("Start Shopping"),
                   ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Image.network(
                            item.product.imageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.product.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                currencyFormat.format(item.product.discountPrice ?? item.product.price),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                              ),
                            ],
                          ),
                        ),
                        // Quantity Controls
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (item.quantity > 1) {
                                         CartService().updateQuantity(item.product.id, item.quantity - 1);
                                      } else {
                                         CartService().removeFromCart(item.product.id);
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Icon(Icons.remove, size: 16),
                                    ),
                                  ),
                                  Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  InkWell(
                                    onTap: () {
                                       CartService().updateQuantity(item.product.id, item.quantity + 1);
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Icon(Icons.add, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Total Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            currencyFormat.format(CartService().totalAmount),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CheckoutScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Proceed to Checkout", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
