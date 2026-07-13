// widgets/create_group_dialog.dart
// ── দায়িত্ব: Group তৈরির dialog দেখায় ──
//              Group name validate করে controller.createGroup() call করে

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/utils/language/app_string.dart';

/// Chat list screen থেকে call করা হয়
/// Group name নিয়ে controller.createGroup() trigger করে
void showCreateGroupDialog({
  required BuildContext context,
  required ChatController controller,
}) {
  final TextEditingController groupNameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  File? pickedImageFile;

  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (_) => StatefulBuilder(
      builder: (ctx, setState) {
        Future<void> pickImage() async {
          try {
            final picked = await ImagePicker().pickImage(
              source: ImageSource.gallery,
              imageQuality: 80,
            );
            if (picked != null) {
              setState(() {
                pickedImageFile = File(picked.path);
              });
            }
          } catch (e) {
            debugPrint('pickImage error: $e');
          }
        }

        return Dialog(
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
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Close button ────────────────────────────
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: EdgeInsets.all(
                          ResponsiveHelper.spacing(4),
                        ),
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

                  // Title
                  Text(
                    'create_group_chat'.tr,
                    style: ctx.bodyMedium.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.height(6)),

                  // Subtitle
                  Text(
                    'group_chat_subtitle'.tr,
                    style: ctx.bodySmall.copyWith(
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(16)),

                  // Profile Picture Section
                  Text(
                    'Profile Picture'.tr,
                    style: ctx.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(8)),

                  GestureDetector(
                    onTap: pickImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade100,
                            border: Border.all(color: Colors.grey.shade200, width: 2),
                            image: pickedImageFile != null
                                ? DecorationImage(
                              image: FileImage(pickedImageFile!),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: pickedImageFile == null
                              ? Icon(
                            Icons.groups,
                            size: 40,
                            color: Colors.grey.shade400,
                          )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(20)),

                  // Group Name Label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'group_name'.tr,
                      style: ctx.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(8)),

                  // Group Name input field
                  TextFormField(
                    controller: groupNameController,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(14),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'please_enter_group_name'.tr;
                      }
                      if (value.trim().length < 3) {
                        return 'group_name_min_chars'.tr;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: AppStrings.groupNameHint.tr,
                      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF5F6F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(24)),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final String groupName = groupNameController.text.trim();
                          Navigator.pop(ctx);

                          final success = await controller.createGroup(
                            groupName: groupName,
                            imagePath: pickedImageFile?.path,
                          );

                          if (success) {
                            CustomSnackbar.success(
                              context: context,
                              message: AppStrings.groupCreatedSuccess.tr,
                            );
                          } else {
                            CustomSnackbar.error(
                              context: context,
                              message: AppStrings.groupCreatedFailed.tr,
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: Text(
                        'create_group'.tr,
                        style: ctx.bodySmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}