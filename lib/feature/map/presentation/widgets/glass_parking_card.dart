import 'package:platchatapp/utils/color/app_colors.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:platchatapp/utils/language/app_string.dart';

class GlassParkingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String distance;
  final String rating;
  final String tagText;
  final String spotsLeft;
  final String pricePerHour;
  final VoidCallback onBookPressed;

  const GlassParkingCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.rating,
    required this.tagText,
    required this.spotsLeft,
    required this.pricePerHour,
    required this.onBookPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: BackdropFilter(
        // à¦—à§à¦²à¦¾à¦¸ à¦¬à§à¦²à¦¾à¦° à¦‡à¦«à§‡à¦•à§à¦Ÿ à¦à¦° à¦œà¦¨à§à¦¯
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            // à¦—à§à¦²à¦¾à¦¸ à¦¬à§à¦¯à¦¾à¦•à¦—à§à¦°à¦¾à¦‰à¦¨à§à¦¡ à¦•à¦¾à¦²à¦¾à¦° à¦à¦¬à¦‚ à¦…à¦ªà¦¾à¦¸à¦¿à¦Ÿà¦¿
            color: AppColors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(
              color: AppColors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // à¦¹à§‡à¦¡à¦¾à¦° à¦à¦¬à¦‚ à¦Ÿà§à¦¯à¦¾à¦—
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black87,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.electric_car, color: AppColors.green, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          tagText,
                          style: const TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey[700],
                ),
              ),
              const SizedBox(height: 12),

              // à¦¦à§‚à¦°à¦¤à§à¦¬ à¦à¦¬à¦‚ à¦°à§‡à¦Ÿà¦¿à¦‚
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppColors.blue, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    distance,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.black87,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.star, color: AppColors.indigo, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    rating,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // à¦¸à§à¦ªà¦Ÿ à¦à¦¬à¦‚ à¦ªà§à¦°à¦¾à¦‡à¦¸ à¦¸à§‡à¦•à¦¶à¦¨ (à¦‡à¦¨à¦¾à¦° à¦¬à¦•à§à¦¸)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.map_outlined, color: AppColors.black54, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            spotsLeft,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 25,
                      width: 1,
                      color: AppColors.grey.withOpacity(0.4),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.monetization_on_outlined, color: AppColors.black54, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            pricePerHour,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // à¦¬à§à¦•à¦¿à¦‚ à¦¬à¦¾à¦Ÿà¦¨
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onBookPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.materialBlue[700],
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    AppStrings.bookParkingSpot.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

