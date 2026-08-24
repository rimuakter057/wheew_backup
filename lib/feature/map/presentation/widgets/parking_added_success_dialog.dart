import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/helper/custom_gradient_button/custom_gradient_button.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:platchatapp/utils/language/app_string.dart';

/// Shown right after a parking spot is successfully submitted.
class ParkingAddedSuccessDialog extends StatelessWidget {
  const ParkingAddedSuccessDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: AppColors.black.withValues(alpha: 0.4),
      builder: (_) => const ParkingAddedSuccessDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.padding(24),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.containerGradient,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(24),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.padding(24),
            vertical: ResponsiveHelper.padding(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: ResponsiveHelper.width(64),
                height: ResponsiveHelper.height(64),
                decoration: BoxDecoration(
                  color: AppColors.successColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.successColor,
                  size: ResponsiveHelper.iconSize(36),
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(20)),
              Text(
                AppStrings.mapParkingAddedSuccessTitle.tr,
                style: context.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              // Subtitle (pending-admin-approval note) removed — new
              // parking spots don't need admin approval anymore.
              SizedBox(height: ResponsiveHelper.spacing(28)),
              CustomGradientButton(
                onPressed: () => Navigator.of(context).pop(),
                label: AppStrings.ok.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


