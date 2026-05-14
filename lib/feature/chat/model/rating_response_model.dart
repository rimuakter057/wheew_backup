class RatingUserBrief {
  final String id;
  final String? nickName;
  final String? avatar;

  RatingUserBrief({
    required this.id,
    this.nickName,
    this.avatar,
  });

  factory RatingUserBrief.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RatingUserBrief(id: '');
    }
    return RatingUserBrief(
      id: '${json['id'] ?? ''}',
      nickName: json['nick_name']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }
}

/// Response from GET /ratings/my-rating/:rateeId or POST/PATCH /ratings.
class ChatRatingResponse {
  final String id;
  final String raterId;
  final String rateeId;
  final int rating;
  final String status;
  final String createdAt;
  final String updatedAt;
  final RatingUserBrief? rater;
  final RatingUserBrief? ratee;

  ChatRatingResponse({
    required this.id,
    required this.raterId,
    required this.rateeId,
    required this.rating,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.rater,
    this.ratee,
  });

  factory ChatRatingResponse.fromJson(Map<String, dynamic> json) {
    return ChatRatingResponse(
      id: '${json['id'] ?? ''}',
      raterId: '${json['rater_id'] ?? ''}',
      rateeId: '${json['ratee_id'] ?? ''}',
      rating: _parseInt(json['rating']),
      status: '${json['status'] ?? ''}',
      createdAt: '${json['createdAt'] ?? ''}',
      updatedAt: '${json['updatedAt'] ?? ''}',
      rater: json['rater'] is Map<String, dynamic>
          ? RatingUserBrief.fromJson(
              Map<String, dynamic>.from(json['rater'] as Map),
            )
          : null,
      ratee: json['ratee'] is Map<String, dynamic>
          ? RatingUserBrief.fromJson(
              Map<String, dynamic>.from(json['ratee'] as Map),
            )
          : null,
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.round();
    return int.tryParse('$v') ?? 0;
  }
}
