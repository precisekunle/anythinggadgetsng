class Review {
  final String id;
  final DateTime createdAt;
  final String userId;
  final String productId;
  final int rating;
  final String? comment;
  final List<String> imageUrls;

  Review({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.productId,
    required this.rating,
    this.comment,
    this.imageUrls = const [],
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      productId: json['product_id'],
      rating: json['rating'],
      comment: json['comment'],
      imageUrls: List<String>.from(json['image_urls'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'product_id': productId,
      'rating': rating,
      'comment': comment,
      'image_urls': imageUrls,
    };
  }
}
