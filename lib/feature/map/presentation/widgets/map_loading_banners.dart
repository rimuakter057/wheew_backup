import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

class LocatingBanner extends StatelessWidget {
  const LocatingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + ResponsiveHelper.padding(12),
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.padding(16),
            vertical: ResponsiveHelper.padding(8),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: ResponsiveHelper.width(16),
                height: ResponsiveHelper.height(16),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF3D72E8),
                ),
              ),
              SizedBox(width: ResponsiveHelper.spacing(8)),
              Text(
                'locating'.tr.isNotEmpty ? 'locating'.tr : 'Getting location…',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(12),
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FetchingParkingBanner extends StatelessWidget {
  const FetchingParkingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + ResponsiveHelper.padding(52),
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.padding(16),
            vertical: ResponsiveHelper.padding(8),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: ResponsiveHelper.width(16),
                height: ResponsiveHelper.height(16),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF3D72E8),
                ),
              ),
              SizedBox(width: ResponsiveHelper.spacing(8)),
              Text(
                'Loading parking spots...',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(12),
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
