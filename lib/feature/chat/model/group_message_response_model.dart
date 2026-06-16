// ✅ Wrapper class — API response এর জন্য
class GroupMessageListResponse {
  List<GroupMessageResponseModel>? messages;
  int? total;

  GroupMessageListResponse({this.messages, this.total});

  GroupMessageListResponse.fromJson(Map<String, dynamic> json) {
    if (json['messages'] != null) {
      messages = <GroupMessageResponseModel>[];
      json['messages'].forEach((v) {
        messages!.add(GroupMessageResponseModel.fromJson(v));
      });
    }
    total = json['total'];
  }
}

// ✅ new keyword সরানো, clean version
// class GroupMessageResponseModel {
//   String? id;
//   String? groupChatRoomId;
//   String? senderId;
//   String? message;
//   String? type;
//   String? createdAt;
//   String? updatedAt;
//   GroupSender? sender;
//   bool? isMine;
//
//   GroupMessageResponseModel({
//     this.id,
//     this.groupChatRoomId,
//     this.senderId,
//     this.message,
//     this.type,
//     this.createdAt,
//     this.updatedAt,
//     this.sender,
//     this.isMine,
//   });
//
//   GroupMessageResponseModel.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     groupChatRoomId = json['groupChatRoom_id'];
//     senderId = json['sender_id'];
//     message = json['message'];
//     type = json['type'];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     sender = json['sender'] != null
//         ? GroupSender.fromJson(json['sender'])
//         : null;
//     isMine = json['is_mine'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['groupChatRoom_id'] = groupChatRoomId;
//     data['sender_id'] = senderId;
//     data['message'] = message;
//     data['type'] = type;
//     data['createdAt'] = createdAt;
//     data['updatedAt'] = updatedAt;
//     if (sender != null) data['sender'] = sender!.toJson();
//     data['is_mine'] = isMine;
//     return data;
//   }
// }

// ✅ Sender rename করা হয়েছে GroupSender — conflict এড়াতে


class GroupMessageResponseModel {
  String? id;
  String? groupChatRoomId;
  String? senderId;
  String? message;
  String? type;
  String? createdAt;
  String? updatedAt;
  GroupSender? sender;
  bool? isMine;
  // ✅ নতুন fields
  String? fileUrl;
  String? fileName;
  int? fileSize;

  GroupMessageResponseModel({
    this.id,
    this.groupChatRoomId,
    this.senderId,
    this.message,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.sender,
    this.isMine,
    this.fileUrl,
    this.fileName,
    this.fileSize,
  });

  GroupMessageResponseModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    groupChatRoomId = json['groupChatRoom_id'];
    senderId = json['sender_id'];
    message = json['message'];
    type = json['type'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    sender = json['sender'] != null
        ? GroupSender.fromJson(json['sender'])
        : null;
    isMine = json['is_mine'];
    // ✅ নতুন fields parse
    fileUrl = json['file_url'];
    fileName = json['file_name'];
    fileSize = json['file_size'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['groupChatRoom_id'] = groupChatRoomId;
    data['sender_id'] = senderId;
    data['message'] = message;
    data['type'] = type;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (sender != null) data['sender'] = sender!.toJson();
    data['is_mine'] = isMine;
    // ✅ নতুন fields
    data['file_url'] = fileUrl;
    data['file_name'] = fileName;
    data['file_size'] = fileSize;
    return data;
  }
}

class GroupSender {
  String? id;
  String? nickName;
  String? avatar;

  GroupSender({this.id, this.nickName, this.avatar});

  GroupSender.fromJson(Map<String, dynamic> json) {
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