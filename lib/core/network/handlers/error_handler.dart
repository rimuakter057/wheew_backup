// import 'dart:async';
// import 'dart:io';
//
// import '../exceptions/api_exception.dart';
// import '../interceptors/network_logger.dart';
//
//
// class ErrorHandler {
//   ErrorHandler._();
//
//   // ✅ Convert any exception → ApiResponse
//   static ApiResponse handle(dynamic error, String url, String method) {
//     NetworkLogger.logError(method: method, url: url, error: error);
//
//     // No Internet
//     if (error is SocketException) {
//       return const ApiResponse(
//         statusCode: 0,
//         status: ApiStatus.internetError,
//         errorMessage: 'No internet connection. Please check your network.',
//       );
//     }
//
//     // Timeout
//     if (error is TimeoutException) {
//       return const ApiResponse(
//         statusCode: 408,
//         status: ApiStatus.error,
//         errorMessage: 'Request timed out. Please try again.',
//       );
//     }
//
//     // SSL / secure connection issue
//     if (error is HandshakeException) {
//       return const ApiResponse(
//         statusCode: 0,
//         status: ApiStatus.error,
//         errorMessage: 'Secure connection failed. Please try again.',
//       );
//     }
//
//     // HTTP exception
//     if (error is HttpException) {
//       return ApiResponse(
//         statusCode: 500,
//         status: ApiStatus.error,
//         errorMessage: error.message.isNotEmpty
//             ? error.message
//             : 'Something went wrong while contacting the server.',
//       );
//     }
//
//     // Format exception
//     if (error is FormatException) {
//       NetworkLogger.logWarning('Response format error: ${error.message}');
//       return const ApiResponse(
//         statusCode: 500,
//         status: ApiStatus.error,
//         errorMessage: 'Invalid response format from server.',
//       );
//     }
//
//     // Custom ApiException
//     if (error is ApiException) {
//       return ApiResponse(
//         statusCode: error.statusCode ?? 0,
//         status: ApiStatus.error,
//         errorMessage: error.message,
//       );
//     }
//
//     // http package's ClientException (connection reset etc.)
//     final text = error.toString();
//     if (text.contains('ClientException')) {
//       return const ApiResponse(
//         statusCode: 0,
//         status: ApiStatus.internetError,
//         errorMessage: 'Connection lost. Please check your internet and try again.',
//       );
//     }
//
//     // Unknown
//     return ApiResponse(
//       statusCode: 1,
//       status: ApiStatus.error,
//       errorMessage: text.isNotEmpty && text != 'null'
//           ? 'An unexpected error occurred: $text'
//           : 'An unexpected error occurred.',
//     );
//   }
//
//   // ✅ Convert statusCode → ApiResponse with proper status & message
//   static ApiResponse fromStatusCode(int statusCode, dynamic body, String reasonPhrase) {
//     switch (statusCode) {
//       case 200:
//       case 201:
//       case 204:
//         return ApiResponse(
//           statusCode: statusCode,
//           body: body,
//           status: ApiStatus.completed,
//           statusText: reasonPhrase,
//         );
//
//       case 400:
//         final msg = _extractMessage(body) ?? 'Bad request.';
//         NetworkLogger.logWarning('400 Bad Request: $msg');
//         return ApiResponse(
//           statusCode: 400,
//           body: body,
//           status: ApiStatus.error,
//           errorMessage: msg,
//         );
//
//       case 401:
//         final msg = _extractMessage(body) ?? 'Session expired. Please log in again.';
//         NetworkLogger.logWarning('401 Unauthorized: $msg');
//         return ApiResponse(
//           statusCode: 401,
//           body: body,
//           status: ApiStatus.error,
//           errorMessage: msg,
//         );
//
//       case 403:
//         NetworkLogger.logWarning('403 Forbidden.');
//         return ApiResponse(
//           statusCode: 403,
//           body: body,
//           status: ApiStatus.error,
//           errorMessage: 'You do not have permission to perform this action.',
//         );
//
//       case 404:
//         NetworkLogger.logWarning('404 Not Found.');
//         return ApiResponse(
//           statusCode: 404,
//           body: body,
//           status: ApiStatus.noDataFound,
//           errorMessage: 'The requested resource was not found.',
//         );
//
//       case 408:
//         return const ApiResponse(
//           statusCode: 408,
//           status: ApiStatus.error,
//           errorMessage: 'Request timed out.',
//         );
//
//       case 422:
//         final msg = _extractMessage(body) ?? 'Validation failed.';
//         NetworkLogger.logWarning('422 Unprocessable: $msg');
//         return ApiResponse(
//           statusCode: 422,
//           body: body,
//           status: ApiStatus.error,
//           errorMessage: msg,
//         );
//
//       case 429:
//         return const ApiResponse(
//           statusCode: 429,
//           status: ApiStatus.error,
//           errorMessage: 'Too many requests. Please slow down.',
//         );
//
//       case 500:
//       case 502:
//       case 503:
//       case 504:
//         NetworkLogger.logError(
//           method: 'SERVER',
//           url: '',
//           error: 'Server error $statusCode',
//         );
//         return ApiResponse(
//           statusCode: statusCode,
//           body: body,
//           status: ApiStatus.error,
//           errorMessage: 'Server error. Please try again later.',
//         );
//
//       default:
//         return ApiResponse(
//           statusCode: statusCode,
//           body: body,
//           status: ApiStatus.error,
//           errorMessage: 'Unexpected error (code: $statusCode).', message: '',
//         );
//     }
//   }
//
//   // ✅ Extract message safely from response body
//   static String? _extractMessage(dynamic body) {
//     if (body is Map) {
//       final candidate = body['message'] ?? body['error'] ?? body['msg'];
//       if (candidate is String && candidate.trim().isNotEmpty) return candidate;
//       final errors = body['errors'];
//       if (errors is Map && errors.isNotEmpty) {
//         final firstValue = errors.values.first;
//         if (firstValue is List && firstValue.isNotEmpty) return firstValue.first.toString();
//         if (firstValue is String) return firstValue;
//       }
//     }
//     return null;
//   }
// }