import 'package:flutter/material.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton list shown while SaveParkingScreen's history is loading —
/// shaped like the real ParkingLocationCard rows it's replacing.
class SaveParkingScreenShimmer extends StatelessWidget {
  const SaveParkingScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // Distinct base/highlight so the sweep is actually visible — using the
    // same flat color for both (as elsewhere in the app) renders as static.
    return Shimmer.fromColors(
      baseColor: AppColors.lightBlue1,
      highlightColor: AppColors.white,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: ResponsiveHelper.symmetric(horizontal: 20, vertical: 4),
        itemCount: 4,
        separatorBuilder: (_, _) => SizedBox(height: ResponsiveHelper.spacing(8)),
        itemBuilder: (context, index) => const _SaveParkingCardShimmer(),
      ),
    );
  }
}

/// Mirrors ParkingLocationCard's layout: rounded card, title/subtitle +
/// badge pill row, distance/rating row, bottom stats pill.
class _SaveParkingCardShimmer extends StatelessWidget {
  const _SaveParkingCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveHelper.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6ECF3),
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(32)),
        border: Border.all(color: AppColors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title / subtitle + badge pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: ResponsiveHelper.width(120),
                      height: ResponsiveHelper.height(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(6)),
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.spacing(6)),
                    Container(
                      width: ResponsiveHelper.width(80),
                      height: ResponsiveHelper.height(12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(6)),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: ResponsiveHelper.width(84),
                height: ResponsiveHelper.height(30),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.spacing(8)),

          // Distance / rating row
          Row(
            children: [
              Container(
                width: ResponsiveHelper.width(70),
                height: ResponsiveHelper.height(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(6)),
                ),
              ),
              SizedBox(width: ResponsiveHelper.spacing(16)),
              Container(
                width: ResponsiveHelper.width(40),
                height: ResponsiveHelper.height(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(6)),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.spacing(8)),

          // Bottom stats pill
          Container(
            width: double.infinity,
            height: ResponsiveHelper.height(56),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(24)),
            ),
          ),
        ],
      ),
    );
  }
}
