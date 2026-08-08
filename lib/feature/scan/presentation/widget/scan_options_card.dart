import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
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
      color: AppColors.transparent,
      child: Container(
        padding: EdgeInsets.all(ResponsiveHelper.padding(8)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ScanOptionTile(
              svgIcon: AssetsPath.ocrScannerSvg,
              title: AppStrings.ocrScanner.tr,
              subtitle: AppStrings.ocrScannerSubtitle.tr,
              highlighted: false,
              onTap: onOcrTap,
            ),
            SizedBox(height: ResponsiveHelper.spacing(8)),
            _ScanOptionTile(
              svgIcon: AssetsPath.scanQrSvg,
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
  final String svgIcon;
  final String title;
  final String subtitle;
  final bool highlighted;
  final VoidCallback onTap;

  const _ScanOptionTile({
    required this.svgIcon,
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
                    ? AppColors.white.withValues(alpha: 0.2)
                    : AppColors.blue.withValues(alpha: 0.1),
              ),
              child: Center(
                child: SvgPicture.asset(
                  svgIcon,
                  width: ResponsiveHelper.iconSize(18),
                  height: ResponsiveHelper.iconSize(18),
                  colorFilter: ColorFilter.mode(
                    highlighted ? AppColors.white : AppColors.blue,
                    BlendMode.srcIn,
                  ),
                ),
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
                      color: highlighted ? AppColors.white : AppColors.black,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(2)),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(11.5),
                      color: highlighted
                          ? AppColors.white.withOpacity(0.85)
                          : AppColors.greyShade600,
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


