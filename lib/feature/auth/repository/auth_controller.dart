import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
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
      final String userId = data['id'];


    //
    //   "licence_id": "license_no",
    // "nick_name": "Nick_name",

      // ✅ Save token
      await SharePrefsHelper.setString(AppConst.token, token);
      await SharePrefsHelper.setString(AppConst.userID, userId);
      await SharePrefsHelper.setBool(AppConst.isLoggedIn, true);
      await _saveUserData(data);

      await AppSocket.init(
        onSocketConnect: () {
          context.goNamed(RouteName.chatList);
        },
      );

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
    required String email,
    required String password,
    required String confirmPassword,
    required String designation,
  }) async {
    _setLoading(true);

    final Response registerRes = await _repo.register(
      licenceId: licenceId,
      nickName: nickName,
      email: email,
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
    await SharePrefsHelper.setString(AppConst.userData, jsonEncode(user));
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

  /// forget email send=================

  var isLoadingEmail = false.obs;

  Future<bool> sendOtp({
    required String email,
    required BuildContext context,
  }) async
  {
    isLoadingEmail.value = true;

    final response = await ApiClient.postData(
      uri: ApiUrl.forget,
      body: {'email': email},
    );

    final data = jsonDecode(response.body);

    isLoadingEmail.value = false;

    if (response.statusCode == 404) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? "User Not Found"),
        ),
      );
      return false;
    }

    if (response.statusCode == 200 || response.statusCode == 201) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade100,
          content: Text(data['message'] ?? "OTP sent successfully",style: GoogleFonts.poppins(
            color: AppColors.black,
            fontWeight: FontWeight.w400,
            fontSize: ResponsiveHelper.fontSize(14),
          ),),
        ),
      );

      return true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(data['message'] ?? "Something went wrong"),
      ),
    );

    return false;
  }


  /// verify otp===================================================
  var isLoadingVerify = false.obs;

  Future<String?> verifyOtp({
    required String email,
    required String otp,
    required BuildContext context,
  }) async {
    isLoadingVerify.value = true;

    final response = await ApiClient.postData(
      uri: ApiUrl.verifyOtp,
      body: {'email': email, 'otp': otp},
    );

    final data = jsonDecode(response.body);

    isLoadingVerify.value = false;

    if (response.statusCode == 200 || response.statusCode == 201) {
      final otpToken = data["otp_verification_token"]; // token capture

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade100,
          content: Text(
            data['message'] ?? "OTP verified successfully",
            style: GoogleFonts.poppins(
              color: AppColors.black,
              fontWeight: FontWeight.w400,
              fontSize: ResponsiveHelper.fontSize(14),
            ),
          ),
        ),
      );

      return otpToken; // token return
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(data['message'] ?? "Something went wrong"),
      ),
    );

    return null;
  }

///reset===============================

  var isLoadingReset = false.obs;

  Future<bool> resetOtp({
    required String email,
    required String password,
    required String token,
    required BuildContext context,
  }) async {
    isLoadingReset.value = true;

    final response = await ApiClient.postData(
      uri: ApiUrl.reset,
      body: {
        "email": email,
        "password": password,
        "token": token,
      },
    );

    final data = jsonDecode(response.body);

    isLoadingReset.value = false;

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade100,
          content: Text(
            data['message'] ?? "Password reset successfully",
            style: GoogleFonts.poppins(
              color: AppColors.black,
              fontWeight: FontWeight.w400,
              fontSize: ResponsiveHelper.fontSize(14),
            ),
          ),
        ),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? "Something went wrong"),
        ),
      );
      return false;
    }
  }

















}




