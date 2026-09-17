class ViewUserProfileModel {
  final String id;
  final String? avatar;
  final String? email;
  final String? name;
  final String? nickName;
  final String? licenceId;
  final String? designation;

  final bool isVehicleVerified;
  final bool licenseNoVerified;
  final bool emailVerified;

  final String? vehicleType;
  final String? vehicleModel;
  final String? vehicleColor;

  final String? country;
  final String? city;

  /// Nullable on purpose — the API returns `"age": null` for users who
  /// signed up before birth_year became a required field.
  final int? age;

  /// Raw API enum: MALE | FEMALE | PREFER_NOT_TO_SAY (null for older
  /// accounts created before gender was collected at signup).
  final String? gender;

  final double rating;
  final double totalRating;
  final int totalRatings;

  final int parkingNotificationsAvailable;
  final int parkingReportsSubmitted;

  ViewUserProfileModel({
    required this.id,
    this.avatar,
    this.email,
    this.name,
    this.nickName,
    this.licenceId,
    this.designation,
    required this.isVehicleVerified,
    required this.licenseNoVerified,
    required this.emailVerified,
    this.vehicleType,
    this.vehicleModel,
    this.vehicleColor,
    this.country,
    this.city,
    this.age,
    this.gender,
    required this.rating,
    required this.totalRating,
    required this.totalRatings,
    required this.parkingNotificationsAvailable,
    required this.parkingReportsSubmitted,
  });

  factory ViewUserProfileModel.fromJson(Map<String, dynamic> json) {
    return ViewUserProfileModel(
      id: json['id'] ?? '',
      avatar: json['avatar'],
      email: json['email'],
      name: json['name'],
      nickName: json['nick_name'],
      licenceId: json['licence_id'],
      designation: json['designation'],
      isVehicleVerified: json['is_vehicle_verified'] ?? false,
      licenseNoVerified: json['license_no_verified'] ?? false,
      emailVerified: json['email_verified'] ?? false,
      vehicleType: json['vehicle_type'],
      vehicleModel: json['vehicle_model'],
      vehicleColor: json['vehicle_color'],
      country: json['country'],
      city: json['city'],
      // Tolerates both a number and a numeric string from the API.
      age: json['age'] is num
          ? (json['age'] as num).toInt()
          : int.tryParse(json['age']?.toString() ?? ''),
      gender: json['gender'],
      rating: (json['rating'] ?? 0).toDouble(),
      totalRating: (json['totalRating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      parkingNotificationsAvailable:
      json['parking_notifications_available'] ?? 0,
      parkingReportsSubmitted:
      json['parking_reports_submitted'] ?? 0,
    );
  }
}