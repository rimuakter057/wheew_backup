import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart';
import '../../feature/profile/repository/profile_repository.dart';
import '../model/user_model.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repo = ProfileRepository();
  final ImagePicker _picker = ImagePicker();
  final storage = GetStorage();

  Rx<File?> profileImage = Rx<File?>(null);
  Rx<UserModel?> userProfile = Rx<UserModel?>(null);

  final TextEditingController nickNameController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  @override
  void onClose() {
    nickNameController.dispose();
    licenseController.dispose();
    super.onClose();
  }

  void toggleEdit() {
    _isEditing = !_isEditing;
    update();
  }

  Future<void> getProfile() async {
    _isLoading = true;
    update();

    try {
      final Response response = await _repo.getProfile();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userProfile.value = UserModel.fromJson(data);

        // Set text field values
        nickNameController.text = userProfile.value?.nickName ?? '';
        licenseController.text = userProfile.value?.licenceId ?? '';

        // Update local storage
        await storage.write('nick_name', userProfile.value?.nickName);
        await storage.write('licence_id', userProfile.value?.licenceId);
        await storage.write('avatar', userProfile.value?.avatar);
      } else {
        // Load from local storage if API fails
        _loadFromStorage();
      }
    } catch (e) {
      // Load from local storage on error
      _loadFromStorage();
    }

    _isLoading = false;
    update();
  }

  void _loadFromStorage() {
    final nickName = storage.read('nick_name');
    final licenceId = storage.read('licence_id');
    final avatar = storage.read('avatar');
    final userId = storage.read('user_id');
    final role = storage.read('role');

    if (nickName != null && licenceId != null) {
      userProfile.value = UserModel(
        id: userId ?? '',
        nickName: nickName,
        licenceId: licenceId,
        avatar: avatar,
        role: role ?? 'USER',
      );

      nickNameController.text = nickName;
      licenseController.text = licenceId;
    }
  }

  Future<void> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  Future<void> updateProfile() async {
    _isLoading = true;
    update();

    final Response response = await _repo.updateProfile(
      nickName: nickNameController.text.trim(),
      licenceId: licenseController.text.trim(),
      imageFile: profileImage.value,
    );

    _isLoading = false;

    if (response.statusCode == 200 || response.statusCode == 201) {
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Refresh profile from server
      await getProfile();

      // Reset image
      profileImage.value = null;

      // Exit edit mode
      _isEditing = false;
    } else {
      final data = jsonDecode(response.body);
      Get.snackbar(
        'Error',
        data['message'] ?? 'Failed to update profile',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    update();
  }
}



/*
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart';
import '../../feature/profile/repository/profile_repository.dart';
import '../model/user_model.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repo = ProfileRepository();
  final ImagePicker _picker = ImagePicker();

  Rx<File?> profileImage = Rx<File?>(null);
  Rx<UserModel?> userProfile = Rx<UserModel?>(null);

  final TextEditingController nickNameController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  @override
  void onClose() {
    nickNameController.dispose();
    licenseController.dispose();
    super.onClose();
  }

  void toggleEdit() {
    _isEditing = !_isEditing;
    update();
  }

  Future<void> getProfile() async {
    _isLoading = true;
    update();

    final Response response = await _repo.getProfile();

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      userProfile.value = UserModel.fromJson(data);

      // Set text field values
      nickNameController.text = userProfile.value?.nickName ?? '';
      licenseController.text = userProfile.value?.licenceId ?? '';
    } else {
      Get.snackbar(
        'Error',
        'Failed to load profile',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    _isLoading = false;
    update();
  }

  Future<void> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  Future<void> updateProfile() async {
    _isLoading = true;
    update();

    final Response response = await _repo.updateProfile(
      nickName: nickNameController.text.trim(),
      licenceId: licenseController.text.trim(),
      imageFile: profileImage.value,
    );

    _isLoading = false;

    if (response.statusCode == 200) {
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Refresh profile
      await getProfile();

      // Reset image
      profileImage.value = null;

      // Exit edit mode
      _isEditing = false;
      update();
    } else {
      Get.snackbar(
        'Error',
        'Failed to update profile',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    update();
  }
}*/
