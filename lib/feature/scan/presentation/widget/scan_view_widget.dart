import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:platchatapp/feature/scan/presentation/widget/scan_painter.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

/// Full-screen QR scanner: live camera feed behind a frosted, tinted
/// overlay with a clear cutout (rounded square + blue corner brackets)
/// where the camera stays sharp — matches the Scan QR Code design.
class ScanView extends StatelessWidget {
  final MobileScannerController scannerController;
  final Animation<double> lineAnimation;
  final bool isScanned;
  final bool isLoading;
  final void Function(BarcodeCapture) onDetect;

  const ScanView({
    super.key,
    required this.scannerController,
    required this.lineAnimation,
    required this.isScanned,
    required this.isLoading,
    required this.onDetect,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double boxSize = size.width * 0.72;
    final double radius = ResponsiveHelper.borderRadius(24);
    final Rect cutout = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.4),
      width: boxSize,
      height: boxSize,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // -- Full-screen camera feed ---------------------------------
        MobileScanner(
          controller: scannerController,
          onDetect: onDetect,
          errorBuilder: (context, error) => Container(
            color: const Color(0xFF1A1A1A),
            alignment: Alignment.center,
            child: CameraErrorWidget(boxSize: size.width * 0.8, error: error),
          ),
        ),

        // -- Frosted, tinted overlay everywhere except the cutout ----
        ClipPath(
          clipper: _CutoutClipper(cutout: cutout, radius: radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.lightBlue.withOpacity(0.6),
                    AppColors.blueGrey.withOpacity(0.65),
                  ],
                ),
              ),
            ),
          ),
        ),

        // -- Corner markers -------------------------------------------
        Positioned.fromRect(
          rect: cutout,
          child: CustomPaint(
            painter: CornerPainter(
              color: AppColors.blue,
              cornerSize: ResponsiveHelper.width(28),
              strokeWidth: ResponsiveHelper.borderWidth(3),
              radius: radius,
            ),
          ),
        ),

        // -- Scanning line ---------------------------------------------
        if (!isScanned)
          Positioned.fromRect(
            rect: cutout,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: AnimatedBuilder(
                animation: lineAnimation,
                builder: (_, __) {
                  return Stack(
                    children: [
                      Positioned(
                        top: lineAnimation.value * (boxSize - 4),
                        left: 12,
                        right: 12,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.transparent,
                                AppColors.blue.withOpacity(0.8),
                                AppColors.blue,
                                AppColors.blue.withOpacity(0.8),
                                AppColors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blue.withOpacity(0.5),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

        // -- Loading overlay -------------------------------------------
        if (isLoading)
          Positioned.fromRect(
            rect: cutout,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Center(
                child: CircularProgressIndicator(

                  color: AppColors.blue,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ),

        // -- Success overlay -------------------------------------------
        if (isScanned && !isLoading)
          Positioned.fromRect(
            rect: cutout,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Center(
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.blue,
                  size: 64,
                ),
              ),
            ),
          ),

        // -- Instructional hint below the cutout ----------------------
        Positioned(
          left: 0,
          right: 0,
          top: cutout.bottom + ResponsiveHelper.spacing(24),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.padding(40),
            ),
            child: Text(
              AppStrings.pointCameraHint.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(13),
                color: AppColors.black.withOpacity(0.65),
                height: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Clips everything except a rounded-rect cutout, so the frosted overlay
/// above only tints the area outside the scan frame.
class _CutoutClipper extends CustomClipper<Path> {
  final Rect cutout;
  final double radius;

  _CutoutClipper({required this.cutout, required this.radius});

  @override
  Path getClip(Size size) {
    final outer = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final inner = Path()
      ..addRRect(RRect.fromRectAndRadius(cutout, Radius.circular(radius)));
    return Path.combine(PathOperation.difference, outer, inner);
  }

  @override
  bool shouldReclip(covariant _CutoutClipper oldClipper) =>
      oldClipper.cutout != cutout || oldClipper.radius != radius;
}


