/*
class ChatModel {
  final String id;
  final String name;
  final String message;
  final String time;
  final String? imagePath;

  ChatModel({
    required this.id,
    required this.name,
    required this.message,
    required this.time,
    this.imagePath,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      message: json['message'] ?? '',
      time: json['time'] ?? '',
      imagePath: json['imagePath'] ?? json['image'],
    );
  }
}*/



class ChatModel {
  final String id;
  final String name;
  final String message;
  final String time;
  final String? imagePath;

  ChatModel({
    required this.id,
    required this.name,
    required this.message,
    required this.time,
    this.imagePath,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? '',
      name: json['nick_name'] ?? json['name'] ?? '',  // Use nick_name from API
      message: json['designation'] ?? 'No message',   // Temporary, adjust based on your needs
      time: json['createdAt'] ?? '',
      imagePath: json['avatar'],
    );
  }
}