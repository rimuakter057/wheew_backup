import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';
import '../../../utils/app_const/app_const.dart';
import '../../../utils/language/app_string.dart';
import '../../../utils/toast_message/toast_message.dart';
import '../../../core/service/api_url.dart';
import 'profile_repository.dart';
import 'package:image_cropper/image_cropper.dart';

class ProfileController extends GetxController {
  final ProfileRepository profileRepository = ProfileRepository();

  final Rx<File?> profileImage = Rx<File?>(null);
  final Rx<File?> tempCroppedImage = Rx<File?>(null); // gallery থেকে crop করা temp image
  final Rx<UserModel?> userProfile = Rx<UserModel?>(null);

  final nickNameController = TextEditingController();

  final licenseController = TextEditingController();
  final vehicleTypeController = TextEditingController();
  final vehicleModelController = TextEditingController();
  final vehicleColorController = TextEditingController();

  bool isEditing = false;
  bool isLoading = false;

  // Snapshot of what's actually saved on the server — NOT the live text
  // controllers, which change the instant the user picks a value in edit
  // mode. Locking must only kick in after a save + reload, not the moment
  // a still-unsaved selection is made.
  String _savedVehicleType = '';
  String _savedVehicleModel = '';
  String _savedVehicleColor = '';

  // Each vehicle field locks independently once it already has a saved
  // value — it can only be set once, then stays read-only on every later load.
  bool get isVehicleTypeLocked => _savedVehicleType.isNotEmpty;
  bool get isVehicleModelLocked => _savedVehicleModel.isNotEmpty;
  bool get isVehicleColorLocked => _savedVehicleColor.isNotEmpty;

  Future<void> _initProfile() async {
    await loadUserData();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConst.token);
    if (token != null && token.isNotEmpty) {
      await fetchProfileFromApi();
    }
  }

  /// Screen এ ঢুকলে profile refresh করো
  Future<void> reloadProfile() async {
    isEditing = false;
    update();
    update(['vehicle_fields']); // vehicle fields ও reset করো
    await loadUserData();
    tempCroppedImage.value = null;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConst.token);
    if (token != null && token.isNotEmpty) {
      await fetchProfileFromApi();
    }
  }

  /// Local SharedPreferences থেকে data load করো (instant display)
  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(AppConst.userData);

      if (userDataString != null && userDataString.isNotEmpty) {
        _applyUserData(jsonDecode(userDataString));
      } else {
        // Fallback — individual keys থেকে নাও
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

  /// Server থেকে fresh profile fetch করো
  Future<void> fetchProfileFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConst.token);

    // Token না থাকলে API call করো না
    if (token == null || token.isEmpty) {
      debugPrint('⚠️ No token — skipping fetchProfileFromApi');
      return;
    }

    isLoading = true;
    update();

    try {
      final res = await profileRepository.getProfile();

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final user = data['user'] ?? data;

        // Local cache update করো
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

  /// API response বা local data দিয়ে controller ও userProfile update করো
  void _applyUserData(Map<String, dynamic> data) {
    debugPrint('ℹ️ [DEBUG] ProfileController._applyUserData called. Keys in data: ${data.keys.toList()}');
    debugPrint('ℹ️ [DEBUG] raw documents in data: ${data['documents']}');
    final avatarUrl = _buildAvatarUrl(data['avatar']);

    userProfile.value = UserModel(
      id: data['id'],
      email: data['email'],
      nickName: data['nick_name'] ?? '',
      licenceId: data['licence_id'] ?? '',
      avatar: avatarUrl,
      rating: (data['rating'] is int)
          ? (data['rating'] as int).toDouble()
          : (data['rating'] is double)
          ? data['rating'] as double
          : 0.0,
      totalRatings: data['totalRatings'] ?? data['totalRating'] ?? 0, // ✅ NEW
      designation: data['designation'],
      role: data['role'],
      vehicleType: data['vehicle_type'],
      vehicleModel: data['vehicle_model'],
      vehicleColor: data['vehicle_color'],
      isVehicleVerified: data['is_vehicle_verified'] ?? false,
      isVehicleOwnershipDocumentSubmitted:
      data['is_vehicle_ownership_document_submitted'] ?? false,
      licenseNoVerified: data['license_no_verified'] ?? false,
      country: data['country'], // ✅ NEW
      city: data['city'],       // ✅ NEW
      documents: () {
        final raw = data['documents'];
        if (raw is List) {
          return raw
              .map<Map<String, dynamic>>((e) {
                if (e is Map) {
                  return <String, dynamic>{
                    'document_type': (e['document_type'] ?? e['documentType'] ?? '').toString(),
                    'daysUntilExpiry': (e['daysUntilExpiry'] ?? e['days_until_expiry'] ?? 0) is num
                        ? (e['daysUntilExpiry'] ?? e['days_until_expiry'] ?? 0).toInt()
                        : 0,
                  };
                }
                return <String, dynamic>{};
              })
              .toList();
        }
        return <Map<String, dynamic>>[];
      }(),
    );

    // Read-only fields সবসময় update করো
    nickNameController.text = userProfile.value!.nickName;
    licenseController.text = userProfile.value!.licenceId;

    // Vehicle fields — edit mode এ user type করছে, তাই reset করো না
    if (!isEditing) {
      _savedVehicleType = userProfile.value!.vehicleType ?? '';
      _savedVehicleModel = userProfile.value!.vehicleModel ?? '';
      _savedVehicleColor = userProfile.value!.vehicleColor ?? '';
      vehicleTypeController.text = _savedVehicleType;
      vehicleModelController.text = _savedVehicleModel;
      vehicleColorController.text = _savedVehicleColor;
      update(['vehicle_fields']); // ✅ vehicle fields আলাদা rebuild
    }

    update();
  }

  /// Avatar URL build করো — relative path হলে baseUrl যোগ করো
  String? _buildAvatarUrl(dynamic rawAvatar) {
    if (rawAvatar == null || rawAvatar.toString().isEmpty) return null;
    final avatar = rawAvatar.toString();
    if (avatar.startsWith('http')) return avatar;
    final cleanPath = avatar.replaceAll('\\', '/');
    return '${ApiUrl.baseUrl}/$cleanPath';
  }

  /// Gallery থেকে image pick করে crop করো
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
            IOSUiSettings(title: 'Crop Image'),
          ],
        );

        if (croppedFile != null) {
          tempCroppedImage.value = File(croppedFile.path);
          update();
        }
      }
    } catch (e) {
      debugPrint('❌ Image pick error: $e');
      showErrorToast(AppStrings.somethingWrong.tr);
    }
  }






  /// Profile update — avatar + vehicle fields একসাথে PATCH /users
  Future<void> updateProfile() async {
    final hasImage = tempCroppedImage.value != null;

    // Each field locks independently once set — but any of the three
    // having a value (or just being filled in this session) still counts
    // as "something to save".
    final hasVehicleData = vehicleTypeController.text.isNotEmpty ||
        vehicleModelController.text.isNotEmpty ||
        vehicleColorController.text.isNotEmpty;

    debugPrint('🔄 updateProfile called');
    debugPrint('📸 hasImage: $hasImage');
    debugPrint('🚗 hasVehicleData: $hasVehicleData');
    debugPrint('🚗 vehicleType: ${vehicleTypeController.text}');

    if (!hasImage && !hasVehicleData) {
      debugPrint('⚠️ Nothing to update — returning');
      showErrorToast(AppStrings.nothingToUpdate.tr);
      return;
    }

    isLoading = true;
    update();

    try {
      final res = await profileRepository.updateAvatar(
        imageFile: tempCroppedImage.value,
        vehicleType: vehicleTypeController.text,
        vehicleModel: vehicleModelController.text,
        vehicleColor: vehicleColorController.text,
      );

      debugPrint('📡 updateProfile statusCode: ${res.statusCode}');
      debugPrint('📡 updateProfile body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        tempCroppedImage.value = null;
        isEditing = false;
        showSuccessToast(AppStrings.profileUpdatedSuccessfully.tr);
        await fetchProfileFromApi();
      } else {
        debugPrint('❌ Update failed: ${res.statusCode} — ${res.body}');
        showErrorToast(AppStrings.failedToUpdateProfile.tr);
      }
    } catch (e) {
      debugPrint('❌ updateProfile exception: $e');
      showErrorToast(AppStrings.somethingWrong.tr);
    }

    isLoading = false;
    update();
  }




  void setVehicleType(String? value) {
    vehicleTypeController.text = value ?? '';
    update(['vehicle_fields']); // ✅ এইটা মিসিং ছিল, এই কারণেই UI-তে selection দেখা যাচ্ছিল না
  }

  void setVehicleModel(String? value) {
    vehicleModelController.text = value ?? '';
    update(['vehicle_fields']);
  }

  /// Edit mode toggle — off হলে temp image clear করো
  void toggleEdit() {
    isEditing = !isEditing;
    if (!isEditing) {
      tempCroppedImage.value = null;
    }
    update(['vehicle_fields']); // vehicle fields rebuild
    update(); // বাকি সব rebuild
  }

  // /// Edit mode toggle — off হলে temp image clear করো
  // void toggleEdit() {
  //   isEditing = !isEditing;
  //   if (!isEditing) {
  //     tempCroppedImage.value = null;
  //   }
  //   update(['vehicle_fields']); // vehicle fields rebuild
  //   update(); // বাকি সব rebuild
  // }

  @override
  void onClose() {
    nickNameController.dispose();
    licenseController.dispose();
    vehicleTypeController.dispose();
    vehicleModelController.dispose();
    vehicleColorController.dispose();
    super.onClose();
  }
}