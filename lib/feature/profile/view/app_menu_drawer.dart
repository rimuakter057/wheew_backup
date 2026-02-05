import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../share/controller/auth_controller.dart';
import '../../../share/controller/profile_controller.dart';
import '../../../core/router/routes_name.dart';
import '../../../utils/assets_path/assets_path.dart';

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
              child: Row(
                children: [
                  Obx(() {
                    return CircleAvatar(
                      radius: 28,
                      backgroundImage:
                      profileController.profileImage.value != null
                          ? FileImage(
                          profileController.profileImage.value as File)
                          : const AssetImage(AssetsPath.person3)
                      as ImageProvider,
                    );
                  }),
                  const SizedBox(width: 12),
                  const Text(
                    'Hasan',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
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
            SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text('terms_and_condition'.tr),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(RouteName.terms);
              },
            ),

            const Spacer(),

            /*ListTile(
              leading: const Icon(Icons.logout),
              title: Text('log_out'.tr),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(RouteName.terms);
              },
            ),*/
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await authController.logout();
                if (context.mounted) {
                  context.goNamed(RouteName.signIn);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
