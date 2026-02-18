class Shop {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final String? address;
  final String? phone;
  final double rating;
  final bool isVerified;

  Shop({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    this.address,
    this.phone,
    this.rating = 0.0,
    this.isVerified = false,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }
}
