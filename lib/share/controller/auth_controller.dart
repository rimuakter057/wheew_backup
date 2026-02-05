import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart';
import '../../core/service/api_checker.dart';
import '../../core/service/storage_service.dart';
import '../../feature/auth/repository/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _repo = AuthRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    update();
  }

  Future<bool> login({
    required BuildContext context,
    required String identifier,
    required String password,
    bool rememberMe = false,
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
      await StorageService.saveToken(token);

      // Save user data
      await _saveUserData(data);

      // Save credentials if remember me is checked
      if (rememberMe) {
        await StorageService.saveCredentials(
          identifier: identifier,
          password: password,
        );
      } else {
        await StorageService.clearCredentials();
      }

      return true;
    } else {
      ApiChecker.checkApi(loginRes, context);
      return false;
    }
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

        // Save token and user data
        await StorageService.saveToken(token);
        await _saveUserData(data);

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

  // Save user data to SharedPreferences
  Future<void> _saveUserData(Map<String, dynamic> data) async {
    if (data['user'] != null) {
      await StorageService.saveUserData(
        userId: data['user']['id'] ?? '',
        nickName: data['user']['nick_name'] ?? '',
        licenceId: data['user']['licence_id'] ?? '',
        avatar: data['user']['avatar'],
        role: data['user']['role'] ?? 'USER',
      );
    } else {
      await StorageService.saveUserData(
        userId: data['id'] ?? '',
        nickName: data['nick_name'] ?? '',
        licenceId: data['licence_id'] ?? '',
        avatar: data['avatar'],
        role: data['role'] ?? 'USER',
      );
    }
  }

  Future<void> logout() async {
    await StorageService.clearAll();
  }

  // Check if user is already logged in
  bool isUserLoggedIn() {
    return StorageService.isLoggedIn();
  }
}


/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart';
import '../../core/service/api_checker.dart';
import '../../core/service/storage_service.dart';
import '../../feature/auth/repository/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _repo = AuthRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    update();
  }

  Future<bool> login({
    required BuildContext context,
    required String identifier,
    required String password,
    bool rememberMe = false,
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
      await StorageService.saveToken(token);

      // Save user data
      await _saveUserData(data);

      // Save credentials if remember me is checked
      if (rememberMe) {
        await StorageService.saveCredentials(
          identifier: identifier,
          password: password,
        );
      } else {
        await StorageService.clearCredentials();
      }

      return true;
    } else {
      ApiChecker.checkApi(loginRes, context);
      return false;
    }
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

        // Save token and user data
        await StorageService.saveToken(token);
        await _saveUserData(data);

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

  // Save user data to SharedPreferences
  Future<void> _saveUserData(Map<String, dynamic> data) async {
    if (data['user'] != null) {
      await StorageService.saveUserData(
        userId: data['user']['id'] ?? '',
        nickName: data['user']['nick_name'] ?? '',
        licenceId: data['user']['licence_id'] ?? '',
        avatar: data['user']['avatar'],
        role: data['user']['role'] ?? 'USER',
      );
    } else {
      await StorageService.saveUserData(
        userId: data['id'] ?? '',
        nickName: data['nick_name'] ?? '',
        licenceId: data['licence_id'] ?? '',
        avatar: data['avatar'],
        role: data['role'] ?? 'USER',
      );
    }
  }

  Future<void> logout() async {
    await StorageService.clearAll();
  }

  // Check if user is already logged in
  bool isUserLoggedIn() {
    return StorageService.isLoggedIn();
  }
}*/
