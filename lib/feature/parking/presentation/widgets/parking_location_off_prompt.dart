import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/language/app_string.dart';

class ParkingLocationOffPrompt extends StatelessWidget {
  const ParkingLocationOffPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1a1a2e),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.padding(32),
          ),
          padding: EdgeInsets.all(ResponsiveHelper.padding(24)),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: ResponsiveHelper.width(52),
                height: ResponsiveHelper.height(52),
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F1FB),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_off,
                  color: const Color(0xFF185FA5),
                  size: ResponsiveHelper.iconSize(26),
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(12)),
              Text(
                AppStrings.locationTurnedOff.tr,
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(15),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(6)),
              Text(
                AppStrings.locationOffDesc.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(13),
                  color: AppColors.grey,
                  height: 1.5,
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(20)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF185FA5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(8)),
                    ),
                  ),
                  onPressed: () async {
                    await Geolocator.openLocationSettings();
                  },
                  child: Text(
                    AppStrings.enableLocation.tr,
                    style: const TextStyle(color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

