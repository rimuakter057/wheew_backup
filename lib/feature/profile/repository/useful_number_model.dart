class UsefulNumber {
  final String id;
  final String title;
  final String description;
  final String phone;
  final String category;
  final String icon;
  final int sortOrder;
  final bool isActive;

  UsefulNumber({
    required this.id,
    required this.title,
    required this.description,
    required this.phone,
    required this.category,
    required this.icon,
    required this.sortOrder,
    required this.isActive,
  });

  factory UsefulNumber.fromJson(Map<String, dynamic> json) {
    return UsefulNumber(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      sortOrder: json['sortOrder'] is num ? (json['sortOrder'] as num).toInt() : 0,
      isActive: json['isActive'] == true,
    );
  }
}
