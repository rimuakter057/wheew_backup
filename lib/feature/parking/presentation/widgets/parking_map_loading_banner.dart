import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';

/// Single loading pill for ParkingMapScreen — shown while locating and/or
/// fetching nearby parking, instead of stacking two separate banners.
class ParkingMapLoadingBanner extends StatelessWidget {
  const ParkingMapLoadingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + ResponsiveHelper.padding(12),
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.padding(16),
            vertical: ResponsiveHelper.padding(8),
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
            boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.12), blurRadius: 8)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: ResponsiveHelper.width(16),
                height: ResponsiveHelper.height(16),
                child: CircularProgressIndicator(
                  strokeWidth: ResponsiveHelper.borderWidth(2),
                  color: const Color(0xFF3D72E8),
                ),
              ),
              SizedBox(width: ResponsiveHelper.spacing(8)),
              Text(
                AppStrings.loading.tr,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(12),
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
