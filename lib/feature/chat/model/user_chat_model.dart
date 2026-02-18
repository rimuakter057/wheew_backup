import 'message_response_model.dart';

class UserChatModel {
  List<Rooms>? rooms;
  int? total;

  UserChatModel({this.rooms, this.total});

  UserChatModel.fromJson(Map<String, dynamic> json) {
    if (json['rooms'] != null) {
      rooms = <Rooms>[];
      json['rooms'].forEach((v) {
        rooms!.add(Rooms.fromJson(v));
      });
    }
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (rooms != null) {
      data['rooms'] = rooms!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    return data;
  }
}



class Rooms {
  String? id;
  bool?isBlockedByMe;
  bool?isBlockedMe;

  OtherUser? otherUser;
  LatestMessage? latestMessage;
  int? unreadCount;

  Rooms({this.id, this.otherUser, this.latestMessage, this.unreadCount,this.isBlockedByMe,this.isBlockedMe});

  Rooms.fromJson(Map<String, dynamic> json) {
    id = json['id'];
isBlockedByMe=json['isBlockedByMe'];
isBlockedMe=json["isBlockedMe"];

    otherUser = json['otherUser'] != null
        ? OtherUser.fromJson(json['otherUser'])
        : null;
    latestMessage = json['latest_message'] != null
        ? LatestMessage.fromJson(json['latest_message'])
        : null;
    unreadCount = json['unread_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
   data["isBlockedByMe"]=isBlockedByMe;
   data["isBlockedByMe"]=isBlockedMe;


    if (otherUser != null) {
      data['otherUser'] = otherUser!.toJson();
    }
    if (latestMessage != null) {
      data['latest_message'] = latestMessage!.toJson();
    }
    data['unread_count'] = unreadCount;
    return data;
  }
}

class OtherUser {
  String? id;
  String? nickName;
  String? licenceId;
  String? avatar;

  OtherUser({this.id, this.nickName, this.licenceId, this.avatar});

  OtherUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nickName = json['nick_name'];
    licenceId = json['licence_id'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nick_name'] = nickName;
    data['licence_id'] = licenceId;
    data['avatar'] = avatar;
    return data;
  }
}

class LatestMessage {
  String? id;
  String? chatRoomId;
  String? senderId;
  String? receiverId;
  String? message;
  String? type;
  bool? isRead;
  bool? isDelivered;
  String? createdAt;
  String? updatedAt;

  bool? isMine;

  LatestMessage({
    this.id,
    this.chatRoomId,
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.isRead,
    this.isDelivered,
    this.createdAt,
    this.updatedAt,

    this.isMine,
  });

  LatestMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chatRoomId = json['chatRoom_id'];
    senderId = json['sender_id'];
    receiverId = json['receiver_id'];
    message = json['message'];
    type = json['type'];
    isRead = json['is_read'];
    isDelivered = json['is_delivered'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];

    isMine = json['is_mine'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['chatRoom_id'] = chatRoomId;
    data['sender_id'] = senderId;
    data['receiver_id'] = receiverId;
    data['message'] = message;
    data['type'] = type;
    data['is_read'] = isRead;
    data['is_delivered'] = isDelivered;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;

    data['is_mine'] = isMine;
    return data;
  }
}











