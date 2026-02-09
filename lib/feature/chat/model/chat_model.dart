


class ChatModel {
  final String id;
  final String name;
  final String message;
  final String time;
  final String? avatar;

  ChatModel({
    required this.id,
    required this.name,
    required this.message,
    required this.time,
    this.avatar,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? '',
      name: json['nick_name'] ?? json['name'] ?? '',  // Use nick_name from API
      message: json['designation'] ?? 'No message',   // Temporary, adjust based on your needs
      time: json['createdAt'] ?? '',
      avatar: json['avatar'],
    );
  }
}



















// class SearchModel {
//   List<Users>? users;
//   int? totalUsers;
//
//   SearchModel({this.users, this.totalUsers});
//
//   SearchModel.fromJson(Map<String, dynamic> json) {
//     if (json['users'] != null) {
//       users = <Users>[];
//       json['users'].forEach((v) {
//         users!.add(Users.fromJson(v));
//       });
//     }
//     totalUsers = json['totalUsers'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (this.users != null) {
//       data['users'] = users!.map((v) => v.toJson()).toList();
//     }
//     data['totalUsers'] = totalUsers;
//     return data;
//   }
// }
//
// class Users {
//   String? id;
//   String? avatar;
//   String? licenceId;
//   String? nickName;
//   Null designation;
//   String? role;
//   String? createdAt;
//   String? updatedAt;
//   ExistingRoom? existingRoom;
//
//   Users(
//       {this.id,
//         this.avatar,
//         this.licenceId,
//         this.nickName,
//         this.designation,
//         this.role,
//         this.createdAt,
//         this.updatedAt,
//         this.existingRoom});
//
//   Users.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     avatar = json['avatar'];
//     licenceId = json['licence_id'];
//     nickName = json['nick_name'];
//     designation = json['designation'];
//     role = json['role'];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     existingRoom = json['existingRoom'] != null
//         ? new ExistingRoom.fromJson(json['existingRoom'])
//         : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['avatar'] = avatar;
//     data['licence_id'] = licenceId;
//     data['nick_name'] = nickName;
//     data['designation'] = designation;
//     data['role'] = role;
//     data['createdAt'] = createdAt;
//     data['updatedAt'] = updatedAt;
//     if (existingRoom != null) {
//       data['existingRoom'] = existingRoom!.toJson();
//     }
//     return data;
//   }
// }
//
// class ExistingRoom {
//   String? id;
//   String? user1Id;
//   String? user2Id;
//   String? createdAt;
//   String? updatedAt;
//
//   ExistingRoom(
//       {this.id, this.user1Id, this.user2Id, this.createdAt, this.updatedAt});
//
//   ExistingRoom.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     user1Id = json['user1_id'];
//     user2Id = json['user2_id'];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['user1_id'] = user1Id;
//     data['user2_id'] = user2Id;
//     data['createdAt'] = createdAt;
//     data['updatedAt'] = updatedAt;
//     return data;
//   }
// }
