import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../../core/service/api_client.dart';
import '../../../core/service/api_url.dart';

class AuthRepository {

  Future<http.Response> register({
    required String licenceId,
    required String nickName,
    required String password,
    required String confirmPassword,
    required String designation,
    required String email,
    required String country,   // ✅ নতুন
    required String city,      // ✅ নতুন
    // Backend rejects the request without these two:
    //   gender     -> MALE | FEMALE | PREFER_NOT_TO_SAY
    //   birth_year -> integer between 1000 and the current year
    required String gender,
    required int birthYear,
  }) async {
    return await ApiClient.postData(
      uri: ApiUrl.register,
      body: {
        "licence_id": licenceId,
        "nick_name": nickName,
        "password": password,
        "confirmPassword": confirmPassword,
        "designation": designation,
        "email": email,
        "country": country,   // ✅ নতুন
        "city": city,         // ✅ নতুন
        "gender": gender,
        // Sent as a real int, not a string — the API validates it with
        // "birth_year must be an integer number".
        "birth_year": birthYear,
      },
    );
  }

  Future<http.Response> login({
    required String identifier,
    required String password,
    required String fcmToken,
  }) async {
    final body = {
      "identifier": identifier,
      "password": password,
      "fcm_token": fcmToken,
    };

    debugPrint('📤 Login request body: $body'); // ✅ এখন body defined

    return await ApiClient.postData(
      uri: ApiUrl.login,
      body: body,
    );
  }
}


