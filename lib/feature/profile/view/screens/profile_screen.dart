import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/profile/view/widgets/custom_upload_card.dart';
import 'package:platchatapp/feature/profile/view/widgets/upload_widget.dart';
import '../../../../helper/responsive_helper/responsive_helper.dart';
import '../../../../utils/color/app_colors.dart';
import '../../repository/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProfileController());
    // ✅ Reload every time screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.reloadProfile();
    });
  }

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ResponsiveHelper.spacing(24)),

                /// Profile Image
                Center(
                  child: Obx(() {
                    final avatar = controller.userProfile.value?.avatar;
                    return GestureDetector(
                      onTap: () {
                        final image = controller.profileImage.value?.path ??
                            controller.userProfile.value?.avatar;

                        if (image != null && image.isNotEmpty) {
                          context.pushNamed(
                            RouteName.showProfile,
                            extra: image,
                          );
                        }
                      },

                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          controller.profileImage.value != null
                              ? CircleAvatar(
                                  radius: ResponsiveHelper.width(45),
                                  backgroundImage: FileImage(
                                    controller.profileImage.value!,
                                  ),
                                )
                              : avatar != null && avatar.isNotEmpty
                              ? CircleAvatar(
                                  radius: ResponsiveHelper.width(45),
                                  backgroundImage: NetworkImage(avatar),
                                  onBackgroundImageError: (_, __) {},
                                )
                              : CircleAvatar(
                                  radius: ResponsiveHelper.width(45),
                                  backgroundColor: AppColors.greyShade,
                                  child: Icon(
                                    Icons.person,
                                    size: ResponsiveHelper.width(45),
                                    color: AppColors.blueClient,
                                  ),
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
                      ),
                    );
                  }),
                ),

                SizedBox(height: ResponsiveHelper.spacing(32)),

                _label('nick_name'.tr),
                SizedBox(height: ResponsiveHelper.spacing(4)),
                _textField(
                  controller: controller.nickNameController,
                  hintText: 'nick_name'.tr,
                  enabled: false,
                ),

                SizedBox(height: ResponsiveHelper.spacing(20)),

                _label('license_number_title'.tr),
                SizedBox(height: ResponsiveHelper.spacing(4)),
                _textField(
                  controller: controller.licenseController,
                  hintText: 'license_number1'.tr,
                  enabled: false,
                ),

                SizedBox(height: ResponsiveHelper.spacing(8)),

                Text(
                  "Upload Documents",
                  textAlign: TextAlign.start,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveHelper.fontSize(16),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textBlack,
                  ),
                ),


                SizedBox(height: ResponsiveHelper.spacing(18)),

                CustomUploadCard(title: "Driver's license", subtitle: 'Tap to upload', onUpload: () {

                  showUploadDocumentSheet(context);

                },),
                SizedBox(height: ResponsiveHelper.spacing(12)),
                CustomUploadCard(title: "Car insurance", subtitle: 'Tap to upload', onUpload: () {  },),
                SizedBox(height: ResponsiveHelper.spacing(12)),
                CustomUploadCard(title: "Car tax", subtitle: 'Tap to upload', onUpload: () {  },),


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
          borderSide: BorderSide(color: AppColors.greyShade),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(12),
          ),
          borderSide: BorderSide(color: AppColors.greyShade),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(12),
          ),
          borderSide: BorderSide(color: AppColors.greyShade, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(12),
          ),
          borderSide: BorderSide(color: AppColors.greyShade),
        ),
      ),
    );
  }
}

