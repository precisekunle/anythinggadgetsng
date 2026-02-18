class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double priceAtPurchase;
  final String? productTitle; // Optional helper
  final String? productImage; // Optional helper

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.priceAtPurchase,
    this.productTitle,
    this.productImage,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      priceAtPurchase: (json['price_at_purchase'] as num).toDouble(),
      productTitle: json['products']?['title'],
      productImage: json['products']?['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price_at_purchase': priceAtPurchase,
    };
  }
}

class Order {
  final String id;
  final DateTime createdAt;
  final String userId;
  final double totalAmount;
  final String status;
  final Map<String, dynamic> shippingAddress;
  final String paymentStatus;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.paymentStatus,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'],
      shippingAddress: json['shipping_address'] as Map<String, dynamic>,
      paymentStatus: json['payment_status'] ?? 'pending',
      items: (json['order_items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'total_amount': totalAmount,
      'status': status,
      'shipping_address': shippingAddress,
      'payment_status': paymentStatus,
    };
  }
}
