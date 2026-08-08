import 'package:flutter/material.dart';
import 'package:platchatapp/helper/custom_gradient_button/custom_gradient_button.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

/// Generic "are you sure?" confirmation dialog built on top of
/// [CustomGradientButton], meant to be reused anywhere an action needs a
/// confirm step (accept / reject / block / withdraw a message request, etc.)
/// instead of firing the API call straight from a tap.
class ActionConfirmDialog {
  const ActionConfirmDialog._();

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
    String cancelLabel = 'Cancel',
    IconData icon = Icons.help_outline_rounded,
    Color iconColor = AppColors.blue,
    Gradient? confirmGradient,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
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
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.padding(24),
            vertical: ResponsiveHelper.padding(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: ResponsiveHelper.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: 0.12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: ResponsiveHelper.iconSize(28),
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(18)),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(17),
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(10)),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(13),
                  color: AppColors.black.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(28)),
              Row(
                children: [
                  Expanded(
                    child: CustomGradientButton(
                      onPressed: () => Navigator.of(context).pop(),
                      label: cancelLabel,
                      backgroundColor: AppColors.blueShadeConBg,
                      shadowColor: AppColors.transparent,
                      textColor: AppColors.black,
                      borderColor: AppColors.white,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.spacing(14)),
                  Expanded(
                    child: CustomGradientButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                      label: confirmLabel,
                      gradient: confirmGradient,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


