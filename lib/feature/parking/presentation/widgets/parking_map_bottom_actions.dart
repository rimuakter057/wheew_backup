import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:platchatapp/utils/language/app_string.dart';

import '../../../../helper/custom_gradient_button/custom_gradient_button.dart';
import '../../../../utils/color/app_colors.dart';

/// Bottom Find-Parking / Exit-Parking button row on ParkingMapScreen. Both
class ParkingMapBottomActions extends StatelessWidget {
  final bool isSearching;
  final bool isTransitioningSearch;
  final VoidCallback onFindParkingTap;
  final VoidCallback onExitParkingTap;

  const ParkingMapBottomActions({
    super.key,
    required this.isSearching,
    required this.isTransitioningSearch,
    required this.onFindParkingTap,
    required this.onExitParkingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: ResponsiveHelper.bottomNavOffset(context),
      left: ResponsiveHelper.padding(20),
      right: ResponsiveHelper.padding(20),
      child: Row(
        children: [
          Expanded(
            child: CustomGradientButton(
              onPressed: onFindParkingTap,
              isLoading: isTransitioningSearch,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isSearching) ...[
                    CustomImage(
                      imageSrc: AssetsPath.pNav,
                      width: ResponsiveHelper.iconSize(16),
                      height: ResponsiveHelper.iconSize(16),
                    ),
                    SizedBox(width: ResponsiveHelper.width(4)),
                  ],
                  Flexible(
                    child: Text(
                      isSearching
                          ? AppStrings.stopSearching.tr
                          : AppStrings.findParkingSpot.tr,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: context.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontSize: ResponsiveHelper.fontSize(10),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.width(12)),
          Expanded(
            child: CustomGradientButton(
              gradient: AppColors.redGradient,
              onPressed: onExitParkingTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomImage(
                    imageSrc: AssetsPath.pNav,
                    width: ResponsiveHelper.iconSize(16),
                    height: ResponsiveHelper.iconSize(16),
                  ),
                  SizedBox(width: ResponsiveHelper.width(4)),
                  Flexible(
                    child: Text(
                      AppStrings.exitParking.tr,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: context.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontSize: ResponsiveHelper.fontSize(10),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
