import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/utils/string/app_text_key.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../utils/color/app_colors.dart';
import '../repository/profile_controller.dart';
import '../../../share/widgets/avatar/user_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'profile'.tr,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveHelper.fontSize(18),
          ),
        ),
        actions: [
          GetBuilder<ProfileController>(
            init: ProfileController(),
            builder: (controller) {
              return TextButton(
                onPressed: () {
                  if (controller.isEditing) {
                    controller.updateProfile();
                  } else {
                    controller.toggleEdit();
                  }
                },
                child: Text(
                  controller.isEditing ? 'save'.tr : 'edit'.tr,
                  style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
                ),
              );
            },
          ),
        ],
      ),
      body: GetBuilder<ProfileController>(
        init: ProfileController(),
        builder: (controller) {
          if (controller.isLoading && controller.userProfile.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.padding(24),
            ),
            child: Column(
              children: [
                SizedBox(height: ResponsiveHelper.spacing(24)),

                /// Profile Image
                Obx(() {
                  return Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      controller.profileImage.value != null
                          ? CircleAvatar(
                        radius: ResponsiveHelper.width(45),
                        backgroundImage: FileImage(controller.profileImage.value!),
                      )
                          : UserAvatar(
                        imagePath: controller.userProfile.value?.avatar,
                        radius: ResponsiveHelper.width(45),
                      ),
                      if (controller.isEditing)
                        GestureDetector(
                          onTap: controller.pickImageFromGallery,
                          child: Container(
                            padding: EdgeInsets.all(ResponsiveHelper.padding(6)),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: ResponsiveHelper.iconSize(18),
                            ),
                          ),
                        ),
                    ],
                  );
                }),

                SizedBox(height: ResponsiveHelper.spacing(32)),

                _label('Nick Name'),
                _textField(
                  controller: controller.nickNameController,
                  hintText: 'Nick name',
                  enabled: false, // Always disabled
                ),

                SizedBox(height: ResponsiveHelper.spacing(20)),

                _label('License Number'),
                _textField(
                  controller: controller.licenseController,
                  hintText: 'License number',
                  enabled: false, // Always disabled
                ),

                if (controller.isLoading)
                  Padding(
                    padding: EdgeInsets.only(top: ResponsiveHelper.spacing(20)),
                    child: const CircularProgressIndicator(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _label(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: TextStyle(
        fontSize: ResponsiveHelper.fontSize(14),
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    bool enabled = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: ResponsiveHelper.spacing(8)),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
          filled: true,
          fillColor: enabled ? AppColors.errorColor : AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.borderRadius(12),
            ),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}