import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';
import '../../../utils/app_const/app_const.dart';
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

      // Set text fields (read-only)
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
        'Info',
        'Please select an image first',
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
          'Success',
          'Profile image updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to update profile image',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error updating profile: $e',
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
}



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
