// class UserModel {
//   final String? id;
//   final String nickName;
//   final String licenceId;
//   final String? avatar;
//   final String? designation;
//   final double?rating;
//   final String? createdAt;
//   ExistingRoom2? existingRoom; // mutable রাখো — room update হতে পারে
//
//   UserModel( {
//     this.id,
//     required this.nickName,
//     required this.licenceId,
//     this.rating,
//     this.avatar,
//     this.designation,
//     this.createdAt,
//     this.existingRoom,
//   });
//
//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       id: json['id'],
//       nickName: json['nick_name'] ?? '',
//       licenceId: json['licence_id'] ?? '',
//       rating: (json['rating'] ?? 0).toDouble(),
//       avatar: json['avatar'],
//       designation: json['designation'],
//       createdAt: json['createdAt'],
//       existingRoom: json['existingRoom'] != null
//           ? ExistingRoom2.fromJson(json['existingRoom'])
//           : null,
//     );
//   }
//
//   UserModel copyWith({
//     String? id,
//     String? nickName,
//     String? licenceId,
//     String? avatar,
//     String? designation,
//     String? createdAt,
//     ExistingRoom2? existingRoom,
//   }) {
//     return UserModel(
//       id: id ?? this.id,
//       nickName: nickName ?? this.nickName,
//       licenceId: licenceId ?? this.licenceId,
//       avatar: avatar ?? this.avatar,
//       designation: designation ?? this.designation,
//       createdAt: createdAt ?? this.createdAt,
//       existingRoom: existingRoom ?? this.existingRoom,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'nick_name': nickName,
//     'licence_id': licenceId,
//     'avatar': avatar,
//     'designation': designation,
//     'createdAt': createdAt,
//     'existingRoom': existingRoom?.toJson(),
//   };
// }

// ExistingRoom2 Model


class UserModel {
  final String? id;
  final String? email;

  final String nickName;
  final String licenceId;
  final String? avatar;
  final String? designation;
  final double? rating;

  final int? totalRatings;
  final String? createdAt;
  final String? role;

  final bool? licenseNoVerified;
  final String? vehicleType;
  final String? vehicleModel;
  final String? vehicleColor;
  final bool? isVehicleVerified;
  final bool? isVehicleOwnershipDocumentSubmitted;

  final String? country;
  final String? city;

  ExistingRoom2? existingRoom;

  UserModel({
    this.id,
    this.email,
    required this.nickName,
    required this.licenceId,
    this.avatar,
    this.designation,
    this.rating,
    this.totalRatings,
    this.createdAt,
    this.role,
    this.licenseNoVerified,
    this.vehicleType,
    this.vehicleModel,
    this.vehicleColor,
    this.isVehicleVerified,
    this.isVehicleOwnershipDocumentSubmitted,
    this.country,
    this.city,
    this.existingRoom,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      nickName: json['nick_name'] ?? '',
      licenceId: json['licence_id'] ?? '',
      avatar: json['avatar'],
      designation: json['designation'],
      rating: (json['rating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      createdAt: json['createdAt'],
      role: json['role'],

      licenseNoVerified: json['license_no_verified'],
      vehicleType: json['vehicle_type'],
      vehicleModel: json['vehicle_model'],
      vehicleColor: json['vehicle_color'],
      isVehicleVerified: json['is_vehicle_verified'],
      isVehicleOwnershipDocumentSubmitted:
      json['is_vehicle_ownership_document_submitted'],

      country: json['country'],
      city: json['city'],

      existingRoom: json['existingRoom'] != null
          ? ExistingRoom2.fromJson(json['existingRoom'])
          : null,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? nickName,
    String? licenceId,
    String? avatar,
    String? designation,
    double? rating,

    int? totalRatings,
    String? createdAt,
    String? role,
    bool? licenseNoVerified,
    String? vehicleType,
    String? vehicleModel,
    String? vehicleColor,
    bool? isVehicleVerified,
    bool? isVehicleOwnershipDocumentSubmitted,
    String? country,
    String? city,
    ExistingRoom2? existingRoom,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nickName: nickName ?? this.nickName,
      licenceId: licenceId ?? this.licenceId,
      avatar: avatar ?? this.avatar,
      designation: designation ?? this.designation,
      rating: rating ?? this.rating,

      totalRatings: totalRatings ?? this.totalRatings,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      licenseNoVerified: licenseNoVerified ?? this.licenseNoVerified,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      isVehicleVerified: isVehicleVerified ?? this.isVehicleVerified,
      isVehicleOwnershipDocumentSubmitted:
      isVehicleOwnershipDocumentSubmitted ??
          this.isVehicleOwnershipDocumentSubmitted,
      country: country ?? this.country,
      city: city ?? this.city,
      existingRoom: existingRoom ?? this.existingRoom,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'nick_name': nickName,
    'licence_id': licenceId,
    'avatar': avatar,
    'designation': designation,
    'rating': rating,

    'totalRatings': totalRatings,
    'createdAt': createdAt,
    'role': role,
    'license_no_verified': licenseNoVerified,
    'vehicle_type': vehicleType,
    'vehicle_model': vehicleModel,
    'vehicle_color': vehicleColor,
    'is_vehicle_verified': isVehicleVerified,
    'is_vehicle_ownership_document_submitted':
    isVehicleOwnershipDocumentSubmitted,
    'country': country,
    'city': city,
    'existingRoom': existingRoom?.toJson(),
  };
}


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