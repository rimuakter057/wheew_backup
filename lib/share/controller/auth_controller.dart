import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart';
import '../../core/service/api_checker.dart';
import '../../feature/auth/repository/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _repo = AuthRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    update();
  }

  Future<bool> registerAndLogin({
    required BuildContext context,
    required String licenceId,
    required String nickName,
    required String password,
    required String confirmPassword,
    required String designation,
  }) async {
    _setLoading(true);

    final Response registerRes = await _repo.register(
      licenceId: licenceId,
      nickName: nickName,
      password: password,
      confirmPassword: confirmPassword,
      designation: designation,
    );

    if (registerRes.statusCode == 200 || registerRes.statusCode == 201) {
      // Use identifier (can be email or licence_id) for login
      final Response loginRes = await _repo.login(
        identifier: licenceId,  // Changed parameter name
        password: password,
      );

      _setLoading(false);

      if (loginRes.statusCode == 200) {
        final data = jsonDecode(loginRes.body);
        final token = data['token'];

        // TODO: save token
        return true;
      } else {
        ApiChecker.checkApi(loginRes, context);
        return false;
      }
    } else {
      _setLoading(false);
      ApiChecker.checkApi(registerRes, context);
      return false;
    }
  }

  // Add standalone login method
  Future<bool> login({
    required BuildContext context,
    required String identifier,  // Can be email or licence_id
    required String password,
  }) async {
    _setLoading(true);

    final Response loginRes = await _repo.login(
      identifier: identifier,
      password: password,
    );

    _setLoading(false);

    if (loginRes.statusCode == 200) {
      final data = jsonDecode(loginRes.body);
      final token = data['token'];

      // TODO: save token
      return true;
    } else {
      ApiChecker.checkApi(loginRes, context);
      return false;
    }
  }
}

/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import '../../core/service/api_checker.dart';
import '../../feature/auth/repository/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _repo = AuthRepository();
  final storage = GetStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    update();
  }

  Future<bool> registerAndLogin({
    required BuildContext context,
    required String licenceId,
    required String nickName,
    required String password,
    required String confirmPassword,
    required String designation,
  }) async {
    _setLoading(true);

    final Response registerRes = await _repo.register(
      licenceId: licenceId,
      nickName: nickName,
      password: password,
      confirmPassword: confirmPassword,
      designation: designation,
    );

    if (registerRes.statusCode == 200 || registerRes.statusCode == 201) {
      final Response loginRes = await _repo.login(
        identifier: licenceId,
        password: password,
      );

      _setLoading(false);

      if (loginRes.statusCode == 200) {
        final data = jsonDecode(loginRes.body);
        final token = data['token'];

        // Save token
        await storage.write('token', token);

        return true;
      } else {
        ApiChecker.checkApi(loginRes, context);
        return false;
      }
    } else {
      _setLoading(false);
      ApiChecker.checkApi(registerRes, context);
      return false;
    }
  }

  Future<bool> login({
    required BuildContext context,
    required String identifier,
    required String password,
  }) async {
    _setLoading(true);

    final Response loginRes = await _repo.login(
      identifier: identifier,
      password: password,
    );

    _setLoading(false);

    if (loginRes.statusCode == 200) {
      final data = jsonDecode(loginRes.body);
      final token = data['token'];

      // Save token
      await storage.write('token', token);

      return true;
    } else {
      ApiChecker.checkApi(loginRes, context);
      return false;
    }
  }

  Future<void> logout() async {
    await storage.remove('token');
  }
}
*/
