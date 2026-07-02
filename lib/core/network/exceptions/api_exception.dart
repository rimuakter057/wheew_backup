class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NoInternetException extends ApiException {
  const NoInternetException()
      : super(message: 'No internet connection. Please check your network.');
}

// NOTE: renamed from `TimeoutException` -> `RequestTimeoutException`.
// `dart:async` already exports a class called `TimeoutException`, so having
// a same-named class here caused an ambiguous-import compile error anywhere
// both were imported unqualified.
class RequestTimeoutException extends ApiException {
  const RequestTimeoutException()
      : super(message: 'Request timed out. Please try again.', statusCode: 408);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Your session has expired. Please log in again.',
  }) : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'You do not have permission to perform this action.',
  }) : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
  }) : super(statusCode: 404);
}

class BadRequestException extends ApiException {
  const BadRequestException({
    required super.message,
    super.statusCode = 400,
  });
}

class ValidationException extends ApiException {
  const ValidationException({
    super.message = 'Validation failed. Please check your input.',
  }) : super(statusCode: 422);
}

class RateLimitedException extends ApiException {
  const RateLimitedException({
    super.message = 'Too many requests. Please slow down and try again.',
  }) : super(statusCode: 429);
}

class ServerException extends ApiException {
  const ServerException({
    super.message = 'Server error. Please try again later.',
    super.statusCode,
  });
}