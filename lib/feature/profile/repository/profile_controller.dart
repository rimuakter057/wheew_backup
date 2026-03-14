import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';
import '../../../utils/app_const/app_const.dart';
import '../../../utils/toast_message/toast_message.dart';
import '../../../core/service/api_url.dart';
import 'profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository profileRepository = ProfileRepository();

  final Rx<File?> profileImage = Rx<File?>(null);
  final Rx<UserModel?> userProfile = Rx<UserModel?>(null);

  final nickNameController = TextEditingController();
  final licenseController = TextEditingController();

  bool isEditing = false;
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    _initProfile();
  }

  Future<void> _initProfile() async {
    await loadUserData();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConst.token);
    if (token != null && token.isNotEmpty) {
      await fetchProfileFromApi();
    }
  }

  // ✅ Reload every time profile screen opens
  Future<void> reloadProfile() async {
    await loadUserData();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConst.token);
    if (token != null && token.isNotEmpty) {
      await fetchProfileFromApi();
    }
  }

  // ✅ Load local data first for instant display
  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(AppConst.userData);

      if (userDataString != null && userDataString.isNotEmpty) {
        _applyUserData(jsonDecode(userDataString));
      } else {
        // ✅ Fallback to individual keys
        final nickName = prefs.getString(AppConst.nickName) ?? '';
        final licenceId = prefs.getString(AppConst.licenceId) ?? '';
        final avatar = prefs.getString(AppConst.avatar);

        if (nickName.isNotEmpty || licenceId.isNotEmpty) {
          _applyUserData({
            'nick_name': nickName,
            'licence_id': licenceId,
            'avatar': avatar,
          });
        }
      }
    } catch (e) {
      debugPrint('❌ loadUserData error: $e');
    }
    update();
  }

  // ✅ Fetch fresh profile from /auth/me

  Future<void> fetchProfileFromApi() async {
    // ✅ Check token exists before calling API
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConst.token);

    if (token == null || token.isEmpty) {
      debugPrint('⚠️ No token — skipping fetchProfileFromApi');
      return; // ✅ Don't call API without token
    }

    isLoading = true;
    update();

    try {
      final res = await profileRepository.getProfile();
      debugPrint('📡 fetchProfileFromApi status: ${res.statusCode}');
      debugPrint('📡 fetchProfileFromApi body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final user = data['user'] ?? data;

        await prefs.setString(AppConst.userData, jsonEncode(user));
        await prefs.setString(AppConst.nickName, user['nick_name'] ?? '');
        await prefs.setString(AppConst.licenceId, user['licence_id'] ?? '');
        if (user['avatar'] != null) {
          await prefs.setString(AppConst.avatar, user['avatar'].toString());
        }

        _applyUserData(user);
      }
    } catch (e) {
      debugPrint('❌ fetchProfileFromApi error: $e');
    }

    isLoading = false;
    update();
  }

/*  Future<void> fetchProfileFromApi() async {
    isLoading = true;
    update();

    try {
      final res = await profileRepository.getProfile();
      debugPrint('📡 fetchProfileFromApi status: ${res.statusCode}');
      debugPrint('📡 fetchProfileFromApi body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);

        // ✅ Handle both flat and nested { user: {...} } response
        final user = data['user'] ?? data;

        // ✅ Save fresh data locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConst.userData, jsonEncode(user));
        await prefs.setString(AppConst.nickName, user['nick_name'] ?? '');
        await prefs.setString(AppConst.licenceId, user['licence_id'] ?? '');
        if (user['avatar'] != null) {
          await prefs.setString(AppConst.avatar, user['avatar'].toString());
        }

        _applyUserData(user);
      }
    } catch (e) {
      debugPrint('❌ fetchProfileFromApi error: $e');
    }

    isLoading = false;
    update();
  }*/

  // ✅ Apply data to UI
  void _applyUserData(Map<String, dynamic> data) {
    final avatarUrl = _buildAvatarUrl(data['avatar']);

    userProfile.value = UserModel(
      nickName: data['nick_name'] ?? '',
      licenceId: data['licence_id'] ?? '',
      avatar: avatarUrl,
    );

    nickNameController.text = userProfile.value!.nickName;
    licenseController.text = userProfile.value!.licenceId;
    update(); // ✅ force UI refresh
  }

  // ✅ Build full avatar URL from raw server path
  String? _buildAvatarUrl(dynamic rawAvatar) {
    if (rawAvatar == null || rawAvatar.toString().isEmpty) return null;

    final avatar = rawAvatar.toString();
    if (avatar.startsWith('http')) return avatar;

    final cleanPath = avatar.replaceAll('\\', '/');
    return '${ApiUrl.baseUrl}/$cleanPath';
  }

  // 📷 Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null) {
        profileImage.value = File(picked.path);
        update();
      }
    } catch (e) {
      debugPrint('❌ Image pick error: $e');
      showErrorToast('something_wrong'.tr);
    }
  }

  // ✅ Upload avatar to server
  Future<void> updateProfile() async {
    if (profileImage.value == null) {
      showErrorToast('please_select_an_image_first'.tr);
      return;
    }

    isLoading = true;
    update();

    try {
      final res = await profileRepository.updateAvatar(
        imageFile: profileImage.value!,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);

        // ✅ Save raw avatar path to local storage
        final prefs = await SharedPreferences.getInstance();
        final userDataString = prefs.getString(AppConst.userData);
        if (userDataString != null) {
          final userData = jsonDecode(userDataString);
          userData['avatar'] = data['avatar'];
          await prefs.setString(AppConst.userData, jsonEncode(userData));
          await prefs.setString(AppConst.avatar, data['avatar'].toString());
        }

        profileImage.value = null;
        isEditing = false;

        showSuccessToast('profile_image_updated_successfully'.tr);

        // ✅ Refresh from server to confirm
        await fetchProfileFromApi();
      } else {
        showErrorToast('failed_to_update_profile_image'.tr);
      }
    } catch (e) {
      debugPrint('❌ updateProfile error: $e');
      showErrorToast('something_wrong'.tr);
    }

    isLoading = false;
    update();
  }

  void toggleEdit() {
    isEditing = !isEditing;
    update();
  }

  @override
  void onClose() {
    nickNameController.dispose();
    licenseController.dispose();
    super.onClose();
  }
}


/*
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';
import '../../../utils/app_const/app_const.dart';
import '../../../utils/toast_message/toast_message.dart';
import '../../../core/service/api_url.dart';
import 'profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository profileRepository = ProfileRepository();

  final Rx<File?> profileImage = Rx<File?>(null);
  final Rx<UserModel?> userProfile = Rx<UserModel?>(null);

  final nickNameController = TextEditingController();
  final licenseController = TextEditingController();

  bool isEditing = false;
  bool isLoading = false;

  */
/*@override
  void onInit() {
    super.onInit();
    loadUserData();        // ✅ instant UI from local
    fetchProfileFromApi(); // ✅ fresh data from server
  }*//*

  @override
  void onInit() {
    super.onInit();
    _initProfile();
  }

  Future<void> _initProfile() async {
    await loadUserData(); // load local first

    // ✅ Only fetch from API if token exists
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConst.token);
    if (token != null && token.isNotEmpty) {
      await fetchProfileFromApi();
    }
  }

  /// ✅ Load local data first for instant display

  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(AppConst.userData);

      // ✅ Debug — see exactly what is saved
      debugPrint('📦 userData from prefs: $userDataString');
      debugPrint('📦 avatar from prefs: ${prefs.getString(AppConst.avatar)}');
      debugPrint('📦 nickName from prefs: ${prefs.getString(AppConst.nickName)}');

      if (userDataString != null && userDataString.isNotEmpty) {
        _applyUserData(jsonDecode(userDataString));
      } else {
        final nickName = prefs.getString(AppConst.nickName) ?? '';
        final licenceId = prefs.getString(AppConst.licenceId) ?? '';
        final avatar = prefs.getString(AppConst.avatar);

        debugPrint('📦 fallback — nickName: $nickName, licenceId: $licenceId, avatar: $avatar');

        if (nickName.isNotEmpty || licenceId.isNotEmpty) {
          _applyUserData({
            'nick_name': nickName,
            'licence_id': licenceId,
            'avatar': avatar,
          });
        }
      }
    } catch (e) {
      debugPrint('❌ loadUserData error: $e');
    }
    update();
  }
*/
/*  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(AppConst.userData);
      final avatar = prefs.getString(AppConst.avatar); // ✅ add this

      if (userDataString != null && userDataString.isNotEmpty) {
        _applyUserData(jsonDecode(userDataString));
      } else {
        final nickName = prefs.getString(AppConst.nickName) ?? '';
        final licenceId = prefs.getString(AppConst.licenceId) ?? '';
        if (nickName.isNotEmpty || licenceId.isNotEmpty) {
          _applyUserData({
            'nick_name': nickName,
            'licence_id': licenceId,
            //'avatar': null,
            'avatar': avatar,
          });
        }
      }
    } catch (e) {
      debugPrint('❌ loadUserData error: $e');
    }
    update();
  }*//*


  /// ✅ Fetch fresh profile from /auth/me

  Future<void> fetchProfileFromApi() async {
    isLoading = true;
    update();

    try {
      final res = await profileRepository.getProfile();
      debugPrint('📡 fetchProfileFromApi status: ${res.statusCode}');
      debugPrint('📡 fetchProfileFromApi body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);

        // ✅ /auth/me might return { user: {...} } or flat — handle both
        final user = data['user'] ?? data;

        // ✅ Save fresh data locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConst.userData, jsonEncode(user));
        await prefs.setString(AppConst.nickName, user['nick_name'] ?? '');
        await prefs.setString(AppConst.licenceId, user['licence_id'] ?? '');
        if (user['avatar'] != null) {
          await prefs.setString(AppConst.avatar, user['avatar'].toString());
        }

        _applyUserData(user);
      }
    } catch (e) {
      debugPrint('❌ fetchProfileFromApi error: $e');
    }

    isLoading = false;
    update();
  }
  */
/*Future<void> fetchProfileFromApi() async {
    isLoading = true;
    update();

    try {
      final res = await profileRepository.getProfile();

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);

        // ✅ Save fresh data locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConst.userData, jsonEncode(data));
        await prefs.setString(AppConst.nickName, data['nick_name'] ?? '');
        await prefs.setString(AppConst.licenceId, data['licence_id'] ?? '');

        _applyUserData(data);
      }
    } catch (e) {
      debugPrint('❌ fetchProfileFromApi error: $e');
    }

    isLoading = false;
    update();
  }*//*


  /// ✅ Apply data to UI
  void _applyUserData(Map<String, dynamic> data) {
    // ✅ Build full avatar URL from server path
    final rawAvatar = data['avatar'];
    final avatarUrl = _buildAvatarUrl(rawAvatar);

    userProfile.value = UserModel(
      nickName: data['nick_name'] ?? '',
      licenceId: data['licence_id'] ?? '',
      avatar: avatarUrl,
    );

    nickNameController.text = userProfile.value!.nickName;
    licenseController.text = userProfile.value!.licenceId;
  }

  /// ✅ Build full avatar URL
  /// handles: null, already full URL, or server relative path
  String? _buildAvatarUrl(dynamic rawAvatar) {
    if (rawAvatar == null || rawAvatar.toString().isEmpty) return null;

    final avatar = rawAvatar.toString();

    // Already a full URL
    if (avatar.startsWith('http')) return avatar;

    // Server returns path like: \uploads\users\avatar_xxx.jpg
    // Convert backslashes to forward slashes
    final cleanPath = avatar.replaceAll('\\', '/');

    return '${ApiUrl.baseUrl}/$cleanPath';
  }

  /// 📷 Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null) {
        profileImage.value = File(picked.path);
        update();
      }
    } catch (e) {
      debugPrint('❌ Image pick error: $e');
      showErrorToast('something_wrong'.tr);
    }
  }

  /// ✅ Upload avatar to server
  Future<void> updateProfile() async {
    if (profileImage.value == null) {
      showErrorToast('please_select_an_image_first'.tr);
      return;
    }

    isLoading = true;
    update();

    try {
      final res = await profileRepository.updateAvatar(
        imageFile: profileImage.value!,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final newAvatar = _buildAvatarUrl(data['avatar']); // ✅ full URL

        // ✅ Update local storage
        final prefs = await SharedPreferences.getInstance();
        final userDataString = prefs.getString(AppConst.userData);
        if (userDataString != null) {
          final userData = jsonDecode(userDataString);
          userData['avatar'] = data['avatar']; // save raw path
          await prefs.setString(AppConst.userData, jsonEncode(userData));
        }

        // ✅ Update UI
        userProfile.value = userProfile.value!.copyWith(avatar: newAvatar);
        profileImage.value = null;
        isEditing = false;

        showSuccessToast('profile_image_updated_successfully'.tr);

        // ✅ Refresh from server to confirm
        await fetchProfileFromApi();

      } else {
        showErrorToast('failed_to_update_profile_image'.tr);
      }
    } catch (e) {
      debugPrint('❌ updateProfile error: $e');
      showErrorToast('something_wrong'.tr);
    }

    isLoading = false;
    update();
  }

  void toggleEdit() {
    isEditing = !isEditing;
    update();
  }

  @override
  void onClose() {
    nickNameController.dispose();
    licenseController.dispose();
    super.onClose();
  }
}

*/


/*
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';
import '../../../utils/app_const/app_const.dart';
import 'profile_repository.dart';


import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';
import '../../../utils/app_const/app_const.dart';
import '../../../utils/toast_message/toast_message.dart';
import 'profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository profileRepository = ProfileRepository();

  final Rx<File?> profileImage = Rx<File?>(null);
  final Rx<UserModel?> userProfile = Rx<UserModel?>(null);

  final nickNameController = TextEditingController();
  final licenseController = TextEditingController();

  bool isEditing = false;
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    loadUserData();       // ✅ Load local first (instant UI)
    fetchProfileFromApi(); // ✅ Then fetch fresh from server
  }

  /// ✅ Load local data first for instant display
  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(AppConst.userData);

      if (userDataString != null && userDataString.isNotEmpty) {
        final userData = jsonDecode(userDataString);
        _applyUserData(userData);
      } else {
        // Fallback to individual keys
        final nickName = prefs.getString(AppConst.nickName) ?? '';
        final licenceId = prefs.getString(AppConst.licenceId) ?? '';
        if (nickName.isNotEmpty || licenceId.isNotEmpty) {
          _applyUserData({
            'nick_name': nickName,
            'licence_id': licenceId,
            'avatar': null,
          });
        }
      }
    } catch (e) {
      debugPrint('❌ loadUserData error: $e');
    }
    update();
  }

  /// ✅ Always fetch fresh from server
  Future<void> fetchProfileFromApi() async {
    isLoading = true;
    update();

    try {
      final res = await profileRepository.getProfile();

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);

        // ✅ Save fresh data to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConst.userData, jsonEncode(data));

        // ✅ Update nickName & licenceId keys too
        await prefs.setString(AppConst.nickName, data['nick_name'] ?? '');
        await prefs.setString(AppConst.licenceId, data['licence_id'] ?? '');

        // ✅ Apply fresh data to UI
        _applyUserData(data);
      }
    } catch (e) {
      debugPrint('❌ fetchProfileFromApi error: $e');
      // ✅ Silent fail — local data already showing
    }

    isLoading = false;
    update();
  }

  /// ✅ Update avatar
  Future<void> updateProfile() async {
    if (profileImage.value == null) {
      showErrorToast('please_select_an_image_first'.tr);
      return;
    }

    isLoading = true;
    update();

    try {
      final res = await profileRepository.updateAvatar(
        imageFile: profileImage.value!,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final newAvatar = data['avatar']; // ✅ URL from server

        // ✅ Save new avatar URL to local storage
        final prefs = await SharedPreferences.getInstance();
        final userDataString = prefs.getString(AppConst.userData);
        if (userDataString != null) {
          final userData = jsonDecode(userDataString);
          userData['avatar'] = newAvatar;
          await prefs.setString(AppConst.userData, jsonEncode(userData));
        }

        // ✅ Update UI model
        userProfile.value = userProfile.value!.copyWith(avatar: newAvatar);
        profileImage.value = null;
        isEditing = false;

        showSuccessToast('profile_image_updated_successfully'.tr);
      } else {
        showErrorToast('failed_to_update_profile_image'.tr);
      }
    } catch (e) {
      debugPrint('❌ updateProfile error: $e');
      showErrorToast('something_wrong'.tr);
    }

    isLoading = false;
    update();
  }

  @override
  void onClose() {
    nickNameController.dispose();
    licenseController.dispose();
    super.onClose();
  }
}

*/

/*
  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void toggleEdit() {
    isEditing = !isEditing;
    update();
  }

  /// ✅ Load from SharedPrefs — with fallback to individual keys
  Future<void> loadUserData() async {
    isLoading = true;
    update();

    try {
      final prefs = await SharedPreferences.getInstance();

      // ✅ Try full userData JSON first
      final userDataString = prefs.getString(AppConst.userData);

      if (userDataString != null && userDataString.isNotEmpty) {
        final userData = jsonDecode(userDataString);
        _applyUserData(userData);
      } else {
        // ✅ Fallback to individual saved keys (from login)
        final nickName = prefs.getString(AppConst.nickName) ?? '';
        final licenceId = prefs.getString(AppConst.licenceId) ?? '';

        if (nickName.isNotEmpty || licenceId.isNotEmpty) {
          _applyUserData({
            'nick_name': nickName,
            'licence_id': licenceId,
            'avatar': null,
          });
        }
      }
    } catch (e) {
      debugPrint('❌ loadUserData error: $e');
    }

    isLoading = false;
    update();
  }

  /// ✅ Single place to apply user data
  void _applyUserData(Map<String, dynamic> userData) {
    userProfile.value = UserModel.fromJson(userData);
    nickNameController.text = userProfile.value!.nickName;
    licenseController.text = userProfile.value!.licenceId;
  }

  /// 📷 Pick image
  Future<void> pickImageFromGallery() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null) {
        profileImage.value = File(picked.path);
        update();
      }
    } catch (e) {
      debugPrint('❌ Image pick error: $e');
      showErrorToast('something_wrong'.tr);
    }
  }

  /// ✅ Update avatar
  Future<void> updateProfile() async {
    if (profileImage.value == null) {
      showErrorToast('please_select_an_image_first'.tr);
      return;
    }

    isLoading = true;
    update();

    try {
      final res = await profileRepository.updateAvatar(
        imageFile: profileImage.value!,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final newAvatar = data['avatar'];

        // ✅ Update SharedPrefs
        final prefs = await SharedPreferences.getInstance();
        final userDataString = prefs.getString(AppConst.userData);
        if (userDataString != null) {
          final userData = jsonDecode(userDataString);
          userData['avatar'] = newAvatar;
          await prefs.setString(AppConst.userData, jsonEncode(userData));
        }

        // ✅ Update model with copyWith
        userProfile.value = userProfile.value!.copyWith(avatar: newAvatar);
        profileImage.value = null;
        isEditing = false;

        showSuccessToast('profile_image_updated_successfully'.tr);
      } else {
        showErrorToast('failed_to_update_profile_image'.tr);
      }
    } catch (e) {
      debugPrint('❌ updateProfile error: $e');
      showErrorToast('something_wrong'.tr);
    }

    isLoading = false;
    update();
  }
*/



/*class ProfileController extends GetxController {
  final ProfileRepository profileRepository = ProfileRepository();

  final Rx<File?> profileImage = Rx<File?>(null);
  final Rx<UserModel?> userProfile = Rx<UserModel?>(null);

  final nickNameController = TextEditingController();
  final licenseController = TextEditingController();

  bool isEditing = false;
  bool isLoading = false;

  final nickName = ''.obs;
  final licenceId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void toggleEdit() {
    isEditing = !isEditing;
    update();
  }

  /// 📷 Pick image
  Future<void> pickImageFromGallery() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      profileImage.value = File(picked.path);
      update();
    }
  }

  /// 🔹 Load user data from SharedPreferences (from login token)
  // Future<void> loadUserData() async {
  //   isLoading = true;
  //   update();
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final userDataString = prefs.getString(AppConst.userData);
  //
  //   if (userDataString != null) {
  //     final userData = jsonDecode(userDataString);
  //
  //     userProfile.value = UserModel(
  //       nickName: userData['nick_name'] ?? '',
  //       licenceId: userData['licence_id'] ?? '',
  //       avatar: userData['avatar'],
  //     );
  //
  //     final nickName=userProfile.value!.nickName;
  //     final licenceId=userProfile.value!.licenceId;
  //
  //
  //     // Set text fields (read-only)
  //     nickNameController.text = userProfile.value!.nickName;
  //     licenseController.text = userProfile.value!.licenceId;
  //   }
  //
  //   isLoading = false;
  //   update();
  // }
  //
  //

  /// 🔹 Load user data from SharedPreferences
  Future<void> loadUserData() async {
    isLoading = true;
    update();

    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(AppConst.userData);

    if (userDataString != null) {
      final userData = jsonDecode(userDataString);

      userProfile.value = UserModel(
        nickName: userData['nick_name'] ?? '',
        licenceId: userData['licence_id'] ?? '',
        avatar: userData['avatar'],
      );

      // ✅ Set variables instead of controllers
      nickName.value = userProfile.value!.nickName;
      licenceId.value = userProfile.value!.licenceId;

      // Update text controllers
      nickNameController.text = userProfile.value!.nickName;
      licenseController.text = userProfile.value!.licenceId;
    }

    isLoading = false;
    update();
  }

  /// 🔹 Update ONLY avatar
  Future<void> updateProfile() async {
    if (profileImage.value == null) {
      Get.snackbar(
        'info'.tr,
        'please_select_an_image_first'.tr,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isLoading = true;
    update();

    try {
      final res = await profileRepository.updateAvatar(
        imageFile: profileImage.value!,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);

        // Update avatar in user data
        final prefs = await SharedPreferences.getInstance();
        final userDataString = prefs.getString(AppConst.userData);

        if (userDataString != null) {
          final userData = jsonDecode(userDataString);
          userData['avatar'] = data['avatar']; // Update only avatar

          // Save updated user data
          await prefs.setString(AppConst.userData, jsonEncode(userData));
        }

        // Update local model
        userProfile.value = UserModel(
          nickName: userProfile.value!.nickName,
          licenceId: userProfile.value!.licenceId,
          avatar: data['avatar'],
        );

        profileImage.value = null;
        isEditing = false;

        Get.snackbar(
          'success'.tr,
          'profile_image_updated_successfully'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'error'.tr,
          'failed_to_update_profile_image'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'error_updating_profile: $e'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    isLoading = false;
    update();
  }

  @override
  void onClose() {
    nickNameController.dispose();
    licenseController.dispose();
    super.onClose();
  }
}*/

/*
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../share/model/user_model.dart';
import 'profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository profileRepository = ProfileRepository();

  final Rx<File?> profileImage = Rx<File?>(null);
  final Rx<UserModel?> userProfile = Rx<UserModel?>(null);

  final nickNameController = TextEditingController();
  final licenseController = TextEditingController();

  bool isEditing = false;
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    loadProfileFromBackend();
  }

  void toggleEdit() {
    isEditing = !isEditing;
    update();
  }

  /// 📷 Pick image
  Future<void> pickImageFromGallery() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      profileImage.value = File(picked.path);
      update();
    }
  }

  /// 🔹 Load profile from backend
  Future<void> loadProfileFromBackend() async {
    isLoading = true;
    update();

    final res = await profileRepository.getProfile();

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      userProfile.value = UserModel.fromJson(data);  // Changed from UserProfile

      // Read-only fields (from backend)
      nickNameController.text = userProfile.value!.nickName;
      licenseController.text = userProfile.value!.licenceId;
    }

    isLoading = false;
    update();
  }

  /// 🔹 Update ONLY avatar
  Future<void> updateProfile() async {
    if (profileImage.value == null) return;

    isLoading = true;
    update();

    final res = await profileRepository.updateAvatar(
      imageFile: profileImage.value!,
    );

    if (res.statusCode == 200 || res.statusCode == 201) {  // Added 201
      final data = jsonDecode(res.body);
      userProfile.value = UserModel.fromJson(data);  // Changed from UserProfile

      profileImage.value = null;
      isEditing = false;
    }

    isLoading = false;
    update();
  }

  @override
  void onClose() {
    nickNameController.dispose();
    licenseController.dispose();
    super.onClose();
  }
}*/
