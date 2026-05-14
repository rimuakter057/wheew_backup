// widgets/rating_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

void showRatingDialog({
  required BuildContext context,
  required String image,
  required String name,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.borderRadius(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Close Button ────────────────────────────
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
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
              ),

              SizedBox(height: ResponsiveHelper.spacing(4)),

              // ── Avatar ──────────────────────────────────
              CircleAvatar(
                radius: ResponsiveHelper.borderRadius(30),
                backgroundImage: NetworkImage(
                  ImageHandler.imagesHandle(image, isProfile: true),
                ),
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
                    ? 'update_your_rating'.tr
                    : 'tap_to_rate'.tr,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(12),
                  color: Colors.grey.shade400,
                ),
              ),

              SizedBox(height: ResponsiveHelper.spacing(24)),

              // ── Star Rating ──────────────────────────────
              SizedBox(
                height: ResponsiveHelper.iconSize(50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (starIndex) {
                    final starValue = starIndex + 1;
                    return GestureDetector(
                      onTap: () => setState(
                              () => ratingValue = starValue.toDouble()),
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

              SizedBox(height: ResponsiveHelper.spacing(8)),

              // ── Rating Label ─────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  key: ValueKey(ratingValue),
                  _ratingLabel(ratingValue),
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(14),
                    color: ratingValue < 1
                        ? Colors.transparent
                        : Colors.amber.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: ResponsiveHelper.spacing(28)),

              // ── Submit / Update Button ───────────────────
              Obx(() => SizedBox(
                width: double.infinity,
                height: ResponsiveHelper.buttonHeight(48),
                child: ElevatedButton(
                  onPressed: (ratingValue < 1 ||
                      chatController
                          .isSubmittingRating.value)
                      ? null
                      : () {
                    chatController.submitRating(
                      rateeId: receiverId,
                      rating: ratingValue,
                      context: dialogContext,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueClient,
                    disabledBackgroundColor:
                    Colors.grey.shade200,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(12),
                      ),
                    ),
                  ),
                  child:
                  chatController.isSubmittingRating.value
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    isUpdate
                        ? 'update_rating'.tr
                        : 'submit_rating'.tr,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize:
                      ResponsiveHelper.fontSize(
                          14),
                    ),
                  ),
                ),
              )),
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
    color = Colors.grey.shade300;
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
  if (rating <= 1.0) return 'rating_poor'.tr;
  if (rating <= 2.0) return 'rating_fair'.tr;
  if (rating <= 3.0) return 'rating_good'.tr;
  if (rating <= 4.0) return 'rating_great'.tr;
  return 'rating_excellent'.tr;
}