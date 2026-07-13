class PresetMessage {
  final String id;
  final String message;
  final String messageIt;
  final String type; // 'CLASSIC' | 'ALERT'
  final bool isActive;

  PresetMessage({
    required this.id,
    required this.message,
    required this.messageIt,
    required this.type,
    required this.isActive,

  });

  factory PresetMessage.fromJson(Map<String, dynamic> json) {
    return PresetMessage(
      id: json['id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      messageIt: json['message_it']?.toString() ?? '',
      type: json['type']?.toString() ?? 'CLASSIC',
      isActive: json['isActive'] ?? true,
    );
  }
}