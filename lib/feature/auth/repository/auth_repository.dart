import 'package:http/http.dart';
import '../../../core/service/api_client.dart';
import '../../../core/service/api_url.dart';

class AuthRepository {
  Future<Response> register({
    required String licenceId,
    required String nickName,
    required String password,
    required String confirmPassword,
    required String designation,
    required String email,
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
      },
    );
  }

  Future<Response> login({
    required String identifier,
    required String password,
  }) async {
    return await ApiClient.postData(
      uri: ApiUrl.login,
      body: {
        "identifier": identifier,
        "password": password,
      },
    );
  }
}
