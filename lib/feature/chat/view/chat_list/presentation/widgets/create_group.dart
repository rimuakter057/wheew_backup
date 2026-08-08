// widgets/create_group_dialog.dart
// -- à¦¦à¦¾à¦¯à¦¼à¦¿à¦¤à§à¦¬: Group à¦¤à§ˆà¦°à¦¿à¦° dialog à¦¦à§‡à¦–à¦¾à¦¯à¦¼ --
//              Group name validate à¦•à¦°à§‡ controller.createGroup() call à¦•à¦°à§‡

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

/// Chat list screen à¦¥à§‡à¦•à§‡ call à¦•à¦°à¦¾ à¦¹à¦¯à¦¼
/// Group name à¦¨à¦¿à¦¯à¦¼à§‡ controller.createGroup() trigger à¦•à¦°à§‡
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
    barrierColor: AppColors.black.withOpacity(0.5),
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
          backgroundColor: AppColors.transparent,
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
              color: AppColors.white,
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.borderRadius(24),
              ),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // -- Close button ----------------------------
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: EdgeInsets.all(
                          ResponsiveHelper.spacing(4),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.greyShade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: ResponsiveHelper.iconSize(16),
                          color: AppColors.greyShade600,
                        ),
                      ),
                    ),
                  ),

                  // Title
                  Text(
                    AppStrings.createGroupChat.tr,
                    style: ctx.bodyMedium.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.height(6)),

                  // Subtitle
                  Text(
                    AppStrings.groupChatSubtitle.tr,
                    style: ctx.bodySmall.copyWith(
                      color: AppColors.greyShade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(16)),

                  // Profile Picture Section
                  Text(
                    AppStrings.profilePicture.tr,
                    style: ctx.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.greyShade600,
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
                            color: AppColors.greyShade100,
                            border: Border.all(color: AppColors.greyShade200, width: 2),
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
                            color: AppColors.greyShade400,
                          )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 14,
                              color: AppColors.grey,
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
                      AppStrings.groupName.tr,
                      style: ctx.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.greyShade600,
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
                        return AppStrings.pleaseEnterGroupName.tr;
                      }
                      if (value.trim().length < 3) {
                        return AppStrings.groupNameMinChars.tr;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: AppStrings.groupNameHint.tr,
                      hintStyle: GoogleFonts.poppins(color: AppColors.greyShade400, fontSize: 14),
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
                        AppStrings.createGroup.tr,
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


