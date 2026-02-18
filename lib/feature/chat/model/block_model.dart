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
        ? new BlockedUser.fromJson(json['blocked_user'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['blocked_user_id'] = this.blockedUserId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.blockedUser != null) {
      data['blocked_user'] = this.blockedUser!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nick_name'] = this.nickName;
    data['avatar'] = this.avatar;
    return data;
  }
}
