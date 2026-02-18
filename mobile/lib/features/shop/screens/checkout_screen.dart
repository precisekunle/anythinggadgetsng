import 'package:flutter/material.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/services/payment_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();
  final _paymentService = PaymentService();
  bool _isLoading = false;

  Future<void> _handleCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("Please login to continue");

      final totalAmount = CartService().totalAmount;

      // 1. Process Payment via Paystack
      final paymentSuccess = await _paymentService.initiatePayment(
        amount: totalAmount,
        email: user.email!,
        context: context,
      );

      if (!paymentSuccess) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // 2. Create Order in Supabase
      final orderResponse = await Supabase.instance.client
          .from('orders')
          .insert({
            'user_id': user.id,
            'total_amount': totalAmount,
            'status': 'processing',
            'shipping_address': {
              'address': _addressController.text,
              'city': _cityController.text,
              'zip': _zipController.text,
              'phone': _phoneController.text,
            },
            'payment_status': 'paid',
          })
          .select()
          .single();

      final orderId = orderResponse['id'];

      // 3. Create Order Items
      final cartItems = CartService().items;
      final orderItemsData = cartItems.map((item) => {
        'order_id': orderId,
        'product_id': item.product.id,
        'quantity': item.quantity,
        'price_at_purchase': item.product.discountPrice ?? item.product.price,
      }).toList();

      await Supabase.instance.client
          .from('order_items')
          .insert(orderItemsData);

      // 4. Clear Cart
      CartService().clearCart();

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Order Confirmed!', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: const Text('Your payment was successful and your order is being processed.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainScreen()),
                (route) => false,
              );
            },
            child: const Text('Return Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Checkout', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Shipping Information',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(_addressController, 'Address', Icons.location_on),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_cityController, 'City', Icons.location_city)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(_zipController, 'ZIP Code', Icons.markunread_mailbox, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(_phoneController, 'Phone Number', Icons.phone, isPhone: true),
                  const SizedBox(height: 32),
                  
                  Card(
                    elevation: 0,
                    color: Colors.grey[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Order Summary', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Amount:'),
                              Text(
                                '₦${CartService().totalAmount.toStringAsFixed(0)}',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Pay & Place Order', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : (isPhone ? TextInputType.phone : TextInputType.text),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
    );
  }
}
