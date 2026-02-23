import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ApiChecker {
  static void checkApi(Response response, BuildContext context) {
    // Log the check
    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    developer.log('🔍 API CHECKER', name: 'API');
    developer.log('Status Code: ${response.statusCode}', name: 'API');

    if (response.statusCode == 200 || response.statusCode == 201) {
      developer.log('✅ Success - No error handling needed', name: 'API');
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return;
    }

    String errorMessage = 'Something went wrong';

    if (response.statusCode == 401) {
      errorMessage = '🔒 Unauthorized - Please login again';
      developer.log('❌ $errorMessage', name: 'API');
      _showSnackBar(context, errorMessage);
    } else if (response.statusCode == 400) {
      try {
        final body = jsonDecode(response.body);
        errorMessage = body['message'] ?? '❌ Bad request';
        developer.log('❌ Bad Request: $errorMessage', name: 'API');
        developer.log('Response: ${response.body}', name: 'API');
      } catch (e) {
        errorMessage = '❌ Bad request';
        developer.log('❌ Bad Request (parse error): $e', name: 'API');
      }
      _showSnackBar(context, errorMessage);
    } else if (response.statusCode == 404) {
      errorMessage = '🔍 Resource not found';
      developer.log('❌ 404 Not Found', name: 'API');
      developer.log(
        'URL might be incorrect or endpoint doesn\'t exist',
        name: 'API',
      );
      developer.log('Response: ${response.body}', name: 'API');
      _showSnackBar(context, errorMessage);
    } else if (response.statusCode == 422) {
      try {
        final body = jsonDecode(response.body);
        errorMessage = '❌ Validation failed';

        // Laravel-style validation errors
        if (body['errors'] != null && body['errors'] is Map) {
          final errors = body['errors'] as Map<String, dynamic>;
          developer.log('Validation Errors:', name: 'API');
          errors.forEach((key, value) {
            developer.log('  - $key: $value', name: 'API');
          });

          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError.first.toString();
          } else if (firstError is String) {
            errorMessage = firstError;
          }
        } else if (body['message'] != null) {
          errorMessage = body['message'];
        }

        developer.log('❌ Validation Error: $errorMessage', name: 'API');
      } catch (e) {
        developer.log('❌ Validation Error (parse error): $e', name: 'API');
      }
      _showSnackBar(context, errorMessage);
    } else if (response.statusCode == 500) {
      errorMessage = '🔥 Internal server error';
      developer.log('❌ 500 Server Error', name: 'API');
      developer.log('Response: ${response.body}', name: 'API');
      _showSnackBar(context, errorMessage);
    } else {
      try {
        final body = jsonDecode(response.body);
        errorMessage = body['message'] ?? 'Error ${response.statusCode}';
        developer.log(
          '❌ Error ${response.statusCode}: $errorMessage',
          name: 'API',
        );
        developer.log('Response: ${response.body}', name: 'API');
      } catch (e) {
        errorMessage = 'Error ${response.statusCode}';
        developer.log(
          '❌ Error ${response.statusCode} (parse error)',
          name: 'API',
        );
      }
      _showSnackBar(context, errorMessage);
    }

    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Get error message from exception
  static String getErrorMessage(dynamic error) {
    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    developer.log('⚠️ EXCEPTION HANDLER', name: 'API');
    developer.log('Error Type: ${error.runtimeType}', name: 'API');
    developer.log('Error: $error', name: 'API');
    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (error.toString().contains('SocketException')) {
      return '📡 No internet connection. Please check your network.';
    } else if (error.toString().contains('TimeoutException')) {
      return '⏱️ Request timeout. Please try again.';
    } else if (error.toString().contains('HandshakeException')) {
      return '🔒 SSL certificate error. Check your connection.';
    } else if (error.toString().contains('FormatException')) {
      return '📝 Invalid response format from server.';
    } else if (error.toString().contains('Exception:')) {
      return error.toString().replaceAll('Exception:', '').trim();
    } else {
      return '❌ Something went wrong. Please try again.';
    }
  }
}
