/*
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            /// Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage:
                    AssetImage(AssetsPath.person3),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Hasan',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                     */
/* SizedBox(height: 4),
                      Text(
                        'View Profile',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),*//*

                    ],
                  ),
                ],
              ),
            ),

            const Divider(),

            /// Menu Items
            _drawerItem(
              icon: Icons.person_outline,
              title: 'Profile',
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(RouteName.profile);
              },
            ),

            _drawerItem(
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(RouteName.terms);
              },
            ),

            const Spacer(),

            /// Logout
            _drawerItem(
              icon: Icons.logout,
              title: 'Log Out',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                // logout logic
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    Color color = Colors.black,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      onTap: onTap,
    );
  }
}
*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../share/controller/profile_controller.dart';
import '../../../core/router/routes_name.dart';
import '../../../utils/assets_path/assets_path.dart';

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

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

            const Spacer(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Terms & Condition'),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(RouteName.terms);
              },
            ),
          ],
        ),
      ),
    );
  }
}
