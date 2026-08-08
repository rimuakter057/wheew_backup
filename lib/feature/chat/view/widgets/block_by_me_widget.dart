import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class BlockByMeWidget extends StatelessWidget {
  final VoidCallback onUnblock;
  final String name;
  const BlockByMeWidget({
    super.key,
    required this.onUnblock,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: ResponsiveHelper.all(16),

      margin: ResponsiveHelper.all(12),

      decoration: BoxDecoration(
        color: AppColors.blue,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: AppColors.blue),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /*Text(
            AppStrings.youveBlockedName.tr,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.fontSize(16),
              fontWeight: FontWeight.w400,
              color: AppColors.black,
            ),
          ),*/
          Text(
            "${AppStrings.youveBlocked.tr} $name",
            style: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.fontSize(16),
              fontWeight: FontWeight.w400,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: ResponsiveHelper.spacing(4)),
          Text(
            AppStrings.thisUserWontBeAble.tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.fontSize(14),
              fontWeight: FontWeight.w400,
              color: AppColors.grey[600],
            ),
          ),
          SizedBox(height: ResponsiveHelper.spacing(12)),

          ElevatedButton(
            onPressed: onUnblock,

            style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),

            child: Text(
              AppStrings.unblock.tr,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(16),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}




