class NotificationEvent {
  final String id;
  final String eventType;
  final String title;
  final String message;
  final bool isRead;
  final String sentAt;

  NotificationEvent({
    required this.id,
    required this.eventType,
    required this.title,
    required this.message,
    required this.isRead,
    required this.sentAt,
  });

  factory NotificationEvent.fromJson(Map<String, dynamic> json) {
    return NotificationEvent(
      id: json['id']?.toString() ?? '',
      eventType: json['eventType']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isRead: json['isRead'] ?? false,
      sentAt: json['sentAt']?.toString() ?? '',
    );
  }

  NotificationEvent copyWith({bool? isRead}) {
    return NotificationEvent(
      id: id,
      eventType: eventType,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt,
    );
  }
}