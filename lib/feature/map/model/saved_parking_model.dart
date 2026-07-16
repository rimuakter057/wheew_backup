class ParkingSessionModel {
  final String? id;
  final String? userId;
  final String? spotId;
  final double? latitude;
  final double? longitude;
  final String? costType;
  final int? durationMin;
  final String? expiresAt;
  final String? expiryWarningSentAt;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final String? googleMapsWalkingLink;


  ParkingSessionModel({
    this.id,
    this.userId,
    this.spotId,
    this.latitude,
    this.longitude,
    this.costType,
    this.durationMin,
    this.expiresAt,
    this.expiryWarningSentAt,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.googleMapsWalkingLink,
  });

  factory ParkingSessionModel.fromJson(Map<String, dynamic> json) {
    return ParkingSessionModel(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      spotId: json['spotId']?.toString(),
      latitude: json['latitude'] is num
          ? (json['latitude'] as num).toDouble()
          : double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: json['longitude'] is num
          ? (json['longitude'] as num).toDouble()
          : double.tryParse(json['longitude']?.toString() ?? ''),
      costType: json['costType']?.toString(),
      durationMin: json['durationMin'] is int
          ? json['durationMin']
          : int.tryParse(json['durationMin']?.toString() ?? ''),
      expiresAt: json['expiresAt']?.toString(),
      expiryWarningSentAt: json['expiryWarningSentAt']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      googleMapsWalkingLink: json['googleMapsWalkingLink']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'spotId': spotId,
      'latitude': latitude,
      'longitude': longitude,
      'costType': costType,
      'durationMin': durationMin,
      'expiresAt': expiresAt,
      'expiryWarningSentAt': expiryWarningSentAt,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'googleMapsWalkingLink': googleMapsWalkingLink,
    };
  }
}

class SavedParkingModel {
  final String? id;
  final String? userId;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final double? confidence;
  final String? source;
  final String? createdAt;
  final String? updatedAt;
  final String? googleMapsWalkingLink;
  final String? costType;
  final int? durationMin;
  final String? expiresAt;
  final ParkingSessionModel? parkingSession;

  SavedParkingModel({
    this.id,
    this.userId,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.confidence,
    this.source,
    this.createdAt,
    this.updatedAt,
    this.googleMapsWalkingLink,
    this.costType,
    this.durationMin,
    this.expiresAt,
    this.parkingSession,
  });

  factory SavedParkingModel.fromJson(Map<String, dynamic> json) {
    return SavedParkingModel(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      latitude: json['latitude'] is num
          ? (json['latitude'] as num).toDouble()
          : double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: json['longitude'] is num
          ? (json['longitude'] as num).toDouble()
          : double.tryParse(json['longitude']?.toString() ?? ''),
      accuracy: json['accuracy'] is num
          ? (json['accuracy'] as num).toDouble()
          : double.tryParse(json['accuracy']?.toString() ?? ''),
      confidence: json['confidence'] is num
          ? (json['confidence'] as num).toDouble()
          : double.tryParse(json['confidence']?.toString() ?? ''),
      source: json['source']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      googleMapsWalkingLink: json['googleMapsWalkingLink']?.toString(),
      costType: json['costType']?.toString(),
      durationMin: json['durationMin'] is int
          ? json['durationMin']
          : int.tryParse(json['durationMin']?.toString() ?? ''),
      expiresAt: json['expiresAt']?.toString(),
      parkingSession: json['parkingSession'] != null && json['parkingSession'] is Map
          ? ParkingSessionModel.fromJson(Map<String, dynamic>.from(json['parkingSession']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'confidence': confidence,
      'source': source,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'googleMapsWalkingLink': googleMapsWalkingLink,
      'costType': costType,
      'durationMin': durationMin,
      'expiresAt': expiresAt,
      'parkingSession': parkingSession?.toJson(),
    };
  }
}
