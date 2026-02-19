class TermsModel {
  String id;
  String description;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  TermsModel({
    required this.id,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  // JSON থেকে Dart অবজেক্টে কনভার্ট
  factory TermsModel.fromJson(Map<String, dynamic> json) {
    return TermsModel(
      id: json['id'] ?? json['_id'],
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'] ?? 0,
    );
  }

  // Dart অবজেক্ট থেকে JSON এ কনভার্ট
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
      'id': id,
    };
  }
}
