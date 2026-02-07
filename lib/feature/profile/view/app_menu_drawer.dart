import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../auth/repository/auth_controller.dart';
import '../repository/profile_controller.dart';
import '../../../core/router/routes_name.dart';
import '../../../share/widgets/avatar/user_avatar.dart';

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    final AuthController authController = Get.find<AuthController>();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Obx(() {
                final user = profileController.userProfile.value;

                // Debug prints
                print('User profile: ${user?.nickName}');
                print('Avatar: ${user?.avatar}');

                return Row(
                  children: [
                    // Avatar
                    profileController.profileImage.value != null
                        ? CircleAvatar(
                      radius: 28,
                      backgroundImage: FileImage(
                        profileController.profileImage.value!,
                      ),
                    )
                        : UserAvatar(
                      imagePath: user?.avatar,
                      radius: 28,
                    ),
                    const SizedBox(width: 12),
                    // Nickname
                    Expanded(
                      child: Text(
                        user?.nickName ?? 'Loading...',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              }),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(RouteName.profile);
              },
            ),
            const SizedBox(height: 8),

            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text('terms_and_condition'.tr),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(RouteName.terms);
              },
            ),

            const Spacer(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await authController.logout();
                if (!context.mounted) return;
                context.goNamed(RouteName.welcome);
              },
            ),
          ],
        ),
      ),
    );
  }
}