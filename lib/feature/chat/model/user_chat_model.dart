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

// ─────────────────────────────────────────────────────────────
class Rooms {
  String? id;
  String? name; // GROUP only
  String? image; // GROUP only
  bool? isDeleted;
  bool? isBlockedByMe; // ONE_TO_ONE only
  bool? isBlockedMe; // ONE_TO_ONE only
  String? type; // 'GROUP' | 'ONE_TO_ONE'
  String? user1Id; // ONE_TO_ONE only
  String? user2Id; // ONE_TO_ONE only
  int? groupMembersCount; // GROUP only
  int? totalMessages; // GROUP only
  int? unreadCount;
  String? createdAt;
  String? updatedAt;
  bool? voiceAutoSend;
  String? voiceMessage;
  OtherUser? otherUser; // ONE_TO_ONE only
  LatestMessage? latestMessage;
  List<GroupMessage>? groupMembers; // GROUP only

  Rooms({
    this.id,
    this.name,
    this.image,
    this.isDeleted,
    this.isBlockedByMe,
    this.isBlockedMe,
    this.type,
    this.user1Id,
    this.user2Id,
    this.groupMembersCount,
    this.totalMessages,
    this.unreadCount,
    this.createdAt,
    this.updatedAt,
    this.otherUser,
    this.latestMessage,
    this.groupMembers,
  });

  Rooms.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    isDeleted = json['is_deleted'];
    isBlockedByMe = json['isBlockedByMe'];
    isBlockedMe = json['isBlockedMe'];
    type = json['type'];
    user1Id = json['user1_id'];
    user2Id = json['user2_id'];
    groupMembersCount = json['group_members_count'];
    totalMessages = json['total_messages'];
    unreadCount = json['unread_count'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];

    otherUser = json['otherUser'] != null
        ? OtherUser.fromJson(json['otherUser'])
        : null;

    latestMessage = json['latest_message'] != null
        ? LatestMessage.fromJson(json['latest_message'])
        : null;

    if (json['group_members'] != null) {
      groupMembers = <GroupMessage>[];
      json['group_members'].forEach((v) {
        groupMembers!.add(GroupMessage.fromJson(v));
      });
    }
  }

  /// ✅ UI তে name দেখানোর জন্য
  String get displayName {
    if (type == 'GROUP') return name ?? 'Group';
    return otherUser?.nickName ?? 'No Name';
  }

  /// ✅ UI তে avatar দেখানোর জন্য
  String get displayAvatar {
    if (type == 'GROUP') return image ?? '';
    return otherUser?.avatar ?? '';
  }

  /// ✅ GROUP কিনা check
  bool get isGroup => type == 'GROUP';

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['is_deleted'] = isDeleted;
    data['isBlockedByMe'] = isBlockedByMe;
    data['isBlockedMe'] = isBlockedMe;
    data['type'] = type;
    data['user1_id'] = user1Id;
    data['user2_id'] = user2Id;
    data['group_members_count'] = groupMembersCount;
    data['total_messages'] = totalMessages;
    data['unread_count'] = unreadCount;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (otherUser != null) data['otherUser'] = otherUser!.toJson();
    if (latestMessage != null) data['latest_message'] = latestMessage!.toJson();
    if (groupMembers != null) {
      data['group_members'] = groupMembers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}








class OtherUser {
  String? id;
  String? nickName;
  String? licenceId;
  String? avatar;
  double? rating; // ✅ double

  OtherUser({this.id, this.nickName, this.licenceId, this.avatar, this.rating});

  OtherUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nickName = json['nick_name'];
    licenceId = json['licence_id'];
    avatar = json['avatar'];
    // ✅ int বা double যাই আসুক — safe convert
    rating = json['rating'] != null ? (json['rating'] as num).toDouble() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nick_name'] = nickName;
    data['licence_id'] = licenceId;
    data['avatar'] = avatar;
    data['rating'] = rating;
    return data;
  }
}

// ─────────────────────────────────────────────────────────────
class LatestMessage {
  String? id;

  // ONE_TO_ONE only
  String? chatRoomId;
  String? receiverId;
  String? type; // 'TEXT' | 'IMAGE' etc
  bool? isRead;
  bool? isDelivered;
  String? updatedAt;

  // GROUP only
  String? groupChatRoomId;

  // Common
  String? senderId;
  String? message;
  String? createdAt;
  bool? isMine;
  Sender? sender;

  LatestMessage({
    this.id,
    this.chatRoomId,
    this.groupChatRoomId,
    this.senderId,
    this.receiverId,
    this.message,
    this.type,
    this.isRead,
    this.isDelivered,
    this.createdAt,
    this.updatedAt,
    this.isMine,
    this.sender,
  });

  LatestMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    // ONE_TO_ONE
    chatRoomId = json['chatRoom_id'];
    receiverId = json['receiver_id'];
    type = json['type'];
    isRead = json['is_read'];
    isDelivered = json['is_delivered'];
    updatedAt = json['updatedAt'];

    // GROUP
    groupChatRoomId = json['groupChatRoom_id'];

    // Common
    senderId = json['sender_id'];
    message = json['message'];
    createdAt = json['createdAt'];
    isMine = json['is_mine'];

    sender = json['sender'] != null ? Sender.fromJson(json['sender']) : null;
  }

  /// ✅ যেকোনো type এর room id
  String? get roomId => chatRoomId ?? groupChatRoomId;

  /// ✅ unread কিনা — GROUP এ is_read নেই তাই isMine দিয়ে handle
  bool get isUnread {
    if (isMine == true) return false;
    return isRead == false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['chatRoom_id'] = chatRoomId;
    data['groupChatRoom_id'] = groupChatRoomId;
    data['sender_id'] = senderId;
    data['receiver_id'] = receiverId;
    data['message'] = message;
    data['type'] = type;
    data['is_read'] = isRead;
    data['is_delivered'] = isDelivered;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['is_mine'] = isMine;
    if (sender != null) data['sender'] = sender!.toJson();
    return data;
  }
}

// ─────────────────────────────────────────────────────────────
class Sender {
  String? id;
  String? nickName;
  String? avatar;

  Sender({this.id, this.nickName, this.avatar});

  Sender.fromJson(Map<String, dynamic> json) {
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

// ─────────────────────────────────────────────────────────────
class GroupMessage {
  String? id;
  String? userId;
  String? groupRole;
  User? user;

  GroupMessage({this.id, this.userId, this.groupRole, this.user});

  GroupMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    groupRole = json['group_role'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  /// ✅ Admin কিনা check
  bool get isAdmin => groupRole == 'GROUP_ADMIN';

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['group_role'] = groupRole;
    if (user != null) data['user'] = user!.toJson();
    return data;
  }
}

// ─────────────────────────────────────────────────────────────
class User {
  String? id;
  String? nickName;
  String? avatar;
  String? licenceId;

  User({this.id, this.nickName, this.avatar, this.licenceId});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nickName = json['nick_name'];
    avatar = json['avatar'];
    licenceId = json['licence_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nick_name'] = nickName;
    data['avatar'] = avatar;
    data['licence_id'] = licenceId;
    return data;
  }
}
