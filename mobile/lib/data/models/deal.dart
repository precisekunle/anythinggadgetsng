class Deal {
  final String id;
  final String title;
  final DateTime endTime;
  final bool isActive;

  Deal({
    required this.id,
    required this.title,
    required this.endTime,
    required this.isActive,
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['id'] as String,
      title: json['title'] as String,
      endTime: DateTime.parse(json['end_time'] as String),
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'end_time': endTime.toIso8601String(),
      'is_active': isActive,
    };
  }
}
