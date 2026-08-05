import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';

class CustomParkingDetailsDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String distance;
  final String rating;

  /// Grey when [rating] has no real value (backend sent null), otherwise
  /// the normal accent color.
  final Color ratingColor;

  /// null when the area's parkingAreaTypes list is empty — hides the badge.
  final String? tag;
  final IconData? tagIcon;
  final Color? tagColor;
  final String spots;
  final String price;
  final VoidCallback onClose;

  /// "Free" / "Paid" label shown next to [subtitle] so the cost is clear
  /// at a glance, without waiting to reach the price row below.
  final String costStatusLabel;
  final Color costStatusColor;

  /// Small inline "Navigate" link shown next to the rating — not a full
  /// button, opens the in-app navigation screen for this spot.
  final VoidCallback? onNavigate;

  const CustomParkingDetailsDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.rating,
    required this.ratingColor,
    required this.tag,
    required this.tagIcon,
    required this.tagColor,
    required this.spots,
    required this.price,
    required this.onClose,
    required this.costStatusLabel,
    required this.costStatusColor,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        ResponsiveHelper.borderRadius(32),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ),
        child: Container(
          width: double.infinity,
          padding: ResponsiveHelper.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.parkingContainerGradient,
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.borderRadius(32),
            ),
            border: Border.all(
              color: Colors.white,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF071224).withOpacity(0.04),
                offset: const Offset(0, 4),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ================= HEADER =================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.titleMedium.copyWith(color: AppColors.black,fontSize: ResponsiveHelper.fontSize(18))
                          ),

                       SizedBox(height: ResponsiveHelper.height(8)),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.bodySmall.copyWith(color: AppColors.greyText)
                                ),
                              ),
                              SizedBox(height: ResponsiveHelper.height(6)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: costStatusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  costStatusLabel,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: costStatusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: ResponsiveHelper.height(12)),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,


                children: [

                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [

                        Icon(
                            Icons.location_on_outlined,
                            size: ResponsiveHelper.iconSize(16),
                            color: AppColors.blue
                        ),

                        const SizedBox(width: 3),

                        Text(
                            distance,
                            style: context.bodySmall.copyWith(fontSize: ResponsiveHelper.fontSize(14),fontWeight: FontWeight.w600)
                        ),

                        const SizedBox(width: 10),


                        Icon(
                          Icons.star_rounded,
                          size: ResponsiveHelper.iconSize(16),
                          color: ratingColor,
                        ),

                        const SizedBox(width: 3),

                        Text(
                            rating,
                            style:context.bodySmall.copyWith(fontWeight: FontWeight.w600)
                        ),


                      ],
                    ),
                  ),
                ),

                if (onNavigate != null) ...[

                  SizedBox(width: ResponsiveHelper.spacing(8)),

                  GestureDetector(
                    onTap: onNavigate,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         Icon(
                          Icons.near_me_outlined,
                          size: ResponsiveHelper.iconSize(16),
                          color:AppColors.blue,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Navigate',
                          style: context.bodyMedium.copyWith(color: AppColors.blue)
                        ),
                      ],
                    ),
                  ),
                ],


              ],)
                        ],
                      ),
                    ),

                    // ================= TAG =================
                    // parkingAreaTypes == [] → tag/tagIcon/tagColor are all
                    // null, so the badge is skipped entirely.

                    if (tag != null && tagIcon != null && tagColor != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: tagColor!.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Icon(
                              tagIcon,
                              size: 10,
                              color: tagColor,
                            ),

                            const SizedBox(width: 3),

                            Text(
                              tag!,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: tagColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 5),
                    ],

                    // ================= CLOSE =================

                    GestureDetector(
                      onTap: onClose,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ================= INFO BOX =================

              Container(
                padding: ResponsiveHelper.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [

                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          const Icon(
                            Icons.map_outlined,
                            size: 14,
                            color: Color(0xFF475569),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            spots,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      height: 22,
                      width: 1,
                      color: Colors.white.withOpacity(0.5),
                    ),

                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          const Icon(
                            Icons.monetization_on_outlined,
                            size: 14,
                            color: Color(0xFF475569),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            price,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF64748B),
                            ),
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
    );
  }
}