import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:platchatapp/feature/scan/presentation/widget/scan_painter.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

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
    final double boxSize = ResponsiveHelper.width(280);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: ResponsiveHelper.spacing(32)),
          Stack(
            alignment: Alignment.center,
            children: [
              // ── Camera ───────────────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(20),
                ),
                child: SizedBox(
                  width: boxSize,
                  height: boxSize,
                  child: MobileScanner(
                    controller: scannerController,
                    onDetect: onDetect,
                    errorBuilder: (context, error) =>
                        CameraErrorWidget(boxSize: boxSize, error: error),
                  ),
                ),
              ),
      
              // ── Scanning line ─────────────────────────────────────────────
              if (!isScanned)
                SizedBox(
                  width: boxSize,
                  height: boxSize,
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
                                    Colors.transparent,
                                    const Color(0xFF3D72E8).withOpacity(0.8),
                                    const Color(0xFF3D72E8),
                                    const Color(0xFF3D72E8).withOpacity(0.8),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    const Color(0xFF3D72E8).withOpacity(0.5),
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
      
              // ── Loading overlay ───────────────────────────────────────────
              if (isLoading)
                Container(
                  width: boxSize,
                  height: boxSize,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.borderRadius(20),
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3D72E8),
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
      
              // ── Success overlay ───────────────────────────────────────────
              if (isScanned && !isLoading)
                Container(
                  width: boxSize,
                  height: boxSize,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.borderRadius(20),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF3D72E8),
                      size: 64,
                    ),
                  ),
                ),
      
              // ── Corner markers ────────────────────────────────────────────
              SizedBox(
                width: boxSize,
                height: boxSize,
                child: CustomPaint(
                  painter: CornerPainter(
                    color: const Color(0xFF3D72E8),
                    cornerSize: ResponsiveHelper.width(28),
                    strokeWidth: ResponsiveHelper.borderWidth(3),
                    radius: ResponsiveHelper.borderRadius(8),
                  ),
                ),
              ),
            ],
          ),
      
          SizedBox(height: ResponsiveHelper.spacing(28)),
      
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.padding(40),
            ),
            child: Text(
              'point_camera_hint'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(13),
                color: Colors.white.withOpacity(0.45),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}