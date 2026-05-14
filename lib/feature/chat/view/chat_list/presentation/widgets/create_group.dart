// widgets/create_group_dialog.dart
// ── দায়িত্ব: Group তৈরির dialog দেখায় ──
//              Group name validate করে controller.createGroup() call করে

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';

/// Chat list screen থেকে call করা হয়
/// Group name নিয়ে controller.createGroup() trigger করে
void showCreateGroupDialog({
  required BuildContext context,
  required ChatController controller,
}) {
  final TextEditingController groupNameController =
  TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (_) => StatefulBuilder(
      builder: (ctx, setState) => Dialog(
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

                SizedBox(height: ResponsiveHelper.spacing(4)),

                // ── Dialog title ────────────────────────────
                Text(
                  'create_group_chat'.tr,
                  style: ctx.bodyMedium.copyWith(
                    color: AppColors.black,
                  ),
                ),

                SizedBox(height: ResponsiveHelper.height(8)),

                // ── Subtitle ────────────────────────────────
                Text(
                  'group_chat_subtitle'.tr,
                  style: ctx.bodySmall,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: ResponsiveHelper.spacing(20)),

                // ── Group name label ────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'group_name'.tr,
                    style: ctx.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: ResponsiveHelper.spacing(8)),

                // ── Group name input field ──────────────────
                TextFormField(
                  controller: groupNameController,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(13),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'please_enter_group_name'.tr;
                    }
                    // কমপক্ষে ৩ character লাগবে
                    if (value.trim().length < 3) {
                      return 'group_name_min_chars'.tr;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'enter_group_name'.tr,
                  ),
                ),

                SizedBox(height: ResponsiveHelper.spacing(16)),

                // ── Create group submit button ──────────────
                SizedBox(
                  width: double.infinity,
                  height: ResponsiveHelper.buttonHeight(48),
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final String groupName =
                        groupNameController.text.trim();
                        Navigator.pop(ctx); // dialog বন্ধ করো
                        // Controller এ group create call
                        controller.createGroup(groupName: groupName);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueClient,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(12),
                        ),
                      ),
                    ),
                    child: Text(
                      'create_group'.tr,
                      style: ctx.bodySmall.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}