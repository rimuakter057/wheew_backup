

class SearchModel {
  String? id;
  String? avatar;
  String? nickName;
  String?licenceId;
  String? designation;
  String? createdAt;
  ExistingRoom2? existingRoom;

  SearchModel({
    this.id,
    this.avatar,
    this.nickName,
    this.designation,
    this.licenceId,
    this.createdAt,

    this.existingRoom,
  });

  SearchModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    avatar = json['avatar'];

    nickName = json['nick_name'];
    licenceId=json["licence_id"];
    designation = json['designation'];

    createdAt = json['createdAt'];

    existingRoom = json['existingRoom'] != null
        ? ExistingRoom2.fromJson(json['existingRoom'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['avatar'] = avatar;

    data['nick_name'] = nickName;
    data["licence_id"]=licenceId;
    data['designation'] = designation;

    data['createdAt'] = createdAt;

    if (existingRoom != null) {
      data['existingRoom'] = existingRoom!.toJson();
    }
    return data;
  }
}

class ExistingRoom2 {
  String? id;
  String? user1Id;
  String? user2Id;
  String? createdAt;
  String? updatedAt;

  ExistingRoom2({
    this.id,
    this.user1Id,
    this.user2Id,
    this.createdAt,
    this.updatedAt,
  });

  ExistingRoom2.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user1Id = json['user1_id'];
    user2Id = json['user2_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user1_id'] = user1Id;
    data['user2_id'] = user2Id;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
