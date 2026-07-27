// widgets/rating_dialog.dart

import 'package:flutter/material.dart';
import 'package:platchatapp/helper/custom_gradient_button/custom_gradient_button.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

import '../../../../../../utils/color/app_colors.dart';

void showRatingDialog({
  required BuildContext context,
  required String image,
  required String name,
  required String status,
  required String receiverId,
}) {
  final ChatController chatController = Get.find<ChatController>();
  final int existing =
      chatController.myRatingForRatee.value?.rating ?? 0;
  double ratingValue =
  existing >= 1 && existing <= 5 ? existing.toDouble() : 0;
  final bool isUpdate =
      chatController.myRatingForRatee.value?.id.isNotEmpty == true;

  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (_) => StatefulBuilder(
      builder: (dialogContext, setState) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.spacing(24),
        ),
        child: Container(
          padding: EdgeInsets.only(
            top: ResponsiveHelper.spacing(20),
            left: ResponsiveHelper.spacing(20),
            right: ResponsiveHelper.spacing(20),
            bottom: ResponsiveHelper.spacing(24),
          ),
          decoration: BoxDecoration(
            gradient: AppColors.containerGradient,
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.borderRadius(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              // ── Close Button ────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ///status show here











            GestureDetector(
                      onTap: () => Navigator.pop(dialogContext),
                      child: Container(
                        padding:
                        EdgeInsets.all(ResponsiveHelper.spacing(4)),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: ResponsiveHelper.iconSize(16),
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
          ],
        ),


              SizedBox(height: ResponsiveHelper.spacing(4)),

              // ── Avatar ──────────────────────────────────
              CircleAvatar(
                radius: ResponsiveHelper.borderRadius(30),
                backgroundImage: NetworkImage(
                  ImageHandler.imagesHandle(image, isProfile: true),
                ),
              ),

              SizedBox(height: ResponsiveHelper.spacing(12)),


              Row(
               // crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.spacing(10),
                      vertical: ResponsiveHelper.spacing(4),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(4),
                      ),
                    ),
                    child: Text(
                      status.isEmpty ? 'None' : status,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(11),
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                  ),

                  SizedBox(width: ResponsiveHelper.spacing(6)),

                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.borderRadius(12),
                            ),
                          ),
                          title: Row(
                            children: [
                              Icon(Icons.info_outline, color: AppColors.blue),
                              SizedBox(width: ResponsiveHelper.spacing(8)),
                              Text(
                                AppStrings.statusInfo.tr,
                                style: GoogleFonts.poppins(
                                    fontSize: ResponsiveHelper.fontSize(16),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black
                                ),
                              ),
                            ],
                          ),
                          content: Text(
                            _getStatusInfo(status),
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveHelper.fontSize(13),
                              fontWeight: FontWeight.w400,
                              color: AppColors.black,
                              height: 1.5,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                AppStrings.gotIt.tr,
                                style: GoogleFonts.poppins(
                                  color: AppColors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: SvgPicture.asset(
                      "assets/icons/i.svg",
                      width: ResponsiveHelper.iconSize(18),
                      height: ResponsiveHelper.iconSize(18),
                      colorFilter: const ColorFilter.mode(
                        AppColors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveHelper.spacing(10)),

              // ── Name ────────────────────────────────────
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),

              SizedBox(height: ResponsiveHelper.spacing(4)),

              Text(
                isUpdate
                    ? AppStrings.updateRating.tr
                    : AppStrings.addRating.tr,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(12),
                  color: AppColors.black.withOpacity(0.5),
                  fontWeight: FontWeight.w400
                ),
              ),

              SizedBox(height: ResponsiveHelper.spacing(18)),

              // ── Star Rating ──────────────────────────────
              SizedBox(
                height: ResponsiveHelper.iconSize(50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (starIndex) {
                    final starValue = starIndex + 1;
                    return GestureDetector(
                      onTap: () => setState(() {
                        // একই star এ দ্বিতীয়বার click করলে rating reset হয়ে যাবে
                        if (ratingValue == starValue.toDouble()) {
                          ratingValue = 0;
                        } else {
                          ratingValue = starValue.toDouble();
                        }
                      }),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.spacing(2),
                        ),
                        child: _buildStarIcon(
                            starIndex, ratingValue),
                      ),
                    );
                  }),
                ),
              ),

              SizedBox(height: ResponsiveHelper.spacing(18)),





              Obx(
                    () => CustomGradientButton(
                      onPressed: ratingValue < 1 ||
                          chatController.isSubmittingRating.value
                          ? null
                          : () {
                        chatController.submitRating(
                          rateeId: receiverId,
                          rating: ratingValue,
                          context: dialogContext,
                        );
                      },
                      label: isUpdate
                          ? AppStrings.updateRating.tr
                          : AppStrings.submitRating.tr,
                      isLoading: chatController.isSubmittingRating.value,
                      keepGradientWhenDisabled: true,
                    ),
              ),

            ],
          ),
        ),
      ),
    ),
  );
}

// ── Star icon builder ─────────────────────────────────────────
Widget _buildStarIcon(int starIndex, double rating) {
  final double value = rating - starIndex;
  final IconData icon;
  final Color color;

  if (value >= 1.0) {
    icon = Icons.star_rounded;
    color = Colors.amber;
  } else if (value >= 0.5) {
    icon = Icons.star_half_rounded;
    color = Colors.amber;
  } else {
    icon = Icons.star_outline_rounded;
    color = AppColors.black.withOpacity(0.3);
  }

  return Icon(
    icon,
    color: color,
    size: ResponsiveHelper.iconSize(44),
  );
}

// ── Rating label ──────────────────────────────────────────────
String _ratingLabel(double rating) {
  if (rating == 0) return '';
  if (rating <= 1.0) return AppStrings.ratingPoor.tr;
  if (rating <= 2.0) return AppStrings.ratingFair.tr;
  if (rating <= 3.0) return AppStrings.ratingGood.tr;
  if (rating <= 4.0) return AppStrings.ratingGreat.tr;
  return AppStrings.ratingExcellent.tr;
}



String _getStatusInfo(String status) {
  switch (status.toUpperCase()) {
    case 'PENDING':
      return 'You have rated this request. Waiting for admin to review and update the final status.';
    case 'COMPLETE':
      return 'This request has been completed and approved by the admin.';
    default: // empty / none
      return 'No status yet. Once you submit a rating, the status will update automatically.';
  }
}