class FaqModel {
  final String id;
  final String question;
  final String answer;

  FaqModel({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id']?.toString() ?? '',
      question: (json['title'] ?? json['question'] ?? '').toString(),
      answer: (json['description'] ?? json['answer'] ?? '').toString(),
    );
  }
}