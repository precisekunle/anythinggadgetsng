import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../data/models/order.dart';
import '../../../data/repositories/supabase_order_repository.dart';
import '../../../core/theme/app_theme.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final _orderRepository = SupabaseOrderRepository();
  final _client = Supabase.instance.client;
  List<Order> _orders = [];
  bool _isLoading = true;
  RealtimeChannel? _orderChannel;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _subscribeToOrderUpdates();
  }

  @override
  void dispose() {
    _orderChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final orders = await _orderRepository.getOrders(userId);
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _subscribeToOrderUpdates() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    _orderChannel = _client.channel('order_updates')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'orders',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: userId,
        ),
        callback: (payload) {
          _fetchOrders();
          if (payload.newRecord != null) {
             final status = payload.newRecord!['status'];
             final orderId = payload.newRecord!['id'];
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text("Order #${orderId.toString().substring(0,8)} is now $status"))
             );
          }
        },
      )
      .subscribe();
  }

  String _getDeliveryEstimate(DateTime createdAt) {
    final start = createdAt.add(const Duration(days: 3));
    final end = createdAt.add(const Duration(days: 5));
    return "Estimated: ${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d').format(end)}";
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("My Orders", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[200]),
                      const SizedBox(height: 16),
                      Text("No orders placed yet", style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 16)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                        child: const Text("Go Shopping", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[100]!),
                        boxShadow: [
                           BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: ExpansionTile(
                        shape: const RoundedRectangleBorder(side: BorderSide.none),
                        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                        title: Text("Order #${order.id.substring(0, 8).toUpperCase()}", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat.yMMMd().format(order.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                            const SizedBox(height: 2),
                            Text(_getDeliveryEstimate(order.createdAt), style: const TextStyle(fontSize: 11, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            order.status.toUpperCase(),
                            style: TextStyle(color: _getStatusColor(order.status), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                          ),
                        ),
                        children: [
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: _buildTimeline(order.status),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Align(alignment: Alignment.centerLeft, child: Text("ORDER ITEMS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1))),
                          ),
                          const SizedBox(height: 8),
                          ...order.items.map((item) => ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.all(4),
                              child: item.productImage != null 
                                ? Image.network(item.productImage!, fit: BoxFit.contain)
                                : const Icon(Icons.gadget_setup, size: 20),
                            ),
                            title: Text(item.productTitle ?? "Product", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            subtitle: Text("Qty: ${item.quantity}", style: const TextStyle(fontSize: 11)),
                            trailing: Text(currencyFormat.format(item.priceAtPurchase), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          )),
                          const Divider(indent: 20, endIndent: 20),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("TOTAL PAID", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                                    const SizedBox(height: 2),
                                    Text(currencyFormat.format(order.totalAmount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryColor)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text("STATUS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                                    const SizedBox(height: 2),
                                    Text(order.status.toUpperCase(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _getStatusColor(order.status))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildTimeline(String currentStatus) {
    final stages = ['pending', 'processing', 'shipped', 'delivered'];
    final labels = ['Ordered', 'Processing', 'Shipped', 'Delivered'];
    final icons = [Icons.credit_card, Icons.inventory_2_outlined, Icons.local_shipping_outlined, Icons.home_outlined];
    
    int currentIndex = stages.indexOf(currentStatus.toLowerCase());
    if (currentIndex == -1 && currentStatus.toLowerCase() == 'completed') currentIndex = 3;

    return Row(
      children: List.generate(stages.length, (index) {
        bool isCompleted = index <= currentIndex;
        bool isLast = index == stages.length - 1;
        
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  // Line before
                  Expanded(child: Container(height: 2, color: index == 0 ? Colors.transparent : (isCompleted ? AppTheme.primaryColor : Colors.grey[200]))),
                  // Icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppTheme.primaryColor : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: isCompleted ? AppTheme.primaryColor : Colors.grey[200]!, width: 2),
                    ),
                    child: Icon(icons[index], size: 16, color: isCompleted ? Colors.white : Colors.grey[300]),
                  ),
                  // Line after
                  Expanded(child: Container(height: 2, color: isLast ? Colors.transparent : (index < currentIndex ? AppTheme.primaryColor : Colors.grey[200]))),
                ],
              ),
              const SizedBox(height: 8),
              Text(labels[index], textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isCompleted ? AppTheme.primaryColor : Colors.grey[400])),
            ],
          ),
        );
      }),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered': return Colors.green;
      case 'pending': return Colors.orange;
      case 'shipped': return Colors.blue;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}
