import 'package:platchatapp/core/service/api_url.dart';

class UserDocument {
  final String id;
  final String uniqueId;
  final String documentType;
  final String documentUrl;
  final String expiryDate;
  final bool isExpired;
  final int daysUntilExpiry;

  UserDocument({
    required this.id,
    required this.uniqueId,
    required this.documentType,
    required this.documentUrl,
    required this.expiryDate,
    required this.isExpired,
    required this.daysUntilExpiry,
  });

  /// Normalised for routing (LICENSE | INSURANCE | TAX).
  String get typeKey => documentType.toUpperCase().trim();

  /// Absolute URL for opening the stored file in the browser / viewer.
  String get resolvedDocumentUrl {
    final u = documentUrl.trim();
    if (u.isEmpty) return '';
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    final base = ApiUrl.baseUrl.endsWith('/')
        ? ApiUrl.baseUrl.substring(0, ApiUrl.baseUrl.length - 1)
        : ApiUrl.baseUrl;
    final path = u.startsWith('/') ? u : '/$u';
    return '$base$path';
  }

  factory UserDocument.fromJson(Map<String, dynamic> json) {
    final type = (json['document_type'] ?? json['documentType'] ?? '')
        .toString()
        .trim();
    final expired = json['isExpired'] ??
        json['is_expired'] ??
        json['expired'] ??
        false;

    int days = 0;
    final rawDays = json['daysUntilExpiry'] ?? json['days_until_expiry'];
    if (rawDays is int) {
      days = rawDays;
    } else if (rawDays is num) {
      days = rawDays.toInt();
    }

    return UserDocument(
      id: '${json['id'] ?? ''}',
      uniqueId: '${json['unique_id'] ?? json['uniqueId'] ?? ''}',
      documentType: type,
      documentUrl: '${json['document_url'] ?? json['documentUrl'] ?? ''}',
      expiryDate: '${json['expiry_date'] ?? json['expiryDate'] ?? ''}',
      isExpired: expired == true || expired == 1 || expired == 'true',
      daysUntilExpiry: days,
    );
  }
}