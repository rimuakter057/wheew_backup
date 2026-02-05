import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import '../../../core/service/api_checker.dart';
import '../../../core/service/storage_service.dart';
import 'auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _repo = AuthRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    update();
  }

  /// ======================= LOGIN =======================
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
      final String token = data['token'];

      // ✅ Save token
      await SharePrefsHelper.setString(AppConst.token, token);
      await SharePrefsHelper.setBool(AppConst.isLoggedIn, true);

      // ✅ Save user data
      await _saveUserData(data);

      return true;
    } else {
      ApiChecker.checkApi(loginRes, context);
      return false;
    }
  }

  /// ================= REGISTER & LOGIN ==================
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
        final String token = data['token'];

        await SharePrefsHelper.setString(AppConst.token, token);
        await SharePrefsHelper.setBool(AppConst.isLoggedIn, true);
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

  /// ================= SAVE USER DATA ====================
  Future<void> _saveUserData(Map<String, dynamic> data) async {
    final user = data['user'] ?? data;

    // Save user ID
    await SharePrefsHelper.setString(
      AppConst.userID,
      user['id']?.toString() ?? '',
    );

    // Save full user object as JSON
    await SharePrefsHelper.setString(
      AppConst.userData,
      jsonEncode(user),
    );
  }

  /// ======================= LOGOUT ======================
  Future<void> logout() async {
    await SharePrefsHelper.remove(AppConst.token);
    await SharePrefsHelper.remove(AppConst.userID);
    await SharePrefsHelper.remove(AppConst.userData);
    await SharePrefsHelper.setBool(AppConst.isLoggedIn, false);
  }

  /// ================= LOGIN CHECK ======================
  Future<bool> isUserLoggedIn() async {
    return await SharePrefsHelper.getBool(AppConst.isLoggedIn) ?? false;
  }
}
