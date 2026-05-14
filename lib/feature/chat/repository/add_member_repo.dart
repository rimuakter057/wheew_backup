import 'dart:convert';

import 'package:platchatapp/core/service/api_url.dart';


import '../../../core/service/api_client.dart' show ApiClient; // ApiUrl এর location অনুযায়ী adjust করুন

class AddMemberRepository {
  /// Search users for adding to group
  /// API: GET /users/search?query=<query>&for=group&roomId=<roomId>
  /// Response: { "users": [ {...} ], "totalUsers": 1 }
  Future<List<SearchMemberModel>> searchGroupMember({
    required String roomId,
    required String query,
  }) async {
    try {
      final response = await ApiClient.getData(
        uri: ApiUrl.searchGroupMember(roomId: roomId),
        queryParams: {
          'query': query.isEmpty ? 'r' : query,
          'for': 'group',
          'roomId': roomId,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Response: { "users": [...], "totalUsers": 1 }
        final List data = jsonData['users'] ?? [];
        return data
            .map((e) => SearchMemberModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

/// Response JSON এর প্রতিটি user object এর উপর ভিত্তি করে model:
/// {
///   "id": "6982d8e8006f662761783a7e",
///   "avatar": null,
///   "licence_id": "7654321",
///   "nick_name": "Hasan",
///   "designation": "occasional_driver",
///   "role": "USER",
///   "createdAt": "...",
///   "updatedAt": "..."
/// }
class SearchMemberModel {
  final String id;
  final String nickName;
  final String? avatar;
  final String? licenceId;
  final String? designation;
  final String role;
  final bool isBlocked;
  final bool isMoreOptionsAccepted;
  final ExistingRoom? existingRoom;

  const SearchMemberModel({
    required this.id,
    required this.nickName,
    this.avatar,
    this.licenceId,
    this.designation,
    this.role = 'USER',
    this.isBlocked = false,
    this.isMoreOptionsAccepted = false,
    this.existingRoom,
  });

  factory SearchMemberModel.fromJson(Map<String, dynamic> json) {
    return SearchMemberModel(
      id: json['id']?.toString() ?? '',
      nickName: json['nick_name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      licenceId: json['licence_id']?.toString(),
      designation: json['designation']?.toString(),
      role: json['role']?.toString() ?? 'USER',
      isBlocked: json['is_blocked'] as bool? ?? false,
      isMoreOptionsAccepted: json['is_more_options_accepted'] as bool? ?? false,
      existingRoom: json['existingRoom'] != null
          ? ExistingRoom.fromJson(json['existingRoom'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ExistingRoom {
  final String id;
  final String user1Id;
  final String user2Id;

  const ExistingRoom({
    required this.id,
    required this.user1Id,
    required this.user2Id,
  });

  factory ExistingRoom.fromJson(Map<String, dynamic> json) {
    return ExistingRoom(
      id: json['id']?.toString() ?? '',
      user1Id: json['user1_id']?.toString() ?? '',
      user2Id: json['user2_id']?.toString() ?? '',
    );
  }
}