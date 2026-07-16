
import 'dart:convert';
import 'package:platchatapp/utils/language/app_string.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/scan/controller/scan_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/avatar/user_avatar.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';

class MyQrView extends StatelessWidget {
  final ScanController scanController;
  final String? avatarUrl;
  final String? name;
  final double? rating;
  final  EdgeInsetsGeometry?margin;


  const MyQrView({
    super.key,
    required this.scanController,
    this.avatarUrl,
    this.name,
    this.rating, this.margin,

  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: ResponsiveHelper.all(20),
      margin:ResponsiveHelper.symmetric(vertical: 60,horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Avatar ─────────────────────────────────


Text("My QR Code",style: context.bodyMedium.copyWith(color: AppColors.black),),
          SizedBox(height: ResponsiveHelper.spacing(32)),
          UserAvatar(imagePath: avatarUrl??AppConst.unknown),

          SizedBox(height: ResponsiveHelper.spacing(12)),

          // ── Name ───────────────────────────────────
          Text(
            name?.isNotEmpty == true ? name! : '---',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.fontSize(18),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: ResponsiveHelper.spacing(6)),

          // ── Rating + Location ─────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: ResponsiveHelper.iconSize(16)),
              SizedBox(width: ResponsiveHelper.spacing(4)),
              Text(
                rating != null ? rating!.toStringAsFixed(1) : '0.0',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(13),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: ResponsiveHelper.spacing(10)),


            ],
          ),

          SizedBox(height: ResponsiveHelper.spacing(24)),

          // ── QR Box ─────────────────────────────────
          Obx(() {
            if (scanController.isLoadingQr.value) {
              return Container(
                width: ResponsiveHelper.width(200),
                height: ResponsiveHelper.width(200),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF3D72E8),
                    strokeWidth: 2.5,
                  ),
                ),
              );
            }

            if (scanController.qrBase64.value.isNotEmpty) {
              final base64Str = scanController.qrBase64.value.replaceFirst(
                'data:image/png;base64,',
                '',
              );

              // return Container(
              //   width: ResponsiveHelper.width(200),
              //   height: ResponsiveHelper.width(200),
              //   padding: EdgeInsets.all(ResponsiveHelper.padding(14)),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFFF5F5F5),
              //     borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
              //   ),
              //   child: Image.memory(base64Decode(base64Str), fit: BoxFit.contain),
              // );
              //


              return SizedBox(
                width: ResponsiveHelper.width(200),
                height: ResponsiveHelper.width(200),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
                  ),
                  color: AppColors.black,
                  clipBehavior: Clip.antiAlias, // ⬅️ এটা দিলে ভেতরের Image-ও radius অনুযায়ী কাটা যাবে
                  child: Image.memory(base64Decode(base64Str), fit: BoxFit.contain),
                ),
              );


            }

            return GestureDetector(
              onTap: () => scanController.getScanQrCode(),
              child: Container(
                width: ResponsiveHelper.width(200),
                height: ResponsiveHelper.width(200),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: Colors.grey.shade400,
                      size: 36,
                    ),
                    SizedBox(height: ResponsiveHelper.spacing(8)),
                    Text(
                      AppStrings.tapToRetry.tr,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(13),
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          SizedBox(height: ResponsiveHelper.spacing(24)),

          // ── Caption ────────────────────────────────
          Text(
            AppStrings.letOthersScan.tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.fontSize(13),
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}