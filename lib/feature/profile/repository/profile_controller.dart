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
}