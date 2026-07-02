import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data'; // ← এটা add করো file এর top এ

import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:logger/logger.dart';
import 'package:platchatapp/core/service/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_const/app_const.dart';
import 'api_url.dart';


class ApiService extends GetxService {
  static var client = http.Client();
  static final Logger logger = Logger();

  // static const String somethingWentWrong = "Something Went Wrong";
  static const int timeoutInSeconds = 30;

  static String bearerToken = "";

  static String _parseError(dynamic e) {

    if (e is SocketException) return 'No internet connection. Please check your network.';
    if (e is TimeoutException) return 'Request timed out. Please try again.';
    if (e is FormatException) return 'Invalid response format from server.';
    if (e is HandshakeException) return 'Secure connection failed. Please try again.';

    String errorMsg = e.toString();
    if (errorMsg.contains('ClientException')) {
      return 'Network connection problem: ${errorMsg.replaceAll('ClientException: ', '')}';
    }
    if (errorMsg.contains('ClientException')) {
      return 'Connection lost. Please check your internet and try again.';  // ← simple message
    }
    return errorMsg.isNotEmpty ? errorMsg : 'An unexpected error occurred.';
  }

  //============================= CHECK INTERNET =============================
  static Future<bool> _checkConnection() async {
    return await Connectivity().checkConnectivity() != ConnectivityResult.none;
  }

  //============================= POST REQUEST ================================
  static Future<Response> postData(
      String uri,
      dynamic body, {
        Map<String, String>? headers,
        bool isJson = true,
        bool isAuthRequired = true,
      }) async
  {
    if (!await _checkConnection()) {
      return const Response(
        statusCode: 0,
        statusText: 'No Internet Connection',
      );
    }

    String? bearerToken = isAuthRequired
        ? await SharePrefsHelper.getString(AppConst.token)
        : null;

    var mainHeaders = isJson
        ? {
      'Content-Type': 'application/json',
      'Authorization': "Bearer $bearerToken",
      'x-timezone': DateTime.now().timeZoneName,
      'x-utc-offset-minutes': DateTime.now().timeZoneOffset.inMinutes.toString(),
    }
        : {
      'Accept': 'application/json',
      'Authorization': "Bearer $bearerToken",
      'x-timezone': DateTime.now().timeZoneName,
      'x-utc-offset-minutes': DateTime.now().timeZoneOffset.inMinutes.toString(),
    };

    try {
      logger.i(
        "User Create POST REQUEST==========================================\nURL:======================================= $uri\nHeaders:=================================== ${headers ?? mainHeaders}\nBody:================================================== $body",
      );

      http.Response response = await client
          .post(
        Uri.parse(ApiUrl.baseUrl + uri),
        body: isJson ? jsonEncode(body) : body,
        headers: headers ?? mainHeaders,
      )
          .timeout(const Duration(seconds: timeoutInSeconds));

      ///server response here===================================================================
      return handleResponse(response, uri);
    } catch (e) {
      logger.e(
        "❌ POST Error server:================================================ $e",
      );
      return  Response(statusCode: 1, statusText: _parseError(e));
    }
  }

  //============================= GET REQUEST ================================
  static Future<Response> getData(
      String uri, {
        Map<String, String>? headers,
      }) async
  {
    if (!await _checkConnection()) {
      return const Response(
        statusCode: 0,
        statusText: 'No Internet Connection',
      );
    }

    bearerToken = await SharePrefsHelper.getString(AppConst.token);

    var mainHeaders = {
      'Accept': 'application/json',
      'Authorization': "Bearer $bearerToken",
      'x-timezone': DateTime.now().timeZoneName,
      'x-utc-offset-minutes': DateTime.now().timeZoneOffset.inMinutes.toString(),
    };

    try {
      logger.i(
        "➡️ GET REQUEST=====================================\nURL:===================================== $uri\nHeaders:=========================================== ${headers ?? mainHeaders}",
      );

      http.Response response = await client
          .get(Uri.parse(ApiUrl.baseUrl + uri), headers: headers ?? mainHeaders)
          .timeout(const Duration(seconds: timeoutInSeconds));

      return handleResponse(response, uri);
    } catch (e) {
      logger.e("❌ GET Error:==================================== $e");

      Get.snackbar(
        'Connection Error',
        _parseError(e),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      return Response(statusCode: 1, statusText: _parseError(e));
    }
  }

  //============================= PATCH REQUEST ================================
  static Future<Response> patchData(
      String uri,
      dynamic body, {
        Map<String, String>? headers,
        bool isJson = true,
      }) async
  {
    if (!await _checkConnection()) {
      return const Response(
        statusCode: 0,
        statusText: 'No Internet Connection',
      );
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    bearerToken = (sharedPreferences.getString(AppConst.token))!;

    var mainHeaders = isJson
        ? {
      'Content-Type': 'application/json',
      'Authorization': "Bearer $bearerToken",
      'x-timezone': DateTime.now().timeZoneName,
      'x-utc-offset-minutes': DateTime.now().timeZoneOffset.inMinutes.toString(),
    }
        : {
      'Accept': 'application/json',
      'Authorization': "Bearer $bearerToken",
      'x-timezone': DateTime.now().timeZoneName,
      'x-utc-offset-minutes': DateTime.now().timeZoneOffset.inMinutes.toString(),
    };

    try {
      logger.i(
        "➡️ PATCH REQUEST===============================================\nURL:=============================================== $uri\nHeaders:========================================== ${headers ?? mainHeaders}\nBody:================================== $body",
      );

      http.Response response = await client
          .patch(
        Uri.parse(ApiUrl.baseUrl + uri),
        body: isJson ? jsonEncode(body) : body,
        headers: headers ?? mainHeaders,
      )
          .timeout(const Duration(seconds: timeoutInSeconds));

      return handleResponse(response, uri);
    } catch (e) {
      logger.e("❌ PATCH Error:============================================================== $e");
      return Response(statusCode: 1, statusText: _parseError(e));
    }
  }

  ///=========================multipart patch===================================================================

  static Future<Response> patchMultipartData(
      String uri,
      Map<String, String> body, {
        List<MultipartBody>? multipartBody,
        Map<String, String>? headers,
      }) async
  {
    try {
      bearerToken = await SharePrefsHelper.getString(AppConst.token);

      var mainHeaders = {
        'Accept': 'application/json',
        'Authorization': "Bearer $bearerToken",
        'x-timezone': DateTime.now().timeZoneName,
        'x-utc-offset-minutes': DateTime.now().timeZoneOffset.inMinutes.toString(),
      };

      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse(ApiUrl.baseUrl + uri),
      );

      request.fields.addAll(body);

      if (multipartBody != null && multipartBody.isNotEmpty) {
        for (var element in multipartBody) {
          var mimeType =
              lookupMimeType(element.file.path) ?? 'application/octet-stream';
          var multipartImg = await http.MultipartFile.fromPath(
            element.key,
            element.file.path,
            contentType: MediaType.parse(mimeType),
          );
          request.files.add(multipartImg);
        }
      }

      request.headers.addAll(mainHeaders);

      var streamedResponse = await request.send();
      final responseString = await streamedResponse.stream.bytesToString();

      debugPrint(
        '====> API Response [${streamedResponse.statusCode}]: $uri\n$responseString',
      );

      return Response(
        statusCode: streamedResponse.statusCode,
        body: jsonDecode(responseString),
      );
    } catch (e) {
      debugPrint('Multipart PATCH Error: $e');
      return Response(
        statusCode: 500,
        body: {"chat": _parseError(e)},
      );
    }
  }

  //============================= MULTIPART POST ================================
  static Future<Response> postMultipartData(
      String uri,
      Map<String, String> body, {
        List<MultipartBody>? multipartBody,
      }) async
  {
    try {
      bearerToken = await SharePrefsHelper.getString(AppConst.token);

      var headers = {
        'Accept': 'application/json',
        'Authorization': "Bearer $bearerToken",
        'x-timezone': DateTime.now().timeZoneName,
        'x-utc-offset-minutes': DateTime.now().timeZoneOffset.inMinutes.toString(),
      };

      var request = http.MultipartRequest(
        "POST",
        Uri.parse(ApiUrl.baseUrl + uri),
      );

      request.fields.addAll(body);
      request.headers.addAll(headers);

      logger.i(
        "➡️ MULTIPART POST==============================================================================\nURL:======================================================================== $uri\nBody Fields:============================================================= $body",
      );

      // Attach Files
      if (multipartBody != null) {
        for (var element in multipartBody) {
          var mimeType = lookupMimeType(element.file.path) ?? "image/jpeg";

          logger.i(
            "📎 File Attached:=========================== ${element.file.path} → ${element.key}",
          );

          request.files.add(
            await http.MultipartFile.fromPath(
              element.key,
              element.file.path,
              contentType: MediaType.parse(mimeType),
            ),
          );
        }
      }

      http.StreamedResponse response = await request.send();
      final content = await response.stream.bytesToString();

      logger.i(
        "⬅️ MULTIPART RESPONSE [$uri]:============================================ $content",
      );

      return Response(
        statusCode: response.statusCode,
        body: jsonDecode(content),
        statusText: response.reasonPhrase,
      );
    } catch (e) {
      logger.e(
        "❌ MULTIPART POST Error:====================================================== $e",
      );
      return  Response(statusCode: 1, statusText: _parseError(e));
    }
  }

  //============================= PUT REQUEST ================================
  static Future<Response> putData(
      String uri,
      dynamic body, {
        Map<String, String>? headers,
      }) async
  {
    if (!await _checkConnection()) {
      return const Response(
        statusCode: 0,
        statusText: 'No Internet Connection',
      );
    }

    bearerToken = await SharePrefsHelper.getString(AppConst.token);

    var mainHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer $bearerToken",
      'x-timezone': DateTime.now().timeZoneName,
      'x-utc-offset-minutes': DateTime.now().timeZoneOffset.inMinutes.toString(),
    };

    try {
      logger.i(
        "➡️ PUT REQUEST========================================================\nURL:===================================================== $uri\nBody:===================================================== $body",
      );

      http.Response response = await client
          .put(
        Uri.parse(ApiUrl.baseUrl + uri),
        body: jsonEncode(body),
        headers: headers ?? mainHeaders,
      )
          .timeout(const Duration(seconds: timeoutInSeconds));

      return handleResponse(response, uri);
    } catch (e) {
      logger.e(
        "❌ PUT Error:===================================================================== $e",
      );
      return  Response(statusCode: 1, statusText: _parseError(e));
    }
  }

  //============================= DELETE REQUEST ================================
  static Future<Response> deleteData(
      String uri, {
        dynamic body,
        Map<String, String>? headers,
      }) async {

    bearerToken = await SharePrefsHelper.getString(AppConst.token);

    var mainHeaders = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer $bearerToken",
      'x-timezone': DateTime.now().timeZoneName,
      'x-utc-offset-minutes': DateTime.now().timeZoneOffset.inMinutes.toString(),
    };

    try {
      logger.i(
        "🗑️ DELETE REQUEST==== URL: $uri",
      );

      http.Response response = await client
          .delete(
        Uri.parse(ApiUrl.baseUrl + uri),
        headers: headers ?? mainHeaders,
        body: body,
      )
          .timeout(const Duration(seconds: timeoutInSeconds));

      return handleResponse(response, uri);
    } catch (e) {
      logger.e("❌ DELETE Error: $e");
      return  Response(statusCode: 1, statusText: _parseError(e));
    }
  }

  //============================= HANDLE RESPONSE ================================
  static Response handleResponse(http.Response response, String uri) {
    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = response.body;
    }

    logger.i(
      "⬅️ RESPONSE FOR Server=============================== [$uri]\nStatus:============================================= ${response.statusCode}\nBody:===================================== ${response.body}",
    );

    return Response(
      statusCode: response.statusCode,
      bodyString: response.body,
      body: data,
      statusText: response.reasonPhrase,
      headers: response.headers,
    );
  }






  // ============================= GET BINARY (PDF/File) ================================
  static Future<Uint8List?> getBinaryData(String uri) async {
    if (!await _checkConnection()) return null;

    bearerToken = await SharePrefsHelper.getString(AppConst.token);

    final headers = {
      'Authorization': "Bearer $bearerToken",
      'x-timezone': DateTime.now().timeZoneName,
      'x-utc-offset-minutes': DateTime.now().timeZoneOffset.inMinutes.toString(),
    };

    try {
      final response = await client
          .get(Uri.parse(ApiUrl.baseUrl + uri), headers: headers)
          .timeout(const Duration(seconds: timeoutInSeconds));

      logger.i("🔵 Binary GET [$uri] Status: ${response.statusCode}");
      logger.i("🔵 Response: ${response.body.substring(0, min(200, response.body.length))}");

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      logger.e("❌ GET Binary Error: $e");
      return null;
    }
  }




}

class MultipartBody {
  String key;
  File file;
  MultipartBody(this.key, this.file);
}
















