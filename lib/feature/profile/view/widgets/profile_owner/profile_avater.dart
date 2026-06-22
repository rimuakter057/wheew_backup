import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

/// Profile avatar — tap করলে full screen দেখায়, edit mode এ camera icon দেখায়
class ProfileAvatarWidget extends StatelessWidget {
  final ProfileController controller;

  const ProfileAvatarWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(() {
        final avatar = controller.userProfile.value?.avatar;

        return GestureDetector(
          // Avatar tap করলে full screen এ দেখাও
          onTap: () {
            final image =
                controller.tempCroppedImage.value?.path ?? avatar;
            if (image != null && image.isNotEmpty) {
              context.pushNamed(RouteName.showProfile, extra: image);
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ─── Avatar Image ───────────────────────────────────
              SizedBox(
                width: ResponsiveHelper.iconSize(90),
                height: ResponsiveHelper.iconSize(90),
                child: ClipOval(
                  child: _buildAvatarImage(avatar),
                ),
              ),

              // ─── Camera icon — শুধু edit mode এ ───────────────
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
          ),
        );
      }),
    );
  }

  Widget _buildAvatarImage(String? avatar) {
    final size = ResponsiveHelper.iconSize(90);

    // নতুন crop করা image থাকলে সেটা দেখাও
    if (controller.tempCroppedImage.value != null) {
      return Image.file(
        controller.tempCroppedImage.value!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    // Server থেকে avatar থাকলে network image
    if (avatar != null && avatar.isNotEmpty) {
      return Image.network(
        avatar,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(size),
      );
    }

    // কোনো image নেই — placeholder
    return _placeholder(size);
  }

  Widget _placeholder(double size) {
    return Container(
      width: size,
      height: size,
      color: AppColors.greyShade,
      child: Icon(
        Icons.person,
        size: size / 2,
        color: AppColors.blue,
      ),
    );
  }
}