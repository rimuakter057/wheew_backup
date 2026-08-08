
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/feature/auth/repository/vehicle_type_info.dart';
import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';

/// Vehicle Type dropdown — icon + text (VehicleInfoScreen এর ডিজাইন অনুযায়ী)
class VehicleTypeDropdown extends StatelessWidget {
  final ProfileController controller;
  final ValueChanged<VehicleType>? onSelected;

  const VehicleTypeDropdown({super.key, required this.controller,this.onSelected,});

  @override
  Widget build(BuildContext context) {
    final rawValue = controller.vehicleTypeController.text;

    // backend string ("SCOOTER") থেকে VehicleType enum বের করো
    VehicleType? currentType;
    if (rawValue.isNotEmpty) {
      for (final type in VehicleType.values) {
        if (type.backendKey == rawValue) {
          currentType = type;
          break;
        }
      }
    }

    // Locked once already set; otherwise editable while in edit mode.
    final bool isFieldEnabled = controller.isEditing && !controller.isVehicleTypeLocked;

    return PopupMenuButton<VehicleType>(
      enabled: isFieldEnabled,
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 220),
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
      ),
      onSelected:onSelected?? (value) {
        controller.vehicleTypeController.text = value.backendKey;
      },
      itemBuilder: (context) {
        return VehicleType.values.map((type) {
          return PopupMenuItem<VehicleType>(
            value: type,
            child: Row(
              children: [
                CustomImage(
                  imageSrc: type.imageBlue,
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    type.displayName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: AppStrings.vehicleType.tr,
          hintStyle: const TextStyle(fontSize: 13.0),
          filled: true,
          fillColor: isFieldEnabled
              ? AppColors.white
              : AppColors.greyShade.withOpacity(0.3),
          contentPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.padding(14),
            vertical: ResponsiveHelper.padding(12),
          ),
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
        child: Row(
          children: [
            Expanded(
              child: currentType == null
                  ? Text(
                AppStrings.vehicleType.tr,
                style: const TextStyle(fontSize: 13.0, color: AppColors.grey),
              )
                  : Row(
                children: [
                  CustomImage(
                    imageSrc: currentType.imageBlue,
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      currentType.displayName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13.0, color: AppColors.black),
                    ),
                  ),
                ],
              ),
            ),
            if (isFieldEnabled)
              const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}

