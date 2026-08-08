import 'package:flutter/material.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class MapInitialShimmer extends StatelessWidget {
  const MapInitialShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:AppColors.greyShade,
      highlightColor: AppColors.greyShade,
      child: Container(
        color: AppColors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                margin:  ResponsiveHelper.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16),),
                ),
              ),
            ),
            Positioned(
              left: ResponsiveHelper.padding(16),
              right: ResponsiveHelper.padding(16),
              bottom: ResponsiveHelper.padding(30),
              child: Container(
                height: ResponsiveHelper.height(52),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(28)),
                ),
              ),
            ),
            Positioned(
              right: ResponsiveHelper.padding(16),
              bottom: ResponsiveHelper.padding(104),
              child: Container(
                width: ResponsiveHelper.width(48),
                height: ResponsiveHelper.height(48),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: ResponsiveHelper.padding(16),
              bottom: ResponsiveHelper.padding(168),
              child: Container(
                width: ResponsiveHelper.width(48),
                height: ResponsiveHelper.height(48),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


