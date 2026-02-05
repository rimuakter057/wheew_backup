class UserModel {
  final String nickName;
  final String licenceId;
  final String? avatar;  // Made optional with ?

  UserModel({
    required this.nickName,
    required this.licenceId,
    this.avatar,  // Removed required
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      nickName: json['nick_name'] ?? '',
      licenceId: json['licence_id'] ?? '',
      avatar: json['avatar'],
    );
  }
}