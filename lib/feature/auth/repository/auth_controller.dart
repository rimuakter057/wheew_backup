// ignore_for_file: dead_code, unnecessary_null_comparison

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import '../../../core/service/api_checker.dart';
import '../../../core/service/storage_service.dart';
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

  Future<bool> login({
    required BuildContext context,
    required String identifier,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);

    final http.Response loginRes = await _repo.login(
      identifier: identifier,
      password: password,
    );

    _setLoading(false);

    if (loginRes.statusCode == 200) {
      if (isRememberMe.value) {
        await SharePrefsHelper.setString(AppConst.loginUser, identifier);
        await SharePrefsHelper.setString(AppConst.loginPass, password);
      }

      final data = jsonDecode(loginRes.body);

      await SharePrefsHelper.setString(AppConst.token, data['token'] ?? '');
      await SharePrefsHelper.setString(
        AppConst.userID,
        data['id']?.toString() ?? '',
      );
      await SharePrefsHelper.setString(
        AppConst.licenceId,
        data['licence_id'] ?? '',
      );
      await SharePrefsHelper.setString(
        AppConst.nickName,
        data['nick_name'] ?? '',
      );
      await SharePrefsHelper.setBool(AppConst.isLoggedIn, true);
      await _saveUserData(data);

      await AppSocket.init(
        onSocketConnect: () {
          context.goNamed(RouteName.chatList);
        },
      );

      return true;
    } else {
      ApiChecker.checkApi(loginRes);
      return false;
    }
  }

  // ================= REGISTER & LOGIN ==================

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

    final http.Response registerRes = await _repo.register(
      licenceId: licenceId,
      nickName: nickName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      designation: designation,
    );

    if (registerRes.statusCode == 200 || registerRes.statusCode == 201) {
      final http.Response loginRes = await _repo.login(
        identifier: licenceId,
        password: password,
      );

      _setLoading(false);

      if (loginRes.statusCode == 200) {
        final data = jsonDecode(loginRes.body);

        await SharePrefsHelper.setString(AppConst.token, data['token'] ?? '');
        await SharePrefsHelper.setBool(AppConst.isLoggedIn, true);
        await _saveUserData(data);

        return true;
      } else {
        ApiChecker.checkApi(loginRes);
        return false;
      }
    } else {
      _setLoading(false);
      ApiChecker.checkApi(registerRes);
      return false;
    }
  }

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
      showSuccessToast(data['message'] ?? 'otp_send_success'.tr);
      return true;
    } else {
      showErrorToast(data['message'] ?? 'something_wrong'.tr);
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
      showSuccessToast(data['message'] ?? 'otp_verify_success'.tr);
      return data["otp_verification_token"];
    }

    showErrorToast(data['message'] ?? 'something_wrong'.tr);
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
      showSuccessToast(data['message'] ?? 'password_changed'.tr);
      return true;
    } else {
      showErrorToast(data['message'] ?? 'something_wrong'.tr);
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

      if (response.statusCode == 200) {
        message.value = body['message'] ?? '';
      } else {
        errorMessage.value = body['message'] ?? 'something_wrong'.tr;
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
  }) async {
    isLoadingDeleteAccount.value = true;

    final response = await ApiClient.deleteData(
      uri: ApiUrl.deleteAccount,
      body: {"password": password},
    );

    isLoadingDeleteAccount.value = false;

    final data = response["data"];

    if (response["statusCode"] == 200) {
      await clearUserData();
      showSuccessToast(data['message'] ?? 'deleted'.tr);
      context.goNamed(RouteName.signIn);
    } else {
      showErrorToast(data['message'] ?? 'something_wrong'.tr);
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
    await SharePrefsHelper.setBool(AppConst.isLoggedIn, false);
  }
}

/*
// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:http/http.dart';
import 'package:http/http.dart' as http;
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

  // var isRememberMe = false.obs;
  //
  //
  // Future<bool> login({
  //   required BuildContext context,
  //   required String identifier,
  //   required String password,
  //   bool rememberMe = false, // ✅ শুধু এইটা add
  // }) async
  // {
  //   _setLoading(true);
  //
  //   final Response loginRes = await _repo.login(
  //     identifier: identifier,
  //     password: password,
  //   );
  //
  //   _setLoading(false);
  //
  //   if (loginRes.statusCode == 200) {
  //     final data = jsonDecode(loginRes.body);
  //     final String token = data['token'];
  //     final String userId = data['id'];
  //     final String licenceId = data["licence_id"];
  //     final String nickName = data["nick_name"];
  //
  //     /// ✅ Remember Me condition add
  //     if (rememberMe) {
  //       await SharePrefsHelper.setString(AppConst.token, token);
  //       await SharePrefsHelper.setString(AppConst.userID, userId);
  //       await SharePrefsHelper.setString(AppConst.licenceId, licenceId);
  //       await SharePrefsHelper.setString(AppConst.nickName, nickName);
  //       await SharePrefsHelper.setBool(AppConst.isLoggedIn, true);
  //     }
  //
  //     await _saveUserData(data);
  //
  //     await AppSocket.init(
  //       onSocketConnect: () {
  //         context.goNamed(RouteName.chatList);
  //       },
  //     );
  //
  //     return true;
  //   } else {
  //     ApiChecker.checkApi(loginRes, context);
  //     return false;
  //   }
  // }
  //
  //
  //

  //========================== Remember Me ==========================

  RxBool isRememberMe = false.obs;

  void isRememberMeToggle() {
    isRememberMe.toggle();
  }

  void isRememberMeLoadData() async {
    String? savedUser = await SharePrefsHelper.getString(AppConst.loginUser);
    String? savedPass = await SharePrefsHelper.getString(AppConst.loginPass);

    licenseController.text = savedUser ?? '';
    passwordController.text = savedPass ?? '';
    isRememberMe.value = savedUser != null && savedUser.isNotEmpty;
  }

  final TextEditingController licenseController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<bool> login({
    required BuildContext context,
    required String identifier,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);

    final http.Response loginRes = await _repo.login(
      identifier: identifier,
      password: password,
    );

    _setLoading(false);

    if (loginRes.statusCode == 200) {
      if (isRememberMe.value) {
        await SharePrefsHelper.setString(AppConst.loginUser, identifier);
        await SharePrefsHelper.setString(AppConst.loginPass, password);
      }

      final data = jsonDecode(loginRes.body);
      final String token = data['token'];
      final String userId = data['id'];
      final String licenceId = data["licence_id"];
      final String nickName = data["nick_name"];

      await SharePrefsHelper.setString(AppConst.token, token);
      await SharePrefsHelper.setString(AppConst.userID, userId);
      await SharePrefsHelper.setString(AppConst.licenceId, licenceId);
      await SharePrefsHelper.setString(AppConst.nickName, nickName);
      await SharePrefsHelper.setBool(AppConst.isLoggedIn, true);
      await _saveUserData(data);

      await AppSocket.init(
        onSocketConnect: () {
          context.goNamed(RouteName.chatList);
        },
      );

      return true;
    } else {
      ApiChecker.checkApi(loginRes); // ✅ context removed
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

    final http.Response registerRes = await _repo.register(
      licenceId: licenceId,
      nickName: nickName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      designation: designation,
    );

    if (registerRes.statusCode == 200 || registerRes.statusCode == 201) {
      final http.Response loginRes = await _repo.login(
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
        ApiChecker.checkApi(loginRes); // ✅ context removed
        return false;
      }
    } else {
      _setLoading(false);
      ApiChecker.checkApi(registerRes); // ✅ context removed
      return false;
    }
  }
*/
/*
  RxBool isRememberMe = false.obs;

  void isRememberMeToggle() {
    isRememberMe.toggle();
  }

  void isRememberMeLoadData() async {
    String? savedUser = await SharePrefsHelper.getString(AppConst.loginUser);
    String? savedPass = await SharePrefsHelper.getString(AppConst.loginPass);

    licenseController.text = savedUser;
    passwordController.text = savedPass;
    isRememberMe.value = true;
  }

  final TextEditingController licenseController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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
      if (isRememberMe.value) {
        await SharePrefsHelper.setString(AppConst.loginUser, identifier);
        await SharePrefsHelper.setString(AppConst.loginPass, password);
      }
      final data = jsonDecode(loginRes.body);
      final String token = data['token'];
      final String userId = data['id'];
      final String licenceId = data["licence_id"];
      final String nickName = data["nick_name"];

      //   "licence_id": "license_no",
      // "nick_name": "Nick_name",

      // ✅ Save token
      await SharePrefsHelper.setString(AppConst.token, token);
      await SharePrefsHelper.setString(AppConst.userID, userId);
      await SharePrefsHelper.setString(AppConst.licenceId, licenceId);
      await SharePrefsHelper.setString(AppConst.nickName, nickName);
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
  }*/ /*


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
        SnackBar(content: Text(data['message'] ?? "user_not_found".tr)),
      );
      return false;
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade100,
          content: Text(
            data['message'] ?? "otp_send_success".tr,
            style: GoogleFonts.poppins(
              color: AppColors.black,
              fontWeight: FontWeight.w400,
              fontSize: ResponsiveHelper.fontSize(14),
            ),
          ),
        ),
      );

      return true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'] ?? "something_went_wrong".tr)),
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
            data['message'] ?? "otp_verify_success".tr,
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
      SnackBar(content: Text(data['message'] ?? "something_went_wrong".tr)),
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
  }) async
  {
    isLoadingReset.value = true;

    final response = await ApiClient.postData(
      uri: ApiUrl.reset,
      body: {"email": email, "password": password, "token": token},
    );

    final data = jsonDecode(response.body);

    isLoadingReset.value = false;

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade100,
          content: Text(
            data['message'] ?? "password_reset_successfully".tr,
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
        SnackBar(content: Text(data['message'] ?? "something_went_wrong".tr)),
      );
      return false;
    }
  }
///help and support==============================================

  final isLoadingHelp = false.obs;
  final message = ''.obs;
  final errorMessage = ''.obs;





  Future<void> fetchHelpSupport() async {
    try {
      isLoadingHelp.value = true;
      errorMessage.value = '';

      final response = await ApiClient.getData(uri:ApiUrl .help);

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        message.value = body['message'] ?? '';
      } else {
        errorMessage.value = body['message'] ?? "something_went_wrong".tr;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingHelp.value = false;
    }
  }

  /// delete account==========================================================================================

  var isLoadingDeleteAccount = false.obs;

  Future<void> deleteAccount({
    required BuildContext context,
    required String password,
  }) async {

    isLoadingDeleteAccount.value = true;

    final response = await ApiClient.deleteData(
      uri: ApiUrl.deleteAccount,
      body: {"password": password},
    );

    isLoadingDeleteAccount.value = false;

    final data = response["data"];

    if (response["statusCode"] == 200) {

      await clearUserData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? "delete_account".tr)),
      );

      context.goNamed(RouteName.signIn);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? "failed_delete_account".tr)),
      );

    }
  }

  Future<void> clearUserData() async {
    await SharePrefsHelper.remove(AppConst.token);
    await SharePrefsHelper.remove(AppConst.userID);
    await SharePrefsHelper.remove(AppConst.userData);
    await SharePrefsHelper.remove(AppConst.licenceId);
    await SharePrefsHelper.remove(AppConst.nickName);
    await SharePrefsHelper.remove(AppConst.loginUser);
    await SharePrefsHelper.remove(AppConst.loginPass);
    await SharePrefsHelper.setBool(AppConst.isLoggedIn, false);
  }


}
*/
