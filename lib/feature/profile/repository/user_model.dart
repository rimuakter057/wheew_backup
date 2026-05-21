class UserModel {
  final String? id;
  final String nickName;
  final String licenceId;
  final String? avatar;
  final String? designation;
  final double?rating;
  final String? createdAt;
  ExistingRoom2? existingRoom; // mutable রাখো — room update হতে পারে

  UserModel( {
    this.id,
    required this.nickName,
    required this.licenceId,
    this.rating,
    this.avatar,
    this.designation,
    this.createdAt,
    this.existingRoom,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nickName: json['nick_name'] ?? '',
      licenceId: json['licence_id'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      avatar: json['avatar'],
      designation: json['designation'],
      createdAt: json['createdAt'],
      existingRoom: json['existingRoom'] != null
          ? ExistingRoom2.fromJson(json['existingRoom'])
          : null,
    );
  }

  UserModel copyWith({
    String? id,
    String? nickName,
    String? licenceId,
    String? avatar,
    String? designation,
    String? createdAt,
    ExistingRoom2? existingRoom,
  }) {
    return UserModel(
      id: id ?? this.id,
      nickName: nickName ?? this.nickName,
      licenceId: licenceId ?? this.licenceId,
      avatar: avatar ?? this.avatar,
      designation: designation ?? this.designation,
      createdAt: createdAt ?? this.createdAt,
      existingRoom: existingRoom ?? this.existingRoom,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nick_name': nickName,
    'licence_id': licenceId,
    'avatar': avatar,
    'designation': designation,
    'createdAt': createdAt,
    'existingRoom': existingRoom?.toJson(),
  };
}

// ExistingRoom2 Model
class ExistingRoom2 {
  final String? id;
  final String? user1Id;
  final String? user2Id;
  final bool? isDeleted;
  final String? createdAt;
  final String? updatedAt;

  ExistingRoom2({
    this.id,
    this.user1Id,
    this.user2Id,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  factory ExistingRoom2.fromJson(Map<String, dynamic> json) {
    return ExistingRoom2(
      id: json['id'],
      user1Id: json['user1_id'],
      user2Id: json['user2_id'],
      isDeleted: json['is_deleted'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user1_id': user1Id,
    'user2_id': user2Id,
    'is_deleted': isDeleted,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}