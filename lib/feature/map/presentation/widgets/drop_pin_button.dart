

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/language/app_string.dart';

import '../../../../utils/color/app_colors.dart';


class AddParkingButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddParkingButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(ResponsiveHelper.padding(30)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.padding(20),
          vertical: ResponsiveHelper.padding(12),
        ),
        decoration: BoxDecoration(
          color: AppColors.paidBlue,
          borderRadius: BorderRadius.circular(ResponsiveHelper.padding(30)),
          boxShadow: [
            BoxShadow(
              color: AppColors.paidBlue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              color: AppColors.white,
              size: ResponsiveHelper.iconSize(24),
            ),
            SizedBox(width: ResponsiveHelper.padding(8)),
            Text(
             AppStrings.addParking.tr,
              style: GoogleFonts.poppins(
                color: AppColors.white,
                fontSize: ResponsiveHelper.fontSize(16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
