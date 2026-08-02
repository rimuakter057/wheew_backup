import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
import 'package:platchatapp/feature/profile/repository/user_model.dart';
import 'package:platchatapp/feature/scan/controller/scan_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/core/service/storage_service.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/scan/controller/qr_card_webview.dart';
import 'package:platchatapp/feature/scan/presentation/widget/download_qr_code.dart';
import 'package:platchatapp/main.dart';

import '../../../../../helper/custom_image/custom_image.dart';
import '../../../../../utils/assets_path/assets_path.dart';

class ProfileHeaderCard extends StatelessWidget {
  final ProfileController controller;
  final ScanController scanController;

  const ProfileHeaderCard({
    super.key,
    required this.controller,
    required this.scanController,
  });

  @override
  Widget build(BuildContext context) {
    final user = controller.userProfile.value;

    final avatarUrl = user?.avatar;
    final isVerified = user?.isVehicleVerified;

    final location = [
      user?.city,
      user?.country,
    ].where((e) => e != null && e.isNotEmpty).join(", ");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopRow(context, user, avatarUrl, isVerified, location),
        SizedBox(height: ResponsiveHelper.height(16)),
        SizedBox(
          height: ResponsiveHelper.height(44),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildDocumentChip(
                icon: AssetsPath.profileOneIcon,
                label: AppStrings.driversLicense.tr,
                days: _daysUntilExpiry(user, 'LICENSE'),
              ),
              SizedBox(width: ResponsiveHelper.width(10)),
              _buildDocumentChip(
                icon: AssetsPath.profileTwoIcon,
                label: AppStrings.carTax.tr,
                days: _daysUntilExpiry(user, 'TAX'),
              ),
              SizedBox(width: ResponsiveHelper.width(10)),
              _buildDocumentChip(
                icon: AssetsPath.profileThreeIcon,
                label: AppStrings.carInspection.tr,
                days: _daysUntilExpiry(user, 'CAR_INSPECTION'),
              ),
              SizedBox(width: ResponsiveHelper.width(10)),
              _buildDocumentChip(
                icon: AssetsPath.profileFourIcon,
                label: AppStrings.carInsurance.tr,
                days: _daysUntilExpiry(user, 'INSURANCE'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentChip({
    required String icon,
    required String label,
    required int? days,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.padding(12),
        vertical: ResponsiveHelper.padding(10),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomImage(
            imageSrc: icon,
            width: ResponsiveHelper.iconSize(18),
            height: ResponsiveHelper.iconSize(18),
          ),
          SizedBox(width: ResponsiveHelper.width(6)),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(11),
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
          if (days != null) ...[
            SizedBox(width: ResponsiveHelper.width(6)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.padding(6),
                vertical: ResponsiveHelper.padding(2),
              ),
              decoration: BoxDecoration(
                color: AppColors.blue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$days',
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(11),
                  fontWeight: FontWeight.w700,
                  color: AppColors.blue,
                ),
              ),
            ),
            SizedBox(width: ResponsiveHelper.width(4)),
            Text(
              AppStrings.daysLeft.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(10),
                color: const Color(0xFF555555),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Reads daysUntilExpiry for the given document type from the user's
  /// normalized `documents` list (ported from the legacy profile screen).
  int? _daysUntilExpiry(UserModel? user, String docType) {
    if (user == null) return null;
    for (final doc in user.documents) {
      final type = (doc['document_type'] ?? '').toString().toUpperCase();
      if (type == docType) {
        final days = doc['daysUntilExpiry'];
        if (days is num) return days.toInt();
      }
    }
    return null;
  }

  Widget _buildTopRow(
    BuildContext context,
    UserModel? user,
    String? avatarUrl,
    bool? isVerified,
    String location,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,

      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ///==================== LEFT ====================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              /// Name + Verify
              Row(
                children: [
                  Text(
                    user?.nickName.isNotEmpty == true
                        ? user!.nickName
                        : AppStrings.unknown.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                      fontSize: ResponsiveHelper.fontSize(22),
                    ),
                  ),

                  SizedBox(width: ResponsiveHelper.width(2)),

                  GestureDetector(
                    onTap: () async {
                      if (isVerified == false) {
                        await context.pushNamed(RouteName.profile);
                        controller.reloadProfile();
                      }
                    },
                    child: CustomImage(
                      imageSrc: isVerified == true
                          ? AssetsPath.verified
                          : AssetsPath.unverified,
                      width: ResponsiveHelper.iconSize(18),
                      height: ResponsiveHelper.iconSize(18),
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveHelper.height(14)),

              /// Vehicle Model
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.vehicleModel.tr,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(13),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF555555),
                    ),
                  ),

                  Text(
                    user?.vehicleModel ?? "N/A",
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(13),
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveHelper.height(18)),

              /// Location
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: AppColors.blue,
                    size: ResponsiveHelper.iconSize(20),
                  ),

                  SizedBox(width: ResponsiveHelper.width(6)),

                  Expanded(
                    child: Text(
                      location.isEmpty ? "N/A" : location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(14),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff3A3A3A),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(width: ResponsiveHelper.width(22)),

        /// Avatar Section with Scan/QR Overlay on Top-Left
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () {
                if (avatarUrl != null && avatarUrl.isNotEmpty) {
                  context.pushNamed(RouteName.showProfile, extra: avatarUrl);
                }
              },
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: ResponsiveHelper.width(40),
                      backgroundColor: Colors.white.withOpacity(0.15),
                      backgroundImage: NetworkImage(
                        (avatarUrl != null && avatarUrl.isNotEmpty)
                            ? avatarUrl
                            : AppConst.unknown,
                      ),
                    ),
                  ),
                  if (controller.isLoading)
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            ///================= scan overlay ================================
            Positioned(
              bottom: -ResponsiveHelper.height(4),
              right: -ResponsiveHelper.width(4),
              child: FutureBuilder<bool?>(
                future: SharePrefsHelper.getBool(AppConst.licenseNoVerified),
                builder: (context, snapshot) {
                  final bool isVerified = snapshot.data ?? false;

                  return InkWell(
                    onTap: () {
                      if (scanController.qrCardHtml.value.isEmpty) {
                        scanController.getQrCode();
                      }

                      debugPrint(
                        "Current context: ${qrCardKey.currentContext}",
                      );

                      showModalBottomSheet(
                        context: context,
                        backgroundColor: AppColors.white,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(
                              ResponsiveHelper.borderRadius(24),
                            ),
                          ),
                        ),
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom:
                                  MediaQuery.of(context).viewInsets.bottom +
                                  ResponsiveHelper.padding(24),
                              left: ResponsiveHelper.padding(16),
                              right: ResponsiveHelper.padding(16),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: ResponsiveHelper.all(20),
                              constraints: BoxConstraints(
                                minHeight: ResponsiveHelper.height(650),
                                maxHeight: ResponsiveHelper.height(650),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () => context.pop(),
                                        icon: Icon(
                                          Icons.close,
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Obx(() {
                                      if (scanController.isLoadingQr.value) {
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.blue,
                                            strokeWidth: 2.5,
                                          ),
                                        );
                                      }

                                      if (scanController
                                          .qrCardHtml
                                          .value
                                          .isEmpty) {
                                        return Center(
                                          child: GestureDetector(
                                            onTap: () =>
                                                scanController.getQrCode(),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.refresh_rounded,
                                                  color: Colors.grey.shade400,
                                                  size: 36,
                                                ),
                                                SizedBox(
                                                  height:
                                                      ResponsiveHelper.spacing(
                                                        8,
                                                      ),
                                                ),
                                                Text(
                                                  AppStrings.tapToRetry.tr,
                                                  style: GoogleFonts.poppins(
                                                    fontSize:
                                                        ResponsiveHelper.fontSize(
                                                          13,
                                                        ),
                                                    color: Colors.grey.shade400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                      return RepaintBoundary(
                                        key: qrCardKey,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            ResponsiveHelper.borderRadius(16),
                                          ),
                                          child: QrCardWebView(
                                            htmlContent:
                                                scanController.qrCardHtml.value,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  SizedBox(
                                    height: ResponsiveHelper.spacing(16),
                                  ),
                                  Obx(() {
                                    if (scanController
                                        .qrCardHtml
                                        .value
                                        .isEmpty) {
                                      return const SizedBox.shrink();
                                    }

                                    return SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            scanController.isDownloadingQr.value
                                            ? null
                                            : () async {
                                                scanController
                                                        .isDownloadingQr
                                                        .value =
                                                    true;

                                                try {
                                                  await downloadQrCard(context);

                                                  if (context.mounted)
                                                    Navigator.pop(context);
                                                } finally {
                                                  scanController
                                                          .isDownloadingQr
                                                          .value =
                                                      false;
                                                }
                                              },
                                        icon:
                                            scanController.isDownloadingQr.value
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : const Icon(
                                                Icons.download_rounded,
                                                color: Colors.white,
                                              ),
                                        label: Text(
                                          scanController.isDownloadingQr.value
                                              ? AppStrings.downloading.tr
                                              : AppStrings.download.tr,
                                          style: GoogleFonts.poppins(
                                            fontSize: ResponsiveHelper.fontSize(
                                              15,
                                            ),
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF3D72E8,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: ResponsiveHelper.padding(
                                              14,
                                            ),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              ResponsiveHelper.borderRadius(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  SizedBox(
                                    height: ResponsiveHelper.spacing(46),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.borderRadius(12),
                    ),
                    child: Container(
                      width: ResponsiveHelper.width(38),
                      height: ResponsiveHelper.width(38),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFFF3F7FB),
                        shape: BoxShape.circle,
                      ),
                      child: CustomImage(
                        imageSrc: AssetsPath.scanIcon,
                        width: ResponsiveHelper.width(16),
                        height: ResponsiveHelper.width(16),
                        imageColor: Color(0xFF6B89A9),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
