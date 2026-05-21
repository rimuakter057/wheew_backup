import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';
import '../../../utils/app_const/app_const.dart';
import '../../../utils/toast_message/toast_message.dart';
import '../../../core/service/api_url.dart';
import 'profile_repository.dart';
import 'package:image_cropper/image_cropper.dart';

class ProfileController extends GetxController {
  final ProfileRepository profileRepository = ProfileRepository();

  final Rx<File?> profileImage = Rx<File?>(null);
  final Rx<File?> tempCroppedImage = Rx<File?>(null);
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
    isEditing=false;
    update();
    await loadUserData();
    tempCroppedImage.value = null;
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
            'rating': 0,


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



  // ✅ Apply data to UI
  // void _applyUserData(Map<String, dynamic> data) {
  //   final avatarUrl = _buildAvatarUrl(data['avatar']);
  //
  //   userProfile.value = UserModel(
  //     nickName: data['nick_name'] ?? '',
  //     licenceId: data['licence_id'] ?? '',
  //     avatar: avatarUrl,
  //
  //   );
  //
  //   nickNameController.text = userProfile.value!.nickName;
  //   licenseController.text = userProfile.value!.licenceId;
  //   update(); // ✅ force UI refresh
  // }
  //
  //
  //







// ✅ Apply data to UI
  void _applyUserData(Map<String, dynamic> data) {
    final avatarUrl = _buildAvatarUrl(data['avatar']);

    userProfile.value = UserModel(
      id: data['id'],
      nickName: data['nick_name'] ?? '',
      licenceId: data['licence_id'] ?? '',
      avatar: avatarUrl,
      rating: (data['rating'] is int)
          ? (data['rating'] as int).toDouble()
          : (data['rating'] is double)
          ? data['rating'] as double
          : 0.0,// ✅ Fix: rating যোগ করা হলো
      designation: data['designation'],          // ✅ Fix: designation যোগ করা হলো
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








  Future<void> pickImageFromGallery() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: picked.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: AppColors.blue,
              toolbarWidgetColor: Colors.white,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              title: 'Crop Image',
            ),
          ],
        );

        if (croppedFile != null) {
          tempCroppedImage.value = File(croppedFile.path); // ✅ temp এ রাখো
          update();
        }
      }
    } catch (e) {
      debugPrint('❌ Image pick error: $e');
      showErrorToast('something_wrong'.tr);
    }
  }

  Future<void> updateProfile() async {
    if (tempCroppedImage.value == null) { // ✅ tempCroppedImage check
      showErrorToast('please_select_an_image_first'.tr);
      return;
    }

    isLoading = true;
    update();

    try {
      final res = await profileRepository.updateAvatar(
        imageFile: tempCroppedImage.value!, // ✅ temp থেকে upload
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);

        final prefs = await SharedPreferences.getInstance();
        final userDataString = prefs.getString(AppConst.userData);
        if (userDataString != null) {
          final userData = jsonDecode(userDataString);
          userData['avatar'] = data['avatar'];
          await prefs.setString(AppConst.userData, jsonEncode(userData));
          await prefs.setString(AppConst.avatar, data['avatar'].toString());
        }

        tempCroppedImage.value = null; // ✅ success হলে clear
        isEditing = false;

        showSuccessToast('profile_image_updated_successfully'.tr);
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


  // Future<void> pickImageFromGallery() async
  // {
  //   try {
  //     final picked = await ImagePicker().pickImage(
  //       source: ImageSource.gallery,
  //       imageQuality: 80,
  //     );
  //
  //     if (picked != null) {
  //       // ✅ Crop screen open হবে
  //       final croppedFile = await ImageCropper().cropImage(
  //         sourcePath: picked.path,
  //         uiSettings: [
  //           AndroidUiSettings(
  //             toolbarTitle: 'Crop Image',
  //             toolbarColor: AppColors.blue,
  //             toolbarWidgetColor: Colors.white,
  //             lockAspectRatio: false,
  //           ),
  //           IOSUiSettings(
  //             title: 'Crop Image',
  //           ),
  //         ],
  //       );
  //
  //       // ✅ Crop confirm করলে save, cancel করলে skip
  //       // if (croppedFile != null) {
  //       //   profileImage.value = File(croppedFile.path);
  //       //   update();
  //       // }
  //       //
  //       //
  //
  //       if (croppedFile != null) {
  //         tempCroppedImage.value = File(croppedFile.path); // ✅ temp এ রাখো
  //         update();
  //       }
  //
  //
  //
  //     }
  //   } catch (e) {
  //     debugPrint('❌ Image pick error: $e');
  //     showErrorToast('something_wrong'.tr);
  //   }
  // }

  // ✅ Upload avatar to server
  // Future<void> updateProfile() async {
  //   if (profileImage.value == null) {
  //     showErrorToast('please_select_an_image_first'.tr);
  //     return;
  //   }
  //
  //   isLoading = true;
  //   update();
  //
  //   try {
  //     final res = await profileRepository.updateAvatar(
  //       imageFile: profileImage.value!,
  //     );
  //
  //     if (res.statusCode == 200 || res.statusCode == 201) {
  //       final data = jsonDecode(res.body);
  //
  //       // ✅ Save raw avatar path to local storage
  //       final prefs = await SharedPreferences.getInstance();
  //       final userDataString = prefs.getString(AppConst.userData);
  //       if (userDataString != null) {
  //         final userData = jsonDecode(userDataString);
  //         userData['avatar'] = data['avatar'];
  //         await prefs.setString(AppConst.userData, jsonEncode(userData));
  //         await prefs.setString(AppConst.avatar, data['avatar'].toString());
  //       }
  //
  //       profileImage.value = null;
  //       isEditing = false;
  //
  //       showSuccessToast('profile_image_updated_successfully'.tr);
  //
  //       // ✅ Refresh from server to confirm
  //       await fetchProfileFromApi();
  //     } else {
  //       showErrorToast('failed_to_update_profile_image'.tr);
  //     }
  //   } catch (e) {
  //     debugPrint('❌ updateProfile error: $e');
  //     showErrorToast('something_wrong'.tr);
  //   }
  //
  //   isLoading = false;
  //   update();
  // }

  void toggleEdit() {
    isEditing = !isEditing;
    if (!isEditing) {
      tempCroppedImage.value = null; // ✅ edit বন্ধ হলে clear
    }
    update();
  }

  @override
  void onClose() {
    nickNameController.dispose();
    licenseController.dispose();
    super.onClose();
  }
}