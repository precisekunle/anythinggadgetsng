import '../models/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders(String userId);
  Future<Order?> getOrderById(String orderId);
  Future<void> createOrder(Order order, List<OrderItem> items);
}
