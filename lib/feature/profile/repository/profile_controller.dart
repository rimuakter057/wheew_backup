// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:platchatapp/utils/color/app_colors.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'user_model.dart';
// import '../../../utils/app_const/app_const.dart';
// import '../../../utils/toast_message/toast_message.dart';
// import '../../../core/service/api_url.dart';
// import 'profile_repository.dart';
// import 'package:image_cropper/image_cropper.dart';
//
// class ProfileController extends GetxController {
//   final ProfileRepository profileRepository = ProfileRepository();
//
//   final Rx<File?> profileImage = Rx<File?>(null);
//   final Rx<File?> tempCroppedImage = Rx<File?>(null);
//   final Rx<UserModel?> userProfile = Rx<UserModel?>(null);
//
//
//
//   final nickNameController = TextEditingController();
//   final licenseController = TextEditingController();
//   final vehicleTypeController = TextEditingController();   // ✅ new
//   final vehicleModelController = TextEditingController();  // ✅ new
//   final vehicleColorController = TextEditingController();   // ✅ new
//
//
//   bool isEditing = false;
//   bool isLoading = false;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _initProfile();
//   }
//
//   Future<void> _initProfile() async {
//     await loadUserData();
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString(AppConst.token);
//     if (token != null && token.isNotEmpty) {
//       await fetchProfileFromApi();
//     }
//   }
//
//   // ✅ Reload every time profile screen opens
//   Future<void> reloadProfile() async {
//     isEditing=false;
//     update();
//     await loadUserData();
//     tempCroppedImage.value = null;
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString(AppConst.token);
//     if (token != null && token.isNotEmpty) {
//       await fetchProfileFromApi();
//     }
//   }
//
//   // ✅ Load local data first for instant display
//   Future<void> loadUserData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userDataString = prefs.getString(AppConst.userData);
//
//       if (userDataString != null && userDataString.isNotEmpty) {
//         _applyUserData(jsonDecode(userDataString));
//       } else {
//
//
//
//
//
//         // ✅ Fallback to individual keys
//         final nickName = prefs.getString(AppConst.nickName) ?? '';
//         final licenceId = prefs.getString(AppConst.licenceId) ?? '';
//         final avatar = prefs.getString(AppConst.avatar);
//
//         if (nickName.isNotEmpty || licenceId.isNotEmpty) {
//           _applyUserData({
//             'nick_name': nickName,
//             'licence_id': licenceId,
//             'avatar': avatar,
//             'rating': 0,
//
//
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('❌ loadUserData error: $e');
//     }
//     update();
//   }
//
//   // ✅ Fetch fresh profile from /auth/me
//
//   Future<void> fetchProfileFromApi() async {
//     // ✅ Check token exists before calling API
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString(AppConst.token);
//
//     if (token == null || token.isEmpty) {
//       debugPrint('⚠️ No token — skipping fetchProfileFromApi');
//       return; // ✅ Don't call API without token
//     }
//
//     isLoading = true;
//     update();
//
//     try {
//       final res = await profileRepository.getProfile();
//       debugPrint('📡 fetchProfileFromApi status: ${res.statusCode}');
//       debugPrint('📡 fetchProfileFromApi body: ${res.body}');
//
//       if (res.statusCode == 200 || res.statusCode == 201) {
//         final data = jsonDecode(res.body);
//         final user = data['user'] ?? data;
//
//         await prefs.setString(AppConst.userData, jsonEncode(user));
//         await prefs.setString(AppConst.nickName, user['nick_name'] ?? '');
//         await prefs.setString(AppConst.licenceId, user['licence_id'] ?? '');
//         if (user['avatar'] != null) {
//           await prefs.setString(AppConst.avatar, user['avatar'].toString());
//         }
//
//         _applyUserData(user);
//       }
//     } catch (e) {
//       debugPrint('❌ fetchProfileFromApi error: $e');
//     }
//
//     isLoading = false;
//     update();
//   }
//
//   // void _applyUserData(Map<String, dynamic> data) {
//   //   final avatarUrl = _buildAvatarUrl(data['avatar']);
//   //
//   //   userProfile.value = UserModel(
//   //     id: data['id'],
//   //     nickName: data['nick_name'] ?? '',
//   //     licenceId: data['licence_id'] ?? '',
//   //     avatar: avatarUrl,
//   //     rating: (data['rating'] is int)
//   //         ? (data['rating'] as int).toDouble()
//   //         : (data['rating'] is double)
//   //         ? data['rating'] as double
//   //         : 0.0,// ✅ Fix: rating যোগ করা হলো
//   //     designation: data['designation'],          // ✅ Fix: designation যোগ করা হলো
//   //   );
//   //
//   //   nickNameController.text = userProfile.value!.nickName;
//   //   licenseController.text = userProfile.value!.licenceId;
//   //   update(); // ✅ force UI refresh
//   // }
//
//
//
//
//
//
//   void _applyUserData(Map<String, dynamic> data) {
//     final avatarUrl = _buildAvatarUrl(data['avatar']);
//
//     userProfile.value = UserModel(
//       id: data['id'],
//       email: data['email'],
//       nickName: data['nick_name'] ?? '',
//       licenceId: data['licence_id'] ?? '',
//       avatar: avatarUrl,
//
//       rating: (data['rating'] is int)
//           ? (data['rating'] as int).toDouble()
//           : (data['rating'] is double)
//           ? data['rating'] as double
//           : 0.0,
//
//       designation: data['designation'],
//       role: data['role'], // 🔥 ADD THIS
//
//       // 🔥 VEHICLE DATA ADD HERE (IMPORTANT)
//       vehicleType: data['vehicle_type'],
//       vehicleModel: data['vehicle_model'],
//       vehicleColor: data['vehicle_color'],
//
//       isVehicleVerified: data['is_vehicle_verified'] ?? false,
//       isVehicleOwnershipDocumentSubmitted:
//       data['is_vehicle_ownership_document_submitted'] ?? false,
//
//       licenseNoVerified: data['license_no_verified'] ?? false,
//     );
//
//     nickNameController.text = userProfile.value!.nickName;
//     licenseController.text = userProfile.value!.licenceId;
//
//     vehicleTypeController.text = userProfile.value!.vehicleType ?? '';     // ✅ new
//     vehicleModelController.text = userProfile.value!.vehicleModel ?? '';   // ✅ new
//     vehicleColorController.text = userProfile.value!.vehicleColor ?? '';   // ✅ new
//
//     if (!isEditing) {
//       vehicleTypeController.text = userProfile.value!.vehicleType ?? '';
//       vehicleModelController.text = userProfile.value!.vehicleModel ?? '';
//       vehicleColorController.text = userProfile.value!.vehicleColor ?? '';
//     }
//
//     update();
//   }
//
//
//
//
//   String? _buildAvatarUrl(dynamic rawAvatar) {
//     if (rawAvatar == null || rawAvatar.toString().isEmpty) return null;
//
//     final avatar = rawAvatar.toString();
//     if (avatar.startsWith('http')) return avatar;
//
//     final cleanPath = avatar.replaceAll('\\', '/');
//     return '${ApiUrl.baseUrl}/$cleanPath';
//   }
//
//   Future<void> pickImageFromGallery() async {
//     try {
//       final picked = await ImagePicker().pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 80,
//       );
//
//       if (picked != null) {
//         final croppedFile = await ImageCropper().cropImage(
//           sourcePath: picked.path,
//           uiSettings: [
//             AndroidUiSettings(
//               toolbarTitle: 'Crop Image',
//               toolbarColor: AppColors.blue,
//               toolbarWidgetColor: Colors.white,
//               lockAspectRatio: false,
//             ),
//             IOSUiSettings(
//               title: 'Crop Image',
//             ),
//           ],
//         );
//
//         if (croppedFile != null) {
//           tempCroppedImage.value = File(croppedFile.path); // ✅ temp এ রাখো
//           update();
//         }
//       }
//     } catch (e) {
//       debugPrint('❌ Image pick error: $e');
//       showErrorToast('something_wrong'.tr);
//     }
//   }
//
//   // Future<void> updateProfile() async {
//   //   if (tempCroppedImage.value == null) { // ✅ tempCroppedImage check
//   //     showErrorToast('please_select_an_image_first'.tr);
//   //     return;
//   //   }
//   //
//   //   isLoading = true;
//   //   update();
//   //
//   //   try {
//   //     final res = await profileRepository.updateAvatar(
//   //       imageFile: tempCroppedImage.value!, // ✅ temp থেকে upload
//   //     );
//   //
//   //     if (res.statusCode == 200 || res.statusCode == 201) {
//   //       final data = jsonDecode(res.body);
//   //
//   //       final prefs = await SharedPreferences.getInstance();
//   //       final userDataString = prefs.getString(AppConst.userData);
//   //       if (userDataString != null) {
//   //         final userData = jsonDecode(userDataString);
//   //         userData['avatar'] = data['avatar'];
//   //         await prefs.setString(AppConst.userData, jsonEncode(userData));
//   //         await prefs.setString(AppConst.avatar, data['avatar'].toString());
//   //       }
//   //
//   //       tempCroppedImage.value = null; // ✅ success হলে clear
//   //       isEditing = false;
//   //
//   //       showSuccessToast('profile_image_updated_successfully'.tr);
//   //       await fetchProfileFromApi();
//   //     } else {
//   //       showErrorToast('failed_to_update_profile_image'.tr);
//   //     }
//   //   } catch (e) {
//   //     debugPrint('❌ updateProfile error: $e');
//   //     showErrorToast('something_wrong'.tr);
//   //   }
//   //
//   //   isLoading = false;
//   //   update();
//   // }
//
//
//
//
//
//
//
//
//   Future<void> updateProfile() async {
//     // ✅ image বা vehicle data — যেকোনো একটা থাকলেই চলবে
//     final hasImage = tempCroppedImage.value != null;
//     final hasVehicleData =
//         vehicleTypeController.text.isNotEmpty ||
//             vehicleModelController.text.isNotEmpty ||
//             vehicleColorController.text.isNotEmpty;
//
//     if (!hasImage && !hasVehicleData) {
//       showErrorToast('nothing_to_update'.tr);
//       return;
//     }
//
//     isLoading = true;
//     update();
//
//     try {
//       final res = await profileRepository.updateAvatar(
//         imageFile: tempCroppedImage.value,          // null হলেও চলবে
//         vehicleType: vehicleTypeController.text,
//         vehicleModel: vehicleModelController.text,
//         vehicleColor: vehicleColorController.text,
//       );
//
//       if (res.statusCode == 200 || res.statusCode == 201) {
//         tempCroppedImage.value = null;
//         isEditing = false;
//         showSuccessToast('profile_updated_successfully'.tr);
//         await fetchProfileFromApi();
//       } else {
//         showErrorToast('failed_to_update_profile'.tr);
//       }
//     } catch (e) {
//       debugPrint('❌ updateProfile error: $e');
//       showErrorToast('something_wrong'.tr);
//     }
//
//     isLoading = false;
//     update();
//   }
//
//
//
//
//
//
//   //
//   // void toggleEdit() {
//   //   isEditing = !isEditing;
//   //   if (!isEditing) {
//   //     tempCroppedImage.value = null; // ✅ edit বন্ধ হলে clear
//   //   }
//   //   update();
//   // }
//
//
//   void toggleEdit() {
//     isEditing = !isEditing;
//     if (!isEditing) {
//       tempCroppedImage.value = null;
//     }
//     update(['vehicle_fields']); // ✅ শুধু vehicle fields rebuild
//     update(); // বাকি সব
//   }
//
//
//
//   @override
//   void onClose() {
//     nickNameController.dispose();
//     licenseController.dispose();
//
//     vehicleTypeController.dispose();   // ✅ new
//     vehicleModelController.dispose();  // ✅ new
//     vehicleColorController.dispose();  // ✅ new
//
//     super.onClose();
//   }
// }



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

  // @override
  // void onInit() {
  //   super.onInit();
  //   //_initProfile();
  // }

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
      designation: data['designation'],
      role: data['role'],
      vehicleType: data['vehicle_type'],
      vehicleModel: data['vehicle_model'],
      vehicleColor: data['vehicle_color'],
      isVehicleVerified: data['is_vehicle_verified'] ?? false,
      isVehicleOwnershipDocumentSubmitted:
      data['is_vehicle_ownership_document_submitted'] ?? false,
      licenseNoVerified: data['license_no_verified'] ?? false,
    );

    // Read-only fields সবসময় update করো
    nickNameController.text = userProfile.value!.nickName;
    licenseController.text = userProfile.value!.licenceId;

    // Vehicle fields — edit mode এ user type করছে, তাই reset করো না

    if (!isEditing) {
      vehicleTypeController.text = userProfile.value!.vehicleType ?? '';
      vehicleModelController.text = userProfile.value!.vehicleModel ?? '';
      vehicleColorController.text = userProfile.value!.vehicleColor ?? '';
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
    final hasVehicleData =
        vehicleTypeController.text.isNotEmpty ||
            vehicleModelController.text.isNotEmpty ||
            vehicleColorController.text.isNotEmpty;

    debugPrint('🔄 updateProfile called');
    debugPrint('📸 hasImage: $hasImage');
    debugPrint('🚗 hasVehicleData: $hasVehicleData');
    debugPrint('🚗 vehicleType: ${vehicleTypeController.text}');
    debugPrint('🚗 vehicleModel: ${vehicleModelController.text}');
    debugPrint('🚗 vehicleColor: ${vehicleColorController.text}');

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

  /// Edit mode toggle — off হলে temp image clear করো
  void toggleEdit() {
    isEditing = !isEditing;
    if (!isEditing) {
      tempCroppedImage.value = null;
    }
    update(['vehicle_fields']); // vehicle fields rebuild
    update(); // বাকি সব rebuild
  }

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