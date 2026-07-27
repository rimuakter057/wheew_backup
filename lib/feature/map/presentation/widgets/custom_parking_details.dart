import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:platchatapp/helper/custom_gradient_button/custom_gradient_button.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class CustomParkingDetailsDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String distance;
  final String rating;
  final String tag;
  final IconData tagIcon;
  final Color tagColor;
  final String spots;
  final String buttonText;
  final String price;
  final VoidCallback onClose;
  final VoidCallback onGetDirections;

  const CustomParkingDetailsDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.rating,
    required this.tag,
    required this.tagIcon,
    required this.tagColor,
    required this.spots,
    required this.price,
    required this.onClose,
    required this.onGetDirections, required this.buttonText,
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
                            style: TextStyle(
                              fontSize: ResponsiveHelper.fontSize(15),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.fontSize(10),
                              color: const Color(0xFF64748B),
                            ),
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [

                              const Icon(
                                Icons.location_on_outlined,
                                size: 11,
                                color: Color(0xFF0077B6),
                              ),

                              const SizedBox(width: 3),

                              Text(
                                distance,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF334155),
                                ),
                              ),

                              const SizedBox(width: 10),

                              const Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: Color(0xFF334155),
                              ),

                              const SizedBox(width: 3),

                              Text(
                                rating,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ================= TAG =================

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.12),
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
                            tag,
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

              const SizedBox(height: 8),

              // ================= BUTTON =================

              CustomGradientButton(
                label: buttonText,
                onPressed: onGetDirections,
              ),
            ],
          ),
        ),
      ),
    );
  }
}