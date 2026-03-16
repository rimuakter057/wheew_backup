import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:platchatapp/core/service/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_const/app_const.dart';
import 'api_url.dart';

class ApiClient {
  /// Check internet connection
  static Future<bool> _checkConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return true; // Continue if connectivity check fails
    }
  }

  /// GET Token from SharedPreferences
  static Future<String?> _getToken() async {
    return await SharePrefsHelper.getString(AppConst.token);
  }

  /// POST Request with full console logging
  static Future<http.Response> postData({
    required String uri,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    // Check internet first
    if (!await _checkConnection()) {
      developer.log('❌ No Internet Connection', name: 'API');
      throw Exception('No Internet Connection');
    }

    final url = Uri.parse(ApiUrl.baseUrl + uri);
    final token = await _getToken();

    // Merge headers with token
    final finalHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
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
      final response = await http
          .post(url, headers: finalHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      // 📥 LOG RESPONSE
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      developer.log('📥 API RESPONSE', name: 'API');
      developer.log('Status Code: ${response.statusCode}', name: 'API');
      developer.log(
        'Status: ${_getStatusMessage(response.statusCode)}',
        name: 'API',
      );
      developer.log('Headers: ${response.headers}', name: 'API');

      // Pretty print response body
      try {
        final prettyJson = JsonEncoder.withIndent(
          '  ',
        ).convert(jsonDecode(response.body));
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
    // Check internet first
    if (!await _checkConnection()) {
      developer.log('❌ No Internet Connection', name: 'API');
      throw Exception('No Internet Connection');
    }

    var url = Uri.parse(ApiUrl.baseUrl + uri);
    final token = await _getToken();

    if (queryParams != null && queryParams.isNotEmpty) {
      url = url.replace(queryParameters: queryParams);
    }

    // Merge headers with token
    final finalHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
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
      final response = await http
          .get(url, headers: finalHeaders)
          .timeout(const Duration(seconds: 30));

      // 📥 LOG RESPONSE
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      developer.log('URL: $url', name: 'API');
      developer.log('📥 API RESPONSE', name: 'API');
      developer.log('Status Code: ${response.statusCode}', name: 'API');
      developer.log(
        'Status: ${_getStatusMessage(response.statusCode)}',
        name: 'API',
      );

      try {
        final prettyJson = JsonEncoder.withIndent(
          '  ',
        ).convert(jsonDecode(response.body));
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

  /// PUT Request
  static Future<http.Response> putData({
    required String uri,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    if (!await _checkConnection()) {
      throw Exception('No Internet Connection');
    }

    final url = Uri.parse(ApiUrl.baseUrl + uri);
    final token = await _getToken();

    final finalHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    developer.log('📤 PUT REQUEST', name: 'API');
    developer.log('URL: $url', name: 'API');
    developer.log('Body: ${jsonEncode(body)}', name: 'API');
    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final response = await http
          .put(url, headers: finalHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      developer.log('📥 PUT RESPONSE: ${response.statusCode}', name: 'API');
      return response;
    } catch (e, stackTrace) {
      developer.log('❌ PUT ERROR: $e', name: 'API');
      developer.log('StackTrace: $stackTrace', name: 'API');
      rethrow;
    }
  }


  ///============================= PATCH REQUEST ================================
  static Future<http.Response> patchData({
    required String uri,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool isJson = true,
  }) async {
    // Check internet
    if (!await _checkConnection()) {
      throw Exception('No Internet Connection');
    }

    // Get bearer token
    final sharedPreferences = await SharedPreferences.getInstance();
    final bearerToken = sharedPreferences.getString(AppConst.token) ?? '';

    // Prepare headers
    final mainHeaders = isJson
        ? {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $bearerToken',
          }
        : {
            'Accept': 'application/json',
            'Authorization': 'Bearer $bearerToken',
          };

    try {
      // Log request
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      developer.log('📤 PATCH REQUEST', name: 'API');
      developer.log('URL: ${ApiUrl.baseUrl + uri}', name: 'API');
      developer.log('Headers: ${headers ?? mainHeaders}', name: 'API');
      developer.log('Body: ${jsonEncode(body)}', name: 'API');
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Send PATCH request
      final response = await http
          .patch(
            Uri.parse(ApiUrl.baseUrl + uri),
            headers: headers ?? mainHeaders,
            body: isJson ? jsonEncode(body) : body,
          )
          .timeout(const Duration(seconds: 30));

      // Log response
      developer.log('📥 PATCH RESPONSE: ${response.statusCode}', name: 'API');
      try {
        final prettyJson = JsonEncoder.withIndent(
          '  ',
        ).convert(jsonDecode(response.body));
        developer.log('Response Body:\n$prettyJson', name: 'API');
      } catch (e) {
        developer.log('Response Body (raw): ${response.body}', name: 'API');
      }
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return response;
    } catch (e, stackTrace) {
      developer.log('❌ PATCH ERROR: $e', name: 'API');
      developer.log('StackTrace: $stackTrace', name: 'API');
      rethrow;
    }
  }

  /// DELETE Request
  static Future<Map<String, dynamic>> deleteData({
    required String uri,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {

    if (!await _checkConnection()) {
      return {
        "statusCode": 0,
        "data": {"message": "No Internet Connection"}
      };
    }

    final url = Uri.parse(ApiUrl.baseUrl + uri);
    final token = await _getToken();

    final finalHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    developer.log('🗑️ DELETE REQUEST', name: 'API');
    developer.log('URL: $url', name: 'API');
    developer.log('BODY: $body', name: 'API');
    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {

      final response = await http
          .delete(
        url,
        headers: finalHeaders,
        body: body != null ? jsonEncode(body) : null,
      )
          .timeout(const Duration(seconds: 30));

      developer.log('📥 DELETE RESPONSE: ${response.statusCode}', name: 'API');
      developer.log('BODY: ${response.body}', name: 'API');

      final data = jsonDecode(response.body);

      return {
        "statusCode": response.statusCode,
        "data": data,
      };

    } on TimeoutException {

      return {
        "statusCode": 408,
        "data": {"message": "Request Timeout"}
      };

    } on FormatException {

      return {
        "statusCode": 500,
        "data": {"message": "Invalid server response"}
      };

    } catch (e) {

      developer.log('❌ DELETE ERROR: $e', name: 'API');

      return {
        "statusCode": 500,
        "data": {"message": "Something went wrong"}
      };

    }
  }


  /// Multipart Request (for file uploads)
  static Future<http.Response> multipartRequest({
    required String uri,
    required String method,
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
  }) async {
    if (!await _checkConnection()) {
      throw Exception('No Internet Connection');
    }

    final url = Uri.parse(ApiUrl.baseUrl + uri);
    final token = await _getToken();

    var request = http.MultipartRequest(method, url);

    // Add headers
    request.headers['Accept'] = 'application/json';
    if (token != null && token.isNotEmpty) {
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
    developer.log('📤 MULTIPART REQUEST', name: 'API');
    developer.log('Method: $method', name: 'API');
    developer.log('URL: $url', name: 'API');
    developer.log('Headers: ${request.headers}', name: 'API');
    developer.log('Fields: ${request.fields}', name: 'API');
    developer.log(
      'Files: ${files?.map((f) => f.filename).toList()}',
      name: 'API',
    );
    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // 📥 LOG RESPONSE
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      developer.log('📥 MULTIPART RESPONSE', name: 'API');
      developer.log('Status Code: ${response.statusCode}', name: 'API');
      developer.log(
        'Status: ${_getStatusMessage(response.statusCode)}',
        name: 'API',
      );

      try {
        final prettyJson = JsonEncoder.withIndent(
          '  ',
        ).convert(jsonDecode(response.body));
        developer.log('Response Body:\n$prettyJson', name: 'API');
      } catch (e) {
        developer.log('Response Body (raw): ${response.body}', name: 'API');
      }
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return response;
    } catch (e, stackTrace) {
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      developer.log('❌ MULTIPART ERROR', name: 'API');
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
}
