import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';

class PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? borderRadius;

  const PrimaryButton({
    super.key,
    required this.title,
    required this.onTap,
    this.backgroundColor = AppColors.blue,
    this.textColor = Colors.white,
    this.height = 52,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveHelper.buttonHeight(height!),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.borderRadius(borderRadius!),
            ),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(16),
            color: textColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
