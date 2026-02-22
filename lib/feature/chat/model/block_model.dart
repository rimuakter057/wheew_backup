class BlockModel {
  String? id;
  String? userId;
  String? blockedUserId;
  String? createdAt;
  String? updatedAt;
  BlockedUser? blockedUser;

  BlockModel(
      {this.id,
        this.userId,
        this.blockedUserId,
        this.createdAt,
        this.updatedAt,
        this.blockedUser});

  BlockModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    blockedUserId = json['blocked_user_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    blockedUser = json['blocked_user'] != null
        ? BlockedUser.fromJson(json['blocked_user'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['blocked_user_id'] = blockedUserId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (blockedUser != null) {
      data['blocked_user'] = blockedUser!.toJson();
    }
    return data;
  }
}

class BlockedUser {
  String? id;
  String? nickName;
  String? avatar;

  BlockedUser({this.id, this.nickName, this.avatar});

  BlockedUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nickName = json['nick_name'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nick_name'] = nickName;
    data['avatar'] = avatar;
    return data;
  }
}
