import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

/// Shown instead of the "Find Parking Spot" button whenever the user's
/// parking-mode status is PARKED — displays the active session (location +
/// spot code) and a full-width "Exit Parking" action.
class ParkedSessionCard extends StatelessWidget {
  final String locationName;
  final String spotCode;
  final String statusLabel;
  final VoidCallback onExitPressed;

  const ParkedSessionCard({
    super.key,
    required this.locationName,
    required this.spotCode,
    required this.onExitPressed,
    this.statusLabel = 'Active',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveHelper.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "You're Parked",
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(12),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.spacing(2)),
                    Text(
                      locationName,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(18),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.spacing(2)),
                    Text(
                      spotCode,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(13),
                        color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: ResponsiveHelper.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.chargingGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.borderRadius(20),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: ResponsiveHelper.width(7),
                      height: ResponsiveHelper.width(7),
                      decoration: const BoxDecoration(
                        color: AppColors.chargingGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.spacing(6)),
                    Text(
                      statusLabel,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(12),
                        fontWeight: FontWeight.w600,
                        color: AppColors.chargingGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.spacing(16)),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: onExitPressed,
              child: Container(
                padding: ResponsiveHelper.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.redGradient,
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.borderRadius(28),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Exit Parking',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(15),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
