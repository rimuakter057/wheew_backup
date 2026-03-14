/*
class UserModel {
  final String nickName;
  final String licenceId;
  final String? avatar; // Made optional with ?

  UserModel({
    required this.nickName,
    required this.licenceId,
    this.avatar, // Removed required
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      nickName: json['nick_name'] ?? '',
      licenceId: json['licence_id'] ?? '',
      avatar: json['avatar'],
    );
  }
}
*/
class UserModel {
  final String nickName;
  final String licenceId;
  final String? avatar;

  UserModel({
    required this.nickName,
    required this.licenceId,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      nickName: json['nick_name'] ?? '',
      licenceId: json['licence_id'] ?? '',
      avatar: json['avatar'],
    );
  }

  // ✅ copyWith for easy updates
  UserModel copyWith({String? nickName, String? licenceId, String? avatar}) {
    return UserModel(
      nickName: nickName ?? this.nickName,
      licenceId: licenceId ?? this.licenceId,
      avatar: avatar ?? this.avatar,
    );
  }

  Map<String, dynamic> toJson() => {
    'nick_name': nickName,
    'licence_id': licenceId,
    'avatar': avatar,
  };
}