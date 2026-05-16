class GroupMemberModel {
  final String id;
  final String userId;
  final String groupRole;
  final String nickName;
  final String avatar;
  final String licenceId;

  GroupMemberModel({
    required this.id,
    required this.userId,
    required this.groupRole,
    required this.nickName,
    required this.avatar,
    required this.licenceId,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return GroupMemberModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      groupRole: json['group_role'] ?? '',
      nickName: user['nick_name'] ?? '',
      avatar: user['avatar'] ?? '',
      licenceId: user['licence_id'] ?? '',
    );
  }
}