import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

/// ─── Corner Painter ───────────────────────────────────────────────────────────

class CornerPainter extends CustomPainter {
  final Color color;
  final double cornerSize;
  final double strokeWidth;
  final double radius;

  CornerPainter({
    required this.color,
    required this.cornerSize,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double r = radius;
    final double c = cornerSize;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, c)
        ..lineTo(0, r)
        ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
        ..lineTo(c, 0),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - c, 0)
        ..lineTo(size.width - r, 0)
        ..arcToPoint(Offset(size.width, r), radius: Radius.circular(r))
        ..lineTo(size.width, c),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - c)
        ..lineTo(0, size.height - r)
        ..arcToPoint(
          Offset(r, size.height),
          radius: Radius.circular(r),
          clockwise: false,
        )
        ..lineTo(c, size.height),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - c, size.height)
        ..lineTo(size.width - r, size.height)
        ..arcToPoint(
          Offset(size.width, size.height - r),
          radius: Radius.circular(r),
          clockwise: false,
        )
        ..lineTo(size.width, size.height - c),
      paint,
    );
  }

  @override
  bool shouldRepaint(CornerPainter old) =>
      old.color != color ||
          old.cornerSize != cornerSize ||
          old.strokeWidth != strokeWidth;
}

/// ─── Camera Error Widget ──────────────────────────────────────────────────────

class CameraErrorWidget extends StatelessWidget {
  final double boxSize;
  final MobileScannerException error;

  const CameraErrorWidget({
    super.key,
    required this.boxSize,
    required this.error,
  });

  String get _message {
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return 'camera_permission_denied'.tr;
      case MobileScannerErrorCode.unsupported:
        return 'camera_unsupported'.tr;
      default:
        return 'camera_error'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            color: Colors.white.withOpacity(0.2),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            _message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.4),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// ─── Tab Button ───────────────────────────────────────────────────────────────

class ScanTabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const ScanTabButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.borderRadius(26),
            ),
            boxShadow: isActive
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(13),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? const Color(0xFF1A1A2E)
                    : Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}