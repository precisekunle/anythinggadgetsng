class Product {
  final String id;
  final String title;
  final double price;
  final double? discountPrice;
  final String imageUrl;
  final String category;
  final bool stockStatus;
  final int stockQuantity;
  final String? shopId;
  final String? dealId;

  Product({
    required this.id,
    required this.title,
    required this.price,
    this.discountPrice,
    required this.imageUrl,
    required this.category,
    required this.stockStatus,
    required this.stockQuantity,
    this.shopId,
    this.dealId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discount_price'] != null
          ? (json['discount_price'] as num).toDouble()
          : null,
      imageUrl: json['image_url'] as String,
      category: json['category'] as String,
      stockStatus: json['stock_status'] as bool,
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      shopId: json['shop_id'] as String?,
      dealId: json['deal_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'discount_price': discountPrice,
      'image_url': imageUrl,
      'category': category,
      'stock_status': stockStatus,
      'stock_quantity': stockQuantity,
      'shop_id': shopId,
      'deal_id': dealId,
    };
  }
}
