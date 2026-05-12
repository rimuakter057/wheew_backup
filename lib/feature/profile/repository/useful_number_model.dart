class UsefulNumber {
  final String id;
  final String title;
  final String phone;

  UsefulNumber({
    required this.id,
    required this.title,
    required this.phone,
  });

  factory UsefulNumber.fromJson(Map<String, dynamic> json) {
    return UsefulNumber(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      phone: json['phone'] ?? '',
    );
  }}