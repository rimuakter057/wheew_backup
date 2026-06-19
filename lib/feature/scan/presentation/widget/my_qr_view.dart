import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/scan/controller/scan_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';

class MyQrView extends StatelessWidget {
  final ScanController scanController;

  const MyQrView({super.key, required this.scanController});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Obx(() {
          // ── Loading ──────────────────────────────────
          if (scanController.isLoadingQr.value) {
            return Container(
              width: ResponsiveHelper.width(240),
              height: ResponsiveHelper.width(240),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(24),
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF3D72E8),
                  strokeWidth: 2.5,
                ),
              ),
            );
          }

          // ── QR Image ─────────────────────────────────
          if (scanController.qrBase64.value.isNotEmpty) {
            final base64Str = scanController.qrBase64.value.replaceFirst(
              'data:image/png;base64,',
              '',
            );

            return Container(
              width: ResponsiveHelper.width(240),
              height: ResponsiveHelper.width(240),
              padding: EdgeInsets.all(ResponsiveHelper.padding(16)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3D72E8).withOpacity(0.22),
                    blurRadius: 32,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.memory(base64Decode(base64Str), fit: BoxFit.contain),
            );
          }

          // ── Error / Empty ─────────────────────────────
          return GestureDetector(
            onTap: () => scanController.getQrCode(),
            child: Container(
              width: ResponsiveHelper.width(240),
              height: ResponsiveHelper.width(240),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(24),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    color: Colors.white.withOpacity(0.4),
                    size: 40,
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(8)),
                  Text(
                    'Tap to retry',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(13),
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        SizedBox(height: ResponsiveHelper.spacing(28)),

        Padding(
          padding: ResponsiveHelper.all(8.0),
          child: Text(
            'let_others_scan'.tr,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.fontSize(13),
              color: Colors.white.withOpacity(0.45),
            ),
          ),
        ),
      ],
    );
  }
}