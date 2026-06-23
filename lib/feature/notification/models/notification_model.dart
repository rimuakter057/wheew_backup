class NotificationModel {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final String createdAt;
  final String? type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      isRead: json['is_read'] ?? json['isRead'] ?? false,
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '',
      type: json['type']?.toString(),
    );
  }
}