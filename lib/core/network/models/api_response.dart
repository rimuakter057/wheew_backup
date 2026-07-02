/// Clear, user-understandable categories for every possible API outcome.
/// UI code should branch on [status], not on raw HTTP codes, so behavior
/// (retry button, login redirect, snackbar color, etc.) stays consistent.
enum ApiStatus {
  success,
  noInternet,
  timeout,
  unauthorized, // 401 -> session expired, needs re-login
  forbidden, // 403 -> no permission
  notFound, // 404
  validationError, // 400 / 422
  rateLimited, // 429
  serverError, // 5xx
  unknown, error, // anything else / unexpected
}

class ApiResponse<T> {
  final int statusCode;
  final ApiStatus status;
  final T? body;
  final String? bodyString;

  /// Always a safe, human-readable message you can show directly in a
  /// Snackbar/Dialog. Never null — falls back to a generic message.
  final String message;

  /// Raw HTTP reason phrase (e.g. "OK", "Not Found"), kept separately from
  /// [message] so the two are never confused again.
  final String? reasonPhrase;
  final Map<String, String>? headers;

  const ApiResponse({
    required this.statusCode,
    required this.status,
    required this.message,
    this.body,
    this.bodyString,
    this.reasonPhrase,
    this.headers,
  });

  bool get isSuccess => status == ApiStatus.success;
  bool get isUnauthorized => status == ApiStatus.unauthorized;
  bool get hasNoInternet => status == ApiStatus.noInternet;
  bool get isTimeout => status == ApiStatus.timeout;
  bool get isServerError => status == ApiStatus.serverError;

  @override
  String toString() =>
      'ApiResponse(status: $status, statusCode: $statusCode, message: $message)';
}