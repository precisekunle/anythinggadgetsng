import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order.dart';

class SupabaseOrderRepository implements OrderRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<Order>> getOrders(String userId) async {
    final response = await _client
        .from('orders')
        .select('*, order_items(*, products(*))')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    final data = response as List<dynamic>;
    return data.map((json) => Order.fromJson(json)).toList();
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    try {
      final response = await _client
          .from('orders')
          .select('*, order_items(*, products(*))')
          .eq('id', orderId)
          .single();
      
      return Order.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createOrder(Order order, List<OrderItem> items) async {
    // Note: Ideally use a single call or RPC for transaction
    final orderJson = order.toJson();
    final orderResponse = await _client.from('orders').insert(orderJson).select().single();
    
    final String newOrderId = orderResponse['id'];
    
    final itemsJson = items.map((item) => {
      'order_id': newOrderId,
      'product_id': item.productId,
      'quantity': item.quantity,
      'price_at_purchase': item.priceAtPurchase,
    }).toList();
    
    await _client.from('order_items').insert(itemsJson);
  }

  Future<List<Order>> getVendorOrders() async {
    final response = await _client
        .rpc('get_vendor_orders')
        .select('*, order_items(*, products(*))');
    
    final data = response as List<dynamic>;
    return data.map((json) => Order.fromJson(json)).toList();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _client
        .from('orders')
        .update({'status': status})
        .eq('id', orderId);
  }

  Future<Map<String, dynamic>> getVendorStats() async {
    final response = await _client.rpc('get_vendor_stats');
    return response as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getDailySales() async {
    final response = await _client.rpc('get_vendor_daily_sales');
    return (response as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
  }
}
