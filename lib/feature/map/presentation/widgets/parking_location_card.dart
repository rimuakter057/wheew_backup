import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:platchatapp/helper/custom_gradient_button/custom_gradient_button.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';


class ParkingLocationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badgeLabel;
  final IconData badgeIcon;

  /// SVG asset for the badge icon — takes precedence over [badgeIcon] when
  /// provided (e.g. the "Standard" badge's dedicated icon).
  final String? badgeIconAsset;
  final Color badgeColor;
  final String distanceLabel;
  final String ratingLabel;
  final String leftStatLabel;
  final String rightStatLabel;
  final IconData leftStatIcon;
  final IconData rightStatIcon;

  /// SVG asset for the right stat icon — takes precedence over
  /// [rightStatIcon] when provided (e.g. the dollar icon for Free/Paid).
  final String? rightStatIconAsset;

  final String? remainingTimeLabel;
  final String? remainingTimeSubLabel;

  /// Small inline "Navigate" link shown next to the rating — not a full
  /// button, just an icon + label.
  final VoidCallback? onNavigate;

  /// Full-width "Save Park" button rendered inside the card, below the
  /// stats row — omit to hide it.
  final VoidCallback? onSavePark;

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
    this.badgeIconAsset,
    this.leftStatIcon = Icons.map_outlined,
    this.rightStatIcon = Icons.monetization_on_outlined,
    this.rightStatIconAsset,
    this.remainingTimeLabel,
    this.remainingTimeSubLabel,
    this.onNavigate,
    this.onSavePark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Outer container styling matching the rounded corners and subtle shadow
      decoration: BoxDecoration(
        color: const Color(0xFFE6ECF3),
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
                              badgeIconAsset != null
                                  ? SvgPicture.asset(
                                      badgeIconAsset!,
                                      width: ResponsiveHelper.iconSize(14),
                                      height: ResponsiveHelper.iconSize(14),
                                      colorFilter: ColorFilter.mode(
                                        badgeColor,
                                        BlendMode.srcIn,
                                      ),
                                    )
                                  : Icon(
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
                          color: (double.tryParse(ratingLabel) ?? 0.0) > 0
                              ? const Color(0xFF1D4ED8)
                              : Colors.grey,
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

                    if (remainingTimeLabel != null)
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
                      )
                    else if (onNavigate != null)
                      GestureDetector(
                        onTap: onNavigate,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.near_me_outlined,
                              size: ResponsiveHelper.iconSize(16),
                              color: AppColors.blue,
                            ),
                            SizedBox(width: ResponsiveHelper.spacing(4)),
                            Text(
                              'Navigate',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.fontSize(13),
                                fontWeight: FontWeight.w600,
                                color: AppColors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                            rightStatIconAsset != null
                                ? SvgPicture.asset(
                                    rightStatIconAsset!,
                                    width: ResponsiveHelper.iconSize(22),
                                    height: ResponsiveHelper.iconSize(22),
                                    colorFilter: ColorFilter.mode(
                                      AppColors.black,
                                      BlendMode.srcIn,
                                    ),
                                  )
                                : Icon(
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

                if (onSavePark != null) ...[
                  SizedBox(height: ResponsiveHelper.spacing(12)),
                  SizedBox(
                    width: double.infinity,
                    child: CustomGradientButton(
                      label: 'Save Park',
                      onPressed: onSavePark,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
