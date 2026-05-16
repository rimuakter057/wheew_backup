// user_profile_model.dart
class UserProfileModel {
  final String id;
  final String nickName;
  final String? avatar;
  final String? licenceId;
  final String designation;
  final double rating;
  final String accountType;

  UserProfileModel({
    required this.id,
    required this.nickName,
    this.avatar,
    this.licenceId,
    required this.designation,
    required this.rating,
    required this.accountType,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? '',
      nickName: json['nick_name'] ?? '',
      avatar: json['avatar'],
      licenceId: json['licence_id'],
      designation: json['designation'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      accountType: json['account_type'] ?? 'FREE',
    );
  }
}