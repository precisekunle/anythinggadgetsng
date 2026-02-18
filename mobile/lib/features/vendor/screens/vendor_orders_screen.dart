import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../data/models/order.dart';
import '../../../data/repositories/supabase_order_repository.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> {
  final _orderRepository = SupabaseOrderRepository();
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVendorOrders();
  }

  Future<void> _fetchVendorOrders() async {
    try {
      final orders = await _orderRepository.getVendorOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    try {
      await _orderRepository.updateOrderStatus(orderId, newStatus);
      _fetchVendorOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Order status updated to $newStatus")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update status")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Fulfillment", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text("No orders found for your products"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Order #${order.id.substring(0, 8)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                DropdownButton<String>(
                                  value: order.status,
                                  items: ['pending', 'processing', 'shipped', 'delivered', 'cancelled']
                                      .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) _updateStatus(order.id, val);
                                  },
                                ),
                              ],
                            ),
                            const Divider(),
                            ...order.items.map((item) => ListTile(
                              dense: true,
                              title: Text(item.productTitle ?? "Product"),
                              subtitle: Text("Qty: ${item.quantity}"),
                            )),
                            const Divider(),
                            Text("Customer: ${order.userId.substring(0, 8)}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
