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
          // Everything below sits on the blue card above, so it's coloured for
          // contrast against blue. Previously the title was black, the
          // subtitle grey and the button blue-on-blue — the button read as a
          // flat blank strip and the subtitle was barely legible.
          Text(
            "${AppStrings.youveBlocked.tr} $name",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.fontSize(16),
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: ResponsiveHelper.spacing(4)),
          Text(
            AppStrings.thisUserWontBeAble.tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.fontSize(14),
              fontWeight: FontWeight.w400,
              color: AppColors.white.withValues(alpha: 0.85),
            ),
          ),
          SizedBox(height: ResponsiveHelper.spacing(12)),

          ElevatedButton(
            onPressed: onUnblock,

            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.blue,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.padding(28),
                vertical: ResponsiveHelper.padding(12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(24),
                ),
              ),
            ),

            child: Text(
              AppStrings.unblock.tr,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(16),
                fontWeight: FontWeight.w600,
                color: AppColors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}




