import 'dart:ui';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';


class ParkingLocationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badgeLabel;
  final IconData badgeIcon;
  final Color badgeColor;
  final String distanceLabel;
  final String ratingLabel;
  final String leftStatLabel;
  final String rightStatLabel;
  final IconData leftStatIcon;
  final IconData rightStatIcon;

  final String? remainingTimeLabel;
  final String? remainingTimeSubLabel;

  const ParkingLocationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    required this.badgeIcon,
    required this.badgeColor,
    required this.distanceLabel,
    required this.ratingLabel,
    required this.leftStatLabel,
    required this.rightStatLabel,
    this.leftStatIcon = Icons.map_outlined,
    this.rightStatIcon = Icons.monetization_on_outlined,
    this.remainingTimeLabel,
    this.remainingTimeSubLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Outer container styling matching the rounded corners and subtle shadow
      decoration: BoxDecoration(
        color:  Color(0xFFD6DFEA),
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(32)),
        border: Border.all(color: AppColors.white)
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: ResponsiveHelper.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Section: Title and status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: context.bodyLarge.copyWith(color: AppColors.black,fontWeight: FontWeight.w700)
                          ),
                          SizedBox(height: ResponsiveHelper.spacing(4)),
                          Text(
                            subtitle,
                            style: context.bodySmall.copyWith(color: AppColors.black.withOpacity(0.6),fontWeight: FontWeight.w500)
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Status Pill Badge
                        Container(
                          padding: ResponsiveHelper.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                          gradient: AppColors.containerGradient,
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.borderRadius(20),
                            ),
                            border: Border.all(
                              color: AppColors.white,
                              width: ResponsiveHelper.borderWidth(1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                badgeIcon,
                                size: ResponsiveHelper.iconSize(14),
                                color: badgeColor,
                              ),
                              SizedBox(width: ResponsiveHelper.spacing(4)),
                              Text(
                                badgeLabel,
                                style:context.bodySmall.copyWith(
                                  color: badgeColor,
                                  fontWeight: FontWeight.w600
                                )
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveHelper.spacing(8)),

                /// Distance and Rating Section and time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: ResponsiveHelper.iconSize(18),
                          color: AppColors.blue
                        ),
                        SizedBox(width: ResponsiveHelper.spacing(4)),
                        Text(
                          distanceLabel,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(14),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(width: ResponsiveHelper.spacing(16)),
                        Icon(
                          Icons.star_rounded,
                          size: ResponsiveHelper.iconSize(18),
                          color: const Color(0xFF1D4ED8), // Deep blue star as seen in UI
                        ),
                        SizedBox(width: ResponsiveHelper.spacing(4)),
                        Text(
                          ratingLabel,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(14),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),


                    if (remainingTimeLabel != null) ...[
                      SizedBox(height: ResponsiveHelper.spacing(6)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: ResponsiveHelper.iconSize(14),
                                color: const Color(0xFF1D4ED8),
                              ),
                              SizedBox(width: ResponsiveHelper.spacing(4)),
                              Text(
                                remainingTimeLabel!,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.fontSize(13),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1D4ED8),
                                ),
                              ),
                            ],
                          ),
                          if (remainingTimeSubLabel != null)
                            Text(
                              remainingTimeSubLabel!,
                              style: context.bodySmall.copyWith(color: AppColors.black.withOpacity(0.6),)
                            ),
                        ],
                      ),

                    ],

                  ],
                ),
                SizedBox(height: ResponsiveHelper.spacing(8)),

                // Bottom Detailed Stats Pill Container
                Container(
                  padding: ResponsiveHelper.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(24)),
                  ),
                  child: Row(
                    children: [
                      // Left Section: Spots Info
                      Expanded(
                        child: Column(
                          children: [
                            Icon(
                              leftStatIcon,
                              color: AppColors.black,
                              size: ResponsiveHelper.iconSize(22),
                            ),
                            SizedBox(height: ResponsiveHelper.spacing(6)),
                            Text(
                              leftStatLabel,
                              style: context.bodySmall.copyWith(color: AppColors.black.withOpacity(0.6),fontWeight: FontWeight.w600)
                            ),
                          ],
                        ),
                      ),
                      // Divider line
                      Container(
                        height: ResponsiveHelper.height(32),
                        width: ResponsiveHelper.borderWidth(1),
                        color: const Color(0xFF1E293B).withOpacity(0.1),
                      ),
                      // Right Section: Pricing Info
                      Expanded(
                        child: Column(
                          children: [
                            Icon(
                              rightStatIcon,
                              color: AppColors.black,
                              size: ResponsiveHelper.iconSize(22),
                            ),
                            SizedBox(height: ResponsiveHelper.spacing(6)),
                            Text(
                              rightStatLabel,
                                style: context.bodySmall.copyWith(color: AppColors.black.withOpacity(0.6),fontWeight: FontWeight.w600)
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
