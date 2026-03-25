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
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          minimumSize: Size(
            double.infinity,
            ResponsiveHelper.buttonHeight(height!), // ✅ match SizedBox height
          ),
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.padding(16),
            vertical: 0, // ✅ no vertical padding conflict
          ),
          tapTargetSize:
              MaterialTapTargetSize.shrinkWrap, // ✅ removes extra tap area
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.borderRadius(borderRadius!),
            ),
          ),
        ),
        child: FittedBox(
          // ✅ prevents text clipping
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            maxLines: 1,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.fontSize(16),
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/*
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
          foregroundColor: textColor, // ✅ fixes ripple + icon color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.borderRadius(borderRadius!),
            ),
          ),
        ),
        */
/*style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.borderRadius(borderRadius!),
            ),
          ),
        ),*/ /*

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
*/
