class MessageResponseModel {
  List<Messages>? messages;
  int? total;

  MessageResponseModel({this.messages, this.total});

  MessageResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(Messages.fromJson(v));

      });
    }
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    return data;
  }
}




class Messages {
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
  Sender? sender;
  Receiver? receiver;
  bool? isMine;
  
  // File & Encryption fields
  String? fileUrl;
  String? fileName;
  int? fileSize;
  String? encryptionType;
  String? encryptionVersion;
  String? senderKeyId;
  String? receiverKeyId;
  String? nonce;
  String? fileMimeType;
  num? durationSeconds;
  dynamic waveform;
  bool? isDeletedForEveryone;
  String? deletedAt;
  String? deletedById;

  Messages({
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
    this.sender,
    this.receiver,
    this.isMine,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.encryptionType,
    this.encryptionVersion,
    this.senderKeyId,
    this.receiverKeyId,
    this.nonce,
    this.fileMimeType,
    this.durationSeconds,
    this.waveform,
    this.isDeletedForEveryone,
    this.deletedAt,
    this.deletedById,
  });

  Messages.fromJson(Map<String, dynamic> json) {
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
    sender = json['sender'] != null ? Sender.fromJson(json['sender']) : null;
    receiver = json['receiver'] != null ? Receiver.fromJson(json['receiver']) : null;
    isMine = json['is_mine'] ?? false;
    fileUrl = json['file_url'];
    fileName = json['file_name'];
    fileSize = json['file_size'] != null ? (json['file_size'] as num).toInt() : null;
    encryptionType = json['encryptionType'];
    encryptionVersion = json['encryptionVersion'];
    senderKeyId = json['senderKeyId'];
    receiverKeyId = json['receiverKeyId'];
    nonce = json['nonce'];
    fileMimeType = json['file_mime_type'];
    durationSeconds = json['durationSeconds'];
    waveform = json['waveform'];
    isDeletedForEveryone = json['isDeletedForEveryone'] ?? false;
    deletedAt = json['deletedAt'];
    deletedById = json['deletedById'];
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
    if (sender != null) data['sender'] = sender!.toJson();
    if (receiver != null) data['receiver'] = receiver!.toJson();
    data['is_mine'] = isMine;
    data['file_url'] = fileUrl;
    data['file_name'] = fileName;
    data['file_size'] = fileSize;
    data['encryptionType'] = encryptionType;
    data['encryptionVersion'] = encryptionVersion;
    data['senderKeyId'] = senderKeyId;
    data['receiverKeyId'] = receiverKeyId;
    data['nonce'] = nonce;
    data['file_mime_type'] = fileMimeType;
    data['durationSeconds'] = durationSeconds;
    data['waveform'] = waveform;
    data['isDeletedForEveryone'] = isDeletedForEveryone;
    data['deletedAt'] = deletedAt;
    data['deletedById'] = deletedById;
    return data;
  }
}


class Sender {
  String? id;
  String? nickName;
  String? avatar;

  Sender({this.id, this.nickName, this.avatar});

  Sender.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nickName = json['nick_name'];
    avatar = json['avatar'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nick_name'] = nickName;
    data['avatar'] = avatar;
    return data;
  }
}

class Receiver {
  String? id;
  String? nickName;
  String? avatar;

  Receiver({this.id, this.nickName, this.avatar});

  Receiver.fromJson(Map<String, dynamic> json) {
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
