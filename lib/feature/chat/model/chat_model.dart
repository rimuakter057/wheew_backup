
// class ChatModel {
//   final String id;
//   final String name;
//   final String designation;
//   final String time;
//   final String? avatar;
//
//   ChatModel({
//     required this.id,
//     required this.name,
//     required this.designation,
//     required this.time,
//     this.avatar,
//   });
//
//   factory ChatModel.fromJson(Map<String, dynamic> json) {
//     return ChatModel(
//       id: json['id'] ?? '',
//       name: json['nick_name'] ?? json['name'] ?? '',  // Use nick_name from API
//       designation: json['designation'] ?? 'No message',   // Temporary, adjust based on your needs
//       time: json['createdAt'] ?? '',
//       avatar: json['avatar'],
//     );
//   }
// }























class ChatModel {
  String? id;
  String? avatar;
  String? nickName;
  Null designation;
  String? createdAt;
  ExistingRoom? existingRoom;

  ChatModel(
      {this.id,
        this.avatar,
        this.nickName,
        this.designation,

        this.createdAt,

        this.existingRoom
      });

  ChatModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    avatar = json['avatar'];

    nickName = json['nick_name'];
    designation = json['designation'];

    createdAt = json['createdAt'];

    existingRoom = json['existingRoom'] != null
        ? ExistingRoom.fromJson(json['existingRoom'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['avatar'] = avatar;

    data['nick_name'] = nickName;
    data['designation'] = designation;

    data['createdAt'] = createdAt;

    if (existingRoom != null) {
      data['existingRoom'] = existingRoom!.toJson();
    }
    return data;
  }
}





// class ChatModel {
//   final String id;
//   final String? avatar;
//   final String nickName;
//   final String designation;
//   final String createdAt;
//
//
//
//   ChatModel({
//     required this.id,
//     this.avatar,
//     required this.nickName,
//     required this.designation,
//     required this.createdAt,
//
//   });
//
//   factory ChatModel.fromJson(Map<String, dynamic> json) {
//     return ChatModel(
//       id: json['id'] ?? '',
//       avatar: json['avatar'],
//       nickName: json['nick_name'] ?? json['name'] ?? '',  // Use nick_name from API
//       designation: json['designation'] ?? 'No message',   // Temporary, adjust based on your needs
//       createdAt: json['createdAt'] ?? '',
//
//     );
//   }
// }

















class ExistingRoom {
  String? id;
  String? user1Id;
  String? user2Id;
  String? createdAt;
  String? updatedAt;

  ExistingRoom(
      {this.id, this.user1Id, this.user2Id, this.createdAt, this.updatedAt});

  ExistingRoom.fromJson(Map<String, dynamic> json) {
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
