class PresetMessage {
  final String message;
  final String messageIt;

  PresetMessage({required this.message, required this.messageIt});

  factory PresetMessage.fromJson(Map<String, dynamic> json) {
    return PresetMessage(
      message: json['message']?.toString() ?? '',
      messageIt: json['message_it']?.toString() ?? '',
    );
  }
}