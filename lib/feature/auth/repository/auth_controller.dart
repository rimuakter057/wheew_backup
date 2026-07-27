// ignore_for_file: dead_code, unnecessary_null_comparison
import 'dart:async';
import 'package:platchatapp/utils/language/app_string.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import 'package:platchatapp/feature/notification/controller/notification_controller.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import '../../../core/service/api_checker.dart';
import '../../../core/service/storage_service.dart';
import '../../../helper/custom_snack_bar/custom_snack_bar.dart';
import '../../../utils/toast_message/toast_message.dart';
import 'auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _repo = AuthRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    update();
  }

  // ========================== Remember Me ==========================

  RxBool isRememberMe = false.obs;

  void isRememberMeToggle() {
    isRememberMe.toggle();
  }

  void isRememberMeLoadData() async {
    String? savedUser = await SharePrefsHelper.getString(AppConst.loginUser);
    String? savedPass = await SharePrefsHelper.getString(AppConst.loginPass);

    licenseController.text = savedUser;
    passwordController.text = savedPass;
    isRememberMe.value = savedUser != null && savedUser.isNotEmpty;
  }

  final TextEditingController licenseController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ========================== LOGIN ==========================

  // Future<bool> login({
  //   required BuildContext context,
  //   required String identifier,
  //   required String password,
  //   bool rememberMe = false,
  // }) async
  // {
  //   _setLoading(true);
  //
  //   String? fcmToken = await FirebaseMessaging.instance.getToken();
  //   debugPrint('🔥 FCM Token: $fcmToken'); // ✅ এখানে দেখবেন token আসছে কিনা
  //
  //   if (fcmToken == null) {
  //
  //     _setLoading(false);
  //     return false;
  //   }
  //
  //
  //
  //   final http.Response loginRes = await _repo.login(
  //     identifier: identifier,
  //     password: password,
  //     fcmToken: fcmToken,
  //   );
  //
  //
  //   _setLoading(false);
  //
  //   if (loginRes.statusCode == 200) {
  //     if (isRememberMe.value) {
  //       await SharePrefsHelper.setString(AppConst.loginUser, identifier);
  //       await SharePrefsHelper.setString(AppConst.loginPass, password);
  //     }
  //
  //     final data = jsonDecode(loginRes.body);
  //
  //     await SharePrefsHelper.setString(AppConst.token, data['token'] ?? '');
  //     await SharePrefsHelper.setString(AppConst.userID, data['id']?.toString() ?? '');
  //     await SharePrefsHelper.setString(AppConst.licenceId, data['licence_id'] ?? '');
  //     await SharePrefsHelper.setString(AppConst.nickName, data['nick_name'] ?? '');
  //     await SharePrefsHelper.setBool(AppConst.isLoggedIn, true);
  //     await _saveUserData(data);
  //
  //     debugPrint('✅ Login successful - navigating to mainNavScreen');
  //     final locationController = Get.put(UserLocationController());
  //     await locationController.initLocationTracking();
  //     await AppSocket.init(
  //       onSocketConnect: () {
  //         debugPrint('🔌 Socket connected - going to mainNavScreen');
  //         if (context.mounted) {
  //           context.goNamed(RouteName.mainNavScreen);
  //         }
  //       },
  //     );
  //
  //
  //
  //
  //     return true;
  //   } else {
  //     debugPrint('❌ Login failed: ${loginRes.statusCode} - ${loginRes.body}');
  //     ApiChecker.checkApi(loginRes);
  //     return false;
  //   }
  // }


  Future<bool> login({
    required BuildContext context,
    required String identifier,
    required String password,
    bool rememberMe = false,
  }) async
  {
    _setLoading(true);

    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint('🔥 FCM Token: $fcmToken');

      if (fcmToken == null) {
        showErrorToast(AppStrings.notificationSetupFailed.tr);
        // মেসেজ: "নোটিফিকেশন সেটআপ করা যাচ্ছে না, ইন্টারনেট কানেকশন চেক করে আবার চেষ্টা করুন।"
        return false;
      }

      final http.Response loginRes = await _repo.login(
        identifier: identifier,
        password: password,
        fcmToken: fcmToken,
      );

      if (loginRes.statusCode == 200 || loginRes.statusCode == 201) {
        if (isRememberMe.value) {
          await SharePrefsHelper.setString(AppConst.loginUser, identifier);
          await SharePrefsHelper.setString(AppConst.loginPass, password);
        }

        final data = jsonDecode(loginRes.body);
        debugPrint('📦 Parsed login response data: $data');

        await SharePrefsHelper.setString(AppConst.token, data['token'] ?? '');
        await SharePrefsHelper.setString(AppConst.userID, data['id']?.toString() ?? '');
        await SharePrefsHelper.setString(AppConst.licenceId, data['licence_id'] ?? '');
        await SharePrefsHelper.setString(AppConst.nickName, data['nick_name'] ?? '');
       // await SharePrefsHelper.setString(AppConst.licenseNoVerified, data['license_no_verified'] ?? '');
        await SharePrefsHelper.setBool(
          AppConst.licenseNoVerified,
          data['license_no_verified'] ?? false,
        );


        await SharePrefsHelper.setBool(AppConst.isLoggedIn, true);





        await _saveUserData(data);

        // Location permission is requested when the user enters the Home
        // screen; notification permission when entering the Chat List
        // screen — not eagerly here at login.

        // Force a fresh notification fetch for this account — otherwise the
        // globally-registered NotificationController keeps showing the
        // previous user's unread count/list until something refetches it.
        if (Get.isRegistered<NotificationController>()) {
          Get.find<NotificationController>().fetchNotifications(refresh: true);
        }

        AppSocket.init(
          onSocketConnect: () {
            debugPrint('🔌 Socket connected - going to mainNavScreen');
            if (context.mounted) {
              context.goNamed(RouteName.mainNavScreen);


              CustomSnackbar.success(context: context, message: "Login Successful");

              Future.delayed(const Duration(milliseconds: 300), () {
                licenseController.clear();
                passwordController.clear();
              });
            }

          },
        );

        return true;
      }







      else {
        debugPrint('❌ Login failed: ${loginRes.statusCode} - ${loginRes.body}');
        ApiChecker.checkApi(loginRes); // ব্যাকএন্ডের আসল error message (যেমন "Invalid credentials") দেখাবে
        return false;
      }
    } on TimeoutException catch (e) {
      debugPrint('⏰ Login timeout: $e');
    //  showErrorToast(AppStrings.loginConnectionTimeout.tr);
      CustomSnackbar.error(message:AppStrings.loginConnectionTimeout.tr, context: context);

      // মেসেজ: "সার্ভারের সাথে কানেক্ট হতে সময় বেশি লাগছে। ইন্টারনেট চেক করে আবার চেষ্টা করুন।"
      return false;
    } on FormatException catch (e) {
      debugPrint('❌ Login format/URL error: $e');
    //  showErrorToast(AppStrings.loginUnavailableTryAgain.tr);
      CustomSnackbar.error(message:AppStrings.loginUnavailableTryAgain.tr, context: context);
      // মেসেজ: "এই মুহূর্তে লগইন করা যাচ্ছে না। কিছুক্ষণ পর আবার চেষ্টা করুন।"
      return false;
    } catch (e) {
      debugPrint('❌ Login exception: $e');
      // showErrorToast(AppStrings.loginFailedCheckConnection.tr);
      CustomSnackbar.error(message:AppStrings.loginFailedCheckConnection.tr, context: context);
      // মেসেজ: "লগইন সম্পন্ন করা যাচ্ছে না। আপনার ইন্টারনেট কানেকশন চেক করুন।"
      return false;
    } finally {
      _setLoading(false);
    }
  }
  // ================= REGISTER & LOGIN ==================



  // ================= SAVE USER DATA ====================

  Future<void> _saveUserData(Map<String, dynamic> data) async {
    // ✅ Login response is flat — no nested 'user' key
    final user = data['user'] ?? data;

    await SharePrefsHelper.setString(
      AppConst.userID,
      user['id']?.toString() ?? '',
    );
    await SharePrefsHelper.setString(
      AppConst.nickName,
      user['nick_name'] ?? '',
    );
    await SharePrefsHelper.setString(
      AppConst.licenceId,
      user['licence_id'] ?? '',
    );

    // ✅ Save avatar raw path
    final avatar = user['avatar'];
    if (avatar != null && avatar.toString().isNotEmpty) {
      await SharePrefsHelper.setString(AppConst.avatar, avatar.toString());
    }

    // ✅ Save full user JSON — this is what profile screen reads first
    await SharePrefsHelper.setString(AppConst.userData, jsonEncode(user));

    // ✅ Debug log to verify data is saved
    debugPrint('✅ userData saved: ${jsonEncode(user)}');
    debugPrint('✅ avatar saved: $avatar');
    debugPrint('✅ nickName saved: ${user['nick_name']}');
    debugPrint('✅ licenceId saved: ${user['licence_id']}');
  }

  /*
  Future<void> _saveUserData(Map<String, dynamic> data) async {
    final user = data['user'] ?? data;

    await SharePrefsHelper.setString(AppConst.userID, user['id']?.toString() ?? '');
    await SharePrefsHelper.setString(AppConst.nickName, user['nick_name'] ?? '');
    await SharePrefsHelper.setString(AppConst.licenceId, user['licence_id'] ?? '');

    // ✅ Save avatar raw path so profile loads on any device
    if (user['avatar'] != null) {
      await SharePrefsHelper.setString(AppConst.avatar, user['avatar']);
    }

    // ✅ Save full user JSON
    await SharePrefsHelper.setString(AppConst.userData, jsonEncode(user));
  }
*/

  // ======================= LOGOUT ======================

  Future<void> logout() async {
    await SharePrefsHelper.remove(AppConst.token);
    await SharePrefsHelper.remove(AppConst.userID);
    await SharePrefsHelper.remove(AppConst.userData);
    await SharePrefsHelper.setBool(AppConst.isLoggedIn, false);
  }

  // ================= LOGIN CHECK ======================

  Future<bool> isUserLoggedIn() async {
    return await SharePrefsHelper.getBool(AppConst.isLoggedIn) ?? false;
  }

  /// Backend validation errors (class-validator style) send `message` as a
  /// list of strings instead of a plain string — passing that straight to a
  /// String-typed toast/Rx crashes with a List-to-String type error.
  /// Normalize both shapes here.
  String _extractMessage(dynamic data, String fallback) {
    final msg = data is Map ? data['message'] : null;
    if (msg is String && msg.isNotEmpty) return msg;
    if (msg is List && msg.isNotEmpty) return msg.map((e) => e.toString()).join(', ');
    return fallback;
  }

  // ================= FORGET PASSWORD =================

  var isLoadingEmail = false.obs;

  Future<bool> sendOtp({
    required String email,
    required BuildContext context,
  }) async {
    isLoadingEmail.value = true;

    final response = await ApiClient.postData(
      uri: ApiUrl.forget,
      body: {'email': email},
    );

    final data = jsonDecode(response.body);
    isLoadingEmail.value = false;

    if (response.statusCode == 200 || response.statusCode == 201) {
      showSuccessToast(_extractMessage(data, AppStrings.otpSendSuccess.tr));
      return true;
    } else {
      showErrorToast(_extractMessage(data, AppStrings.someThingWrong.tr));
      return false;
    }
  }

  // ================= VERIFY OTP ======================

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
      showSuccessToast(_extractMessage(data, AppStrings.otpVerifySuccess.tr));
      return data["otp_verification_token"];
    }

    showErrorToast(_extractMessage(data, AppStrings.someThingWrong.tr));
    return null;
  }

  // ================= RESET PASSWORD ==================

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
      body: {"email": email, "password": password, "token": token},
    );

    final data = jsonDecode(response.body);
    isLoadingReset.value = false;

    if (response.statusCode == 200 || response.statusCode == 201) {
      showSuccessToast(_extractMessage(data, AppStrings.passwordChanged.tr));
      return true;
    } else {
      showErrorToast(_extractMessage(data, AppStrings.someThingWrong.tr));
      return false;
    }
  }

  // ================= HELP & SUPPORT ==================

  final isLoadingHelp = false.obs;
  final message = ''.obs;
  final errorMessage = ''.obs;

  Future<void> fetchHelpSupport() async {
    try {
      isLoadingHelp.value = true;
      errorMessage.value = '';

      final response = await ApiClient.getData(uri: ApiUrl.help);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        message.value = _extractMessage(body, '');
      } else {
        errorMessage.value = _extractMessage(body, AppStrings.someThingWrong.tr);
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingHelp.value = false;
    }
  }

  // ================= DELETE ACCOUNT ==================

  var isLoadingDeleteAccount = false.obs;

  Future<void> deleteAccount({
    required BuildContext context,
    required String password,
  }) async
  {
    isLoadingDeleteAccount.value = true;

    final response = await ApiClient.deleteData(
      uri: ApiUrl.deleteAccount,
      body: {"password": password},
    );

    isLoadingDeleteAccount.value = false;

    final data = response["data"];

    if (response["statusCode"] == 200 || response["statusCode"] == 201) {
      await clearUserData();
      showSuccessToast(_extractMessage(data, AppStrings.deleted.tr));
      context.goNamed(RouteName.signIn);
    } else {
      showErrorToast(_extractMessage(data, AppStrings.someThingWrong.tr));
    }
  }

  // ================= CLEAR USER DATA ==================

  Future<void> clearUserData() async {
    await SharePrefsHelper.remove(AppConst.token);
    await SharePrefsHelper.remove(AppConst.userID);
    await SharePrefsHelper.remove(AppConst.userData);
    await SharePrefsHelper.remove(AppConst.licenceId);
    await SharePrefsHelper.remove(AppConst.nickName);
    await SharePrefsHelper.remove(AppConst.avatar); // ✅ clear avatar too
    await SharePrefsHelper.remove(AppConst.loginUser);
    await SharePrefsHelper.remove(AppConst.loginPass);
    await SharePrefsHelper.remove(AppConst.licenseNoVerified);
    await SharePrefsHelper.setBool(AppConst.isLoggedIn, false);
  }
}
