import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../share/widgets/avatar/user_avatar.dart';
import '../../../utils/color/app_colors.dart';
import '../repository/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  // Single controller instance
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'profile'.tr,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: ResponsiveHelper.fontSize(18),
          ),
        ),
        actions: [
          GetBuilder<ProfileController>(
            builder: (controller) {
              return TextButton(
                onPressed: () {
                  controller.isEditing
                      ? controller.updateProfile()
                      : controller.toggleEdit();
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
        builder: (controller) {
          if (controller.isLoading && controller.userProfile.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
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
                              backgroundImage: FileImage(
                                controller.profileImage.value!,
                              ),
                            )
                          : UserAvatar(
                              imagePath: controller.userProfile.value?.avatar,
                              radius: ResponsiveHelper.width(45),
                            ),
                      if (controller.isEditing)
                        GestureDetector(
                          onTap: controller.pickImageFromGallery,
                          child: Container(
                            padding: EdgeInsets.all(
                              ResponsiveHelper.padding(6),
                            ),
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
                SizedBox(height: ResponsiveHelper.spacing(4)),
                _textField(
                  controller: controller.nickNameController,
                  hintText: 'Nick name',
                  enabled: false,
                ),

                SizedBox(height: ResponsiveHelper.spacing(20)),

                _label('License Number'),
                SizedBox(height: ResponsiveHelper.spacing(4)),
                _textField(
                  controller: controller.licenseController,
                  hintText: 'License number',
                  enabled: false,
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
      style: GoogleFonts.poppins(
        fontSize: ResponsiveHelper.fontSize(16),
        fontWeight: FontWeight.w400,
        color: AppColors.textBlack,
      ),
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    bool enabled = true,
  }) {
    return TextField(
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
          borderSide: BorderSide(color: AppColors.greyShade), // fallback
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(12),
          ),
          borderSide: BorderSide(color: AppColors.greyShade), // idle border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(12),
          ),
          borderSide: BorderSide(
            color: AppColors.greyShade,
            width: 1,
          ), // focused border
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(12),
          ),
          borderSide: BorderSide(color: AppColors.greyShade), // disabled border
        ),
      ),
    );
  }
}
