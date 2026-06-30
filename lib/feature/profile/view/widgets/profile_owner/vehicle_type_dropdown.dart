// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
// import 'package:platchatapp/utils/color/app_colors.dart';
// import 'package:platchatapp/utils/language/app_string.dart';
//
// /// Vehicle Type dropdown — API accept করে: CAR, MOTORCYCLE, VAN, OTHER
// class VehicleTypeDropdown extends StatelessWidget {
//   final ProfileController controller;
//
//   const VehicleTypeDropdown({super.key, required this.controller});
//
//   static const List<String> _options = [
//     'VAN',
//     'SUV',
//     'TRUCK',
//     'CAMPER',
//     'SCOOTER',
//     'MOTORCYCLE',
//     'PICKUP',
//     'MICRO_CAR',
//     'CITY_CAR',
//     'E_SCOOTER',
//   ];
//
//
//   @override
//   Widget build(BuildContext context) {
//     final currentValue = controller.vehicleTypeController.text.isEmpty
//         ? null
//         : controller.vehicleTypeController.text;
//
//     return DropdownButtonFormField<String>(
//       value: currentValue,
//       decoration: InputDecoration(
//         hintText: AppStrings.vehicleType.tr,
//         // hint text এর সাইজ ছোট করার জন্য
//         hintStyle: const TextStyle(fontSize: 13.0),
//         filled: true,
//         // edit mode এ white, otherwise grey
//         fillColor: controller.isEditing
//             ? AppColors.white
//             : AppColors.greyShade.withOpacity(0.3),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
//           borderSide: BorderSide(color: AppColors.greyShade),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
//           borderSide: BorderSide(color: AppColors.greyShade),
//         ),
//         disabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
//           borderSide: BorderSide(color: AppColors.greyShade),
//         ),
//       ),
//       // selected value (যেটা ড্রপডাউনে শো করবে) সেটার টেক্সট স্টাইল
//       style: const TextStyle(fontSize: 13.0, color: Colors.black),
//       items: _options
//           .map((e) => DropdownMenuItem(
//         value: e,
//         // ড্রপডাউন অপশনগুলোর টেক্সট সাইজ ছোট করার জন্য
//         child: Text(e.tr, style: const TextStyle(fontSize: 13.0)),
//       ))
//           .toList(),
//       // edit mode OFF হলে null — dropdown disable হয়
//       onChanged: controller.isEditing
//           ? (val) => controller.vehicleTypeController.text = val ?? ''
//           : null,
//     );
//   }
// }










import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:platchatapp/feature/auth/repository/vehicle_type_info.dart';
import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';

/// Vehicle Type dropdown — icon + text (VehicleInfoScreen এর ডিজাইন অনুযায়ী)
class VehicleTypeDropdown extends StatelessWidget {
  final ProfileController controller;

  const VehicleTypeDropdown({super.key, required this.controller});

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

    return PopupMenuButton<VehicleType>(
      enabled: controller.isEditing,
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 220),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
      ),
      onSelected: (value) {
        controller.vehicleTypeController.text = value.backendKey;
      },
      itemBuilder: (context) {
        return VehicleType.values.map((type) {
          return PopupMenuItem<VehicleType>(
            value: type,
            child: Row(
              children: [
                SvgPicture.asset(
                  type.icon,
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    AppColors.black,
                    BlendMode.srcIn,
                  ),
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
          fillColor: controller.isEditing
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
                style: const TextStyle(fontSize: 13.0, color: Colors.grey),
              )
                  : Row(
                children: [
                  SvgPicture.asset(
                    currentType.icon,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      currentType.displayName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13.0, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            if (controller.isEditing)
              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}