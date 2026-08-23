import 'package:flutter/material.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';


class ParkingMapLeftActionButtons extends StatelessWidget {
  final VoidCallback onAddParkingTap;
  final VoidCallback onSaveParkingTap;

  const ParkingMapLeftActionButtons({
    super.key,
    required this.onAddParkingTap,
    required this.onSaveParkingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: ResponsiveHelper.padding(16),
      top: MediaQuery.of(context).padding.top + ResponsiveHelper.padding(68),
      child: Column(
        children: [
          _circleGradientButton(
            iconAsset: AssetsPath.addLocation,
            onTap: onAddParkingTap,
          ),
          SizedBox(height: ResponsiveHelper.height(12)),
          _circleGradientButton(
            iconAsset: AssetsPath.savePNav,
            onTap: onSaveParkingTap,
          ),
        ],
      ),
    );
  }

  Widget _circleGradientButton({
    required String iconAsset,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ResponsiveHelper.width(52),
        height: ResponsiveHelper.height(52),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.buttonGradient,
          border: Border.all(color: AppColors.darBlue, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: CustomImage(
          imageSrc: iconAsset,
          imageColor: AppColors.white,
          width: ResponsiveHelper.iconSize(24),
          height: ResponsiveHelper.iconSize(24),
        ),
      ),
    );
  }
}
