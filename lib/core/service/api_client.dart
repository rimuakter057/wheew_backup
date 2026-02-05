import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'api_url.dart';

class ApiClient {
  /// GET Token from storage
  static String? _getToken() {
    final storage = GetStorage();
    return storage.read('token');
  }

  /// POST Request with full console logging
  static Future<http.Response> postData({
    required String uri,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse(ApiUrl.baseUrl + uri);
    final token = _getToken();

    // Merge headers with token
    final finalHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    // 📤 LOG REQUEST
    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    developer.log('📤 API REQUEST', name: 'API');
    developer.log('Method: POST', name: 'API');
    developer.log('URL: $url', name: 'API');
    developer.log('Headers: $finalHeaders', name: 'API');
    developer.log('Body: ${jsonEncode(body)}', name: 'API');
    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final response = await http.post(
        url,
        headers: finalHeaders,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      // 📥 LOG RESPONSE
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      developer.log('📥 API RESPONSE', name: 'API');
      developer.log('Status Code: ${response.statusCode}', name: 'API');
      developer.log('Status: ${_getStatusMessage(response.statusCode)}', name: 'API');
      developer.log('Headers: ${response.headers}', name: 'API');

      // Pretty print response body
      try {
        final prettyJson = JsonEncoder.withIndent('  ').convert(jsonDecode(response.body));
        developer.log('Response Body:\n$prettyJson', name: 'API');
      } catch (e) {
        developer.log('Response Body (raw): ${response.body}', name: 'API');
      }
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return response;
    } catch (e, stackTrace) {
      // ❌ LOG ERROR
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      developer.log('❌ API ERROR', name: 'API');
      developer.log('URL: $url', name: 'API');
      developer.log('Error: $e', name: 'API');
      developer.log('StackTrace: $stackTrace', name: 'API');
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      rethrow;
    }
  }

  /// GET Request with full console logging
  static Future<http.Response> getData({
    required String uri,
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    var url = Uri.parse(ApiUrl.baseUrl + uri);
    final token = _getToken();

    if (queryParams != null && queryParams.isNotEmpty) {
      url = url.replace(queryParameters: queryParams);
    }

    // Merge headers with token
    final finalHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    // 📤 LOG REQUEST
    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    developer.log('📤 API REQUEST', name: 'API');
    developer.log('Method: GET', name: 'API');
    developer.log('URL: $url', name: 'API');
    developer.log('Headers: $finalHeaders', name: 'API');
    if (queryParams != null) {
      developer.log('Query Params: $queryParams', name: 'API');
    }
    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final response = await http.get(
        url,
        headers: finalHeaders,
      ).timeout(const Duration(seconds: 30));

      // 📥 LOG RESPONSE
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      developer.log('📥 API RESPONSE', name: 'API');
      developer.log('Status Code: ${response.statusCode}', name: 'API');
      developer.log('Status: ${_getStatusMessage(response.statusCode)}', name: 'API');

      try {
        final prettyJson = JsonEncoder.withIndent('  ').convert(jsonDecode(response.body));
        developer.log('Response Body:\n$prettyJson', name: 'API');
      } catch (e) {
        developer.log('Response Body (raw): ${response.body}', name: 'API');
      }
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return response;
    } catch (e, stackTrace) {
      // ❌ LOG ERROR
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      developer.log('❌ API ERROR', name: 'API');
      developer.log('URL: $url', name: 'API');
      developer.log('Error: $e', name: 'API');
      developer.log('StackTrace: $stackTrace', name: 'API');
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      rethrow;
    }
  }

  /// Helper to get status message
  static String _getStatusMessage(int statusCode) {
    switch (statusCode) {
      case 200:
        return '✅ OK';
      case 201:
        return '✅ Created';
      case 400:
        return '❌ Bad Request';
      case 401:
        return '❌ Unauthorized';
      case 403:
        return '❌ Forbidden';
      case 404:
        return '❌ Not Found';
      case 422:
        return '❌ Validation Error';
      case 500:
        return '❌ Server Error';
      default:
        return statusCode >= 200 && statusCode < 300 ? '✅ Success' : '❌ Error';
    }
  }
  /// Multipart Request with full console logging (for file uploads)
  static Future<http.Response> multipartRequest({
    required String uri,
    required String method,
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
  }) async {
    final url = Uri.parse(ApiUrl.baseUrl + uri);
    final token = _getToken();

    var request = http.MultipartRequest(method, url);

    // Add headers
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add fields
    if (fields != null) {
      request.fields.addAll(fields);
    }

    // Add files
    if (files != null) {
      request.files.addAll(files);
    }

    // 📤 LOG REQUEST
    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    developer.log('📤 API REQUEST (MULTIPART)', name: 'API');
    developer.log('Method: $method', name: 'API');
    developer.log('URL: $url', name: 'API');
    developer.log('Headers: ${request.headers}', name: 'API');
    developer.log('Fields: ${request.fields}', name: 'API');
    developer.log('Files: ${files?.map((f) => f.filename).toList()}', name: 'API');
    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // 📥 LOG RESPONSE
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      developer.log('📥 API RESPONSE', name: 'API');
      developer.log('Status Code: ${response.statusCode}', name: 'API');
      developer.log('Status: ${_getStatusMessage(response.statusCode)}', name: 'API');

      try {
        final prettyJson = JsonEncoder.withIndent('  ').convert(jsonDecode(response.body));
        developer.log('Response Body:\n$prettyJson', name: 'API');
      } catch (e) {
        developer.log('Response Body (raw): ${response.body}', name: 'API');
      }
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return response;
    } catch (e, stackTrace) {
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      developer.log('❌ API ERROR', name: 'API');
      developer.log('URL: $url', name: 'API');
      developer.log('Error: $e', name: 'API');
      developer.log('StackTrace: $stackTrace', name: 'API');
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      rethrow;
    }
  }


}