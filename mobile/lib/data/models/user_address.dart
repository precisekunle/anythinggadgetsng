class UserAddress {
  final String id;
  final DateTime createdAt;
  final String userId;
  final String label;
  final String fullName;
  final String phoneNumber;
  final String street;
  final String city;
  final String state;
  final bool isDefault;

  UserAddress({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.label,
    required this.fullName,
    required this.phoneNumber,
    required this.street,
    required this.city,
    required this.state,
    this.isDefault = false,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      label: json['label'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'label': label,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'street': street,
      'city': city,
      'state': state,
      'is_default': isDefault,
    };
  }
}
