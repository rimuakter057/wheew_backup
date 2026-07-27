import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';

/// Shared "OCR Scanner / Scan QR Code" chooser card — used both as a
/// floating overlay above the bottom nav's Scan tab and inside the
/// chat list's scan bottom sheet, so both entry points look identical.
class ScanOptionsCard extends StatelessWidget {
  final VoidCallback onOcrTap;
  final VoidCallback onQrTap;

  const ScanOptionsCard({
    super.key,
    required this.onOcrTap,
    required this.onQrTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(ResponsiveHelper.padding(8)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ScanOptionTile(
              icon: Icons.document_scanner_outlined,
              title: AppStrings.ocrScanner.tr,
              subtitle: AppStrings.ocrScannerSubtitle.tr,
              highlighted: false,
              onTap: onOcrTap,
            ),
            SizedBox(height: ResponsiveHelper.spacing(8)),
            _ScanOptionTile(
              icon: Icons.qr_code_scanner_rounded,
              title: AppStrings.scanQrCode.tr,
              subtitle: AppStrings.scanQrCodeSubtitle.tr,
              highlighted: true,
              onTap: onQrTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool highlighted;
  final VoidCallback onTap;

  const _ScanOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(18)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(ResponsiveHelper.padding(14)),
        decoration: BoxDecoration(
          gradient: highlighted
              ? LinearGradient(
            colors: [AppColors.blue, AppColors.darBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: highlighted ? null : AppColors.softBrandColor,
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(18)),
        ),
        child: Row(
          children: [
            Container(
              width: ResponsiveHelper.width(38),
              height: ResponsiveHelper.width(38),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: highlighted
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.blue.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                size: ResponsiveHelper.iconSize(18),
                color: highlighted ? Colors.white : AppColors.blue,
              ),
            ),
            SizedBox(width: ResponsiveHelper.spacing(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(14),
                      fontWeight: FontWeight.w600,
                      color: highlighted ? Colors.white : AppColors.black,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(2)),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(11.5),
                      color: highlighted
                          ? Colors.white.withOpacity(0.85)
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
