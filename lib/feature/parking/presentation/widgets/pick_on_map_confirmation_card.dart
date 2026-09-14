import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:platchatapp/helper/custom_gradient_button/custom_gradient_button.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';

/// Floating bottom card shown during "Pick on map" mode.
/// Stays on screen while the user taps different spots on the map, allowing
/// them to move the pin repeatedly. Clicking "Confirm and Proceed" opens the
/// target parking bottom sheet, while clicking the cross (X) exits picking mode.
class PickOnMapConfirmationCard extends StatelessWidget {
  final LatLng? pickedLocation;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final VoidCallback? onUseCurrentLocation;

  const PickOnMapConfirmationCard({
    super.key,
    required this.pickedLocation,
    required this.onConfirm,
    required this.onCancel,
    this.onUseCurrentLocation,
  });

  @override
  Widget build(BuildContext context) {
    final lat = pickedLocation?.latitude.toStringAsFixed(5) ?? '--';
    final lng = pickedLocation?.longitude.toStringAsFixed(5) ?? '--';

    return Positioned(
      left: ResponsiveHelper.padding(16),
      right: ResponsiveHelper.padding(16),
      bottom: MediaQuery.of(context).padding.bottom + ResponsiveHelper.padding(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // "Use Current Location" floating pill
          if (onUseCurrentLocation != null) ...[
            GestureDetector(
              onTap: onUseCurrentLocation,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.padding(16),
                  vertical: ResponsiveHelper.padding(10),
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.borderRadius(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.my_location_rounded,
                      color: AppColors.blue,
                      size: ResponsiveHelper.iconSize(18),
                    ),
                    SizedBox(width: ResponsiveHelper.spacing(8)),
                    Text(
                      AppStrings.useCurrentLocation.tr.isNotEmpty
                          ? AppStrings.useCurrentLocation.tr
                          : 'Use Current Location',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.fontSize(13),
                        fontWeight: FontWeight.w600,
                        color: AppColors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: ResponsiveHelper.spacing(12)),
          ],

          // Main Confirmation Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.containerGradient,
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.borderRadius(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.padding(18),
              vertical: ResponsiveHelper.padding(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: Location icon + Title + Cross (X) button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: ResponsiveHelper.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.blue.withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: AppColors.blue,
                        size: ResponsiveHelper.iconSize(22),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.spacing(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.confirmLocation.tr.isNotEmpty
                                ? AppStrings.confirmLocation.tr
                                : 'Confirm Location',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.fontSize(16),
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.spacing(3)),
                          Text(
                            '$lat, $lng',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.fontSize(13),
                              fontWeight: FontWeight.w600,
                              color: AppColors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Close (X) button
                    GestureDetector(
                      onTap: onCancel,
                      child: Container(
                        padding: ResponsiveHelper.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.black.withValues(alpha: 0.06),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: ResponsiveHelper.iconSize(18),
                          color: AppColors.black54,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: ResponsiveHelper.spacing(10)),

                // Helpful hint text
                Text(
                  AppStrings.tapMapToChangeLocation.tr.isNotEmpty
                      ? AppStrings.tapMapToChangeLocation.tr
                      : 'Tap anywhere on the map to adjust pin position',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(11.5),
                    color: AppColors.black.withValues(alpha: 0.5),
                  ),
                ),

                SizedBox(height: ResponsiveHelper.spacing(16)),

                // "Confirm and Proceed" button
                CustomGradientButton(
                  label: AppStrings.confirmAndProceed.tr.isNotEmpty
                      ? AppStrings.confirmAndProceed.tr
                      : 'Confirm and Proceed',
                  onPressed: onConfirm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
