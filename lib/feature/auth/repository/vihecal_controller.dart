import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/route_path.dart';
import 'package:platchatapp/core/service/api_service.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';

class VehicleController extends GetxController {
  final vehicleModelController = TextEditingController();
  final vehicleColorController = TextEditingController();

  final RxString selectedType = 'CAR'.obs;

  final List<String> vehicleTypes = [
    'CAR',
    'MOTORCYCLE',
    'VAN',
    'OTHER',
  ];

  var isLoading = false.obs;

  Future<void> submitVehicle({required BuildContext context}) async {
    if (vehicleModelController.text.isEmpty ||
        vehicleColorController.text.isEmpty) {
      Get.snackbar('Error', 'All fields are required');
      return;
    }

    isLoading.value = true;

    final body = {
      "vehicle_type": selectedType.value,
      "vehicle_model": vehicleModelController.text.trim(),
      "vehicle_color": vehicleColorController.text.trim(),
    };

    try {
      final res = await ApiService.postData(
        ApiUrl.vehicle,
        body,
        isAuthRequired: true,
        isJson: true,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.snackbar('Success', 'Vehicle info saved');

        CustomSnackbar.success(context: context, message: 'Vehicle info saved');
       // context.go(RoutePath.signIn);
        context.go(RoutePath.mainNavScreen);

      } else {
        CustomSnackbar.error(context: context, message: 'Failed Saved');
      }
    } catch (e) {

      CustomSnackbar.success(context: context, message: e.toString());
    }

    isLoading.value = false;
  }

  @override
  void onClose() {
    vehicleModelController.dispose();
    vehicleColorController.dispose();
    super.onClose();
  }
}