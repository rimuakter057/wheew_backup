import 'package:flutter/material.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';


/// Read-only বা editable text field — profile screen এ সব জায়গায় ব্যবহার হয়
class ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool enabled;

  const ProfileTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
        filled: true,
        // enabled হলে white, disabled হলে grey
        fillColor: enabled ? AppColors.white : AppColors.greyShade.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
          borderSide: BorderSide(color: AppColors.greyShade),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
          borderSide: BorderSide(color: AppColors.greyShade),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
          borderSide: BorderSide(color: AppColors.greyShade, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
          borderSide: BorderSide(color: AppColors.greyShade),
        ),
      ),
    );
  }
}