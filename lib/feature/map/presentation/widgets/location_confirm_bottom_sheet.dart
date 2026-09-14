import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/helper/custom_gradient_button/custom_gradient_button.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/bottom_sheet_aware/tracked_bottom_sheet.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';

class LocationConfirmBottomSheet extends StatelessWidget {
  final LatLng location;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const LocationConfirmBottomSheet({
    super.key,
    required this.location,
    required this.onConfirm,
    this.onCancel,
  });

  static Future<void> show(
    BuildContext context, {
    required LatLng location,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return showTrackedBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (sheetContext) => LocationConfirmBottomSheet(
        location: location,
        onConfirm: () {
          Navigator.of(sheetContext).pop();
          onConfirm();
        },
        onCancel: () {
          Navigator.of(sheetContext).pop();
          onCancel?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latStr = location.latitude.toStringAsFixed(5);
    final lngStr = location.longitude.toStringAsFixed(5);

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.containerGradient,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveHelper.borderRadius(24)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: ResponsiveHelper.padding(20),
        right: ResponsiveHelper.padding(20),
        top: ResponsiveHelper.padding(12),
        bottom: MediaQuery.of(context).padding.bottom + ResponsiveHelper.padding(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: ResponsiveHelper.width(40),
              height: ResponsiveHelper.height(4),
              margin: EdgeInsets.only(bottom: ResponsiveHelper.spacing(20)),
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Location icon
          Container(
            padding: ResponsiveHelper.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blue.withValues(alpha: 0.12),
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: AppColors.blue,
              size: ResponsiveHelper.iconSize(32),
            ),
          ),

          SizedBox(height: ResponsiveHelper.spacing(16)),

          // Title
          Text(
            AppStrings.confirmLocation.tr.isNotEmpty
                ? AppStrings.confirmLocation.tr
                : 'Confirm Location',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(18),
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),

          SizedBox(height: ResponsiveHelper.spacing(8)),

          // Subtitle message
          Text(
            AppStrings.useThisLocationConfirmation.tr.isNotEmpty
                ? AppStrings.useThisLocationConfirmation.tr
                : 'Do you want to use this location?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveHelper.fontSize(13),
              color: AppColors.black.withValues(alpha: 0.6),
            ),
          ),

          SizedBox(height: ResponsiveHelper.spacing(14)),

          // Selected coordinates pill
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.padding(14),
              vertical: ResponsiveHelper.padding(8),
            ),
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.borderRadius(12),
              ),
              border: Border.all(
                color: AppColors.blue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.my_location_rounded,
                  size: ResponsiveHelper.iconSize(16),
                  color: AppColors.blue,
                ),
                SizedBox(width: ResponsiveHelper.spacing(8)),
                Text(
                  '$latStr, $lngStr',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveHelper.spacing(24)),

          // Action buttons: Cancel / Confirm
          Row(
            children: [
              Expanded(
                child: CustomGradientButton(
                  onPressed: onCancel ?? () => Navigator.of(context).pop(),
                  label: AppStrings.no.tr.isNotEmpty ? AppStrings.no.tr : 'No',
                  backgroundColor: AppColors.blueShadeConBg,
                  shadowColor: AppColors.transparent,
                  textColor: AppColors.black,
                  borderColor: AppColors.white,
                ),
              ),
              SizedBox(width: ResponsiveHelper.spacing(14)),
              Expanded(
                child: CustomGradientButton(
                  onPressed: onConfirm,
                  label: AppStrings.yes.tr.isNotEmpty ? AppStrings.yes.tr : 'Yes',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
