

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'package:http/http.dart' as http; // ✅ use alias
import 'package:platchatapp/utils/language/app_string.dart';

import '../../utils/toast_message/toast_message.dart';

class ApiChecker {
  static void checkApi(http.Response response) {
    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    developer.log('🔍 API CHECKER', name: 'API');
    developer.log('Status Code: ${response.statusCode}', name: 'API');

    if (response.statusCode == 200 || response.statusCode == 201) {
      developer.log('✅ Success', name: 'API');
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return;
    }

    // ✅ 400, 401, 403, 404 → all show invalid_credentials
    if (response.statusCode == 400 ||
        response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 404) {
      developer.log(
        '❌ Invalid credentials (${response.statusCode})',
        name: 'API',
      );
      showErrorToast(AppStrings.invalidCredentials.tr);

    } else if (response.statusCode == 422) {
      try {
        final body = jsonDecode(response.body);
        String msg = AppStrings.someThingWrong.tr;

        if (body['errors'] != null && body['errors'] is Map) {
          final errors = body['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            msg = firstError.first.toString();
          } else if (firstError is String) {
            msg = firstError;
          }
        } else if (body['message'] != null) {
          msg = body['message'];
        }

        developer.log('❌ Validation: $msg', name: 'API');
        showErrorToast(msg);
      } catch (_) {
        showErrorToast(AppStrings.someThingWrong.tr);
      }
    } else if (response.statusCode == 500) {
      developer.log('❌ 500 Server Error', name: 'API');
      showErrorToast(AppStrings.serverError.tr);
    } else {
      developer.log('❌ Error ${response.statusCode}', name: 'API');
      showErrorToast(AppStrings.someThingWrong.tr);
    }

    developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  static String getErrorMessage(dynamic error) {
    developer.log('⚠️ EXCEPTION: $error', name: 'API');

    if (error.toString().contains('SocketException')) {
      return AppStrings.networkError.tr;
    } else if (error.toString().contains('TimeoutException')) {
      return AppStrings.timeout.tr;
    } else {
      return AppStrings.someThingWrong.tr;
    }
  }
}


