class UserModel {
  final String id;
  final String? avatar;
  final String? email;
  final String? name;
  final String licenceId;
  final String nickName;
  final String? designation;
  final String role;

  UserModel({
    required this.id,
    this.avatar,
    this.email,
    this.name,
    required this.licenceId,
    required this.nickName,
    this.designation,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      avatar: json['avatar'],
      email: json['email'],
      name: json['name'],
      licenceId: json['licence_id'] ?? '',
      nickName: json['nick_name'] ?? '',
      designation: json['designation'],
      role: json['role'] ?? 'USER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'avatar': avatar,
      'email': email,
      'name': name,
      'licence_id': licenceId,
      'nick_name': nickName,
      'designation': designation,
      'role': role,
    };
  }
}