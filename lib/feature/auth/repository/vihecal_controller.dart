// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'package:platchatapp/core/router/route_path.dart';
// import 'package:platchatapp/core/service/api_service.dart';
// import 'package:platchatapp/core/service/api_url.dart';
// import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
//
// class VehicleController extends GetxController {
//   final vehicleModelController = TextEditingController();
//
//   final RxString selectedType = 'CAR'.obs;
//   final RxString selectedColor = ''.obs;
//
//   final List<String> vehicleTypes = [
//     'CAR',
//     'MOTORCYCLE',
//     'VAN',
//     'OTHER',
//   ];
//
//   var isLoading = false.obs;
//
//   Future<void> submitVehicle({required BuildContext context}) async {
//     if (vehicleModelController.text.isEmpty || selectedColor.value.isEmpty) {
//       Get.snackbar('Error', 'All fields are required');
//       return;
//     }
//
//     isLoading.value = true;
//
//     final body = {
//       "vehicle_type": selectedType.value,
//       "vehicle_model": vehicleModelController.text.trim(),
//       "vehicle_color": selectedColor.value,
//     };
//
//     try {
//       final res = await ApiService.postData(
//         ApiUrl.vehicle,
//         body,
//         isAuthRequired: true,
//         isJson: true,
//       );
//
//       if (res.statusCode == 200 || res.statusCode == 201) {
//         CustomSnackbar.success(context: context, message: 'Vehicle info saved');
//         context.go(RoutePath.mainNavScreen);
//       } else {
//         CustomSnackbar.error(context: context, message: 'Failed Saved');
//       }
//     } catch (e) {
//       CustomSnackbar.error(context: context, message: e.toString());
//     }
//
//     isLoading.value = false;
//   }
//
//   @override
//   void onClose() {
//     vehicleModelController.dispose();
//     super.onClose();
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/route_path.dart';
import 'package:platchatapp/core/service/api_service.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/auth/repository/vehicle_type_info.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';




class VehicleController extends GetxController {
  /// Vehicle Type
  final Rx<VehicleType?> selectedType = Rx<VehicleType?>(null);

  /// Vehicle Model
  final RxString selectedVehicleModel = ''.obs;

  /// Vehicle Color
  final RxString selectedColor = ''.obs;

  final List<VehicleType> vehicleTypes = VehicleType.values;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // The type carousel always shows the first type as visually selected,
    // so the controller's value must match from the start — otherwise
    // Submit fails with "All fields are required" even though a type
    // already looks selected on screen.
    if (selectedType.value == null && vehicleTypes.isNotEmpty) {
      selectedType.value = vehicleTypes.first;
    }
  }

  Future<void> submitVehicle({
    required BuildContext context,
  }) async {
    if (selectedType.value == null ||
        selectedVehicleModel.value.isEmpty ||
        selectedColor.value.isEmpty) {

      CustomSnackbar.error(
        context: context,
        message: 'All fields are required',
      );
      return;
    }


    isLoading.value = true;

    final body = {
      "vehicle_type": selectedType.value!.backendKey,
      "vehicle_model": selectedVehicleModel.value,
      "vehicle_color": selectedColor.value,
    };

    try {
      final res = await ApiService.postData(
        ApiUrl.vehicle,
        body,
        isAuthRequired: true,
        isJson: true,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        CustomSnackbar.success(
          context: context,
          message: 'Vehicle info saved',
        );

        context.go(RoutePath.mainNavScreen);
      } else {
        CustomSnackbar.error(
          context: context,
          message: 'Failed Saved',
        );
      }
    } catch (e) {
      CustomSnackbar.error(
        context: context,
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }
}