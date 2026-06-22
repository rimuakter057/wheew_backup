import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';


/// Vehicle Type dropdown — API accept করে: CAR, MOTORCYCLE, VAN, OTHER
class VehicleTypeDropdown extends StatelessWidget {
  final ProfileController controller;

  const VehicleTypeDropdown({super.key, required this.controller});

  static const List<String> _options = ['CAR', 'MOTORCYCLE', 'VAN', 'OTHER'];

  @override
  Widget build(BuildContext context) {
    final currentValue = controller.vehicleTypeController.text.isEmpty
        ? null
        : controller.vehicleTypeController.text;

    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(
        hintText: AppStrings.vehicleType.tr,
        filled: true,
        // edit mode এ white, otherwise grey
        fillColor: controller.isEditing
            ? AppColors.white
            : AppColors.greyShade.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
          borderSide: BorderSide(color: AppColors.greyShade),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
          borderSide: BorderSide(color: AppColors.greyShade),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
          borderSide: BorderSide(color: AppColors.greyShade),
        ),
      ),
      items: _options
          .map((e) => DropdownMenuItem(value: e, child: Text(e.tr)))
          .toList(),
      // edit mode OFF হলে null — dropdown disable হয়
      onChanged: controller.isEditing
          ? (val) => controller.vehicleTypeController.text = val ?? ''
          : null,
    );
  }
}