import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/terms_condition/web_view_screen.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../language/language_controller.dart';
import '../../auth/repository/auth_controller.dart';
import '../repository/profile_controller.dart';
import '../../../core/router/routes_name.dart';
import '../../../share/widgets/avatar/user_avatar.dart';

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    final authController = Get.find<AuthController>();
    final languageController = Get.find<LanguageController>();

    return Drawer(
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Column(
          children: [
            /// ===== USER HEADER =====
            Padding(
              padding: EdgeInsets.all(ResponsiveHelper.padding(20)),
              child: Obx(() {
                final user = profileController.userProfile.value;

                return Row(
                  children: [
                    profileController.profileImage.value != null
                        ? CircleAvatar(
                            radius: ResponsiveHelper.width(28),
                            backgroundImage: FileImage(
                              profileController.profileImage.value!,
                            ),
                          )
                        : UserAvatar(
                            imagePath: user?.avatar,
                            radius: ResponsiveHelper.width(28),
                          ),
                    SizedBox(width: ResponsiveHelper.spacing(12)),
                    Expanded(
                      child: Text(
                        user?.nickName ?? 'Loading...',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveHelper.fontSize(16),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              }),
            ),

            const Divider(),

            /// ===== MENU ITEMS =====
            _drawerItem(
              context,
              icon: Icons.person_outline,
              title: 'profile'.tr,
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(RouteName.profile);
              },
            ),

            _drawerItem(
              context,
              icon: Icons.description_outlined,
              title: 'terms_and_conditions'.tr,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WebViewScreen(url: ApiUrl.terms),
                  ),
                );
              },
            ),

            _drawerItem(
              context,
              icon: Icons.block,
              title: 'block_'.tr,
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(RouteName.block);
              },
            ),

            /// ===== LANGUAGE =====
            ListTile(
              leading: Icon(
                Icons.translate,
                size: ResponsiveHelper.iconSize(24),
              ),
              title: Text(
                'language'.tr,
                style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
              ),
              subtitle: Obx(
                () => Text(
                  languageController.currentLanguageDisplay,
                  style: TextStyle(fontSize: ResponsiveHelper.fontSize(12)),
                ),
              ),
              onTap: () => _showLanguageBottomSheet(context),
            ),

            const Spacer(),

            /// ===== LOGOUT =====
            ListTile(
              leading: Icon(
                Icons.logout,
                color: AppColors.errorColor,
                size: ResponsiveHelper.iconSize(24),
              ),
              title: Text(
                'logout'.tr,
                style: TextStyle(
                  color: AppColors.errorColor,
                  fontSize: ResponsiveHelper.fontSize(16),
                ),
              ),
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

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveHelper.spacing(8)),
      child: ListTile(
        leading: Icon(icon, size: ResponsiveHelper.iconSize(24)),
        title: Text(
          title,
          style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
        ),
        onTap: onTap,
      ),
    );
  }
}

void _showLanguageBottomSheet(BuildContext context) {
  final controller = Get.find<LanguageController>();

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Text(
                'language'.tr,
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontSize(18),
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              ...controller.availableLanguageNames.map((language) {
                final isSelected = controller.isLanguageSelected(language);

                return ListTile(
                  title: Text(language),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () async {
                    await controller.saveLanguage(language);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                );
              }),
            ],
          );
        }),
      );
    },
  );
}

/*
class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    final AuthController authController = Get.find<AuthController>();

    return Drawer(
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(ResponsiveHelper.padding(20)),
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
                            radius: ResponsiveHelper.width(28),
                            backgroundImage: FileImage(
                              profileController.profileImage.value!,
                            ),
                          )
                        : UserAvatar(
                            imagePath: user?.avatar,
                            radius: ResponsiveHelper.width(28),
                          ),
                    SizedBox(width: ResponsiveHelper.spacing(12)),
                    // Nickname
                    Expanded(
                      child: Text(
                        user?.nickName ?? 'Loading...',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveHelper.fontSize(16),
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
              leading: Icon(
                Icons.person_outline,
                size: ResponsiveHelper.iconSize(24),
              ),
              title: Text(
                'profile'.tr,
                style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
              ),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(RouteName.profile);
              },
            ),
            SizedBox(height: ResponsiveHelper.spacing(8)),

            ListTile(
              leading: Icon(
                Icons.description_outlined,
                size: ResponsiveHelper.iconSize(24),
              ),
              title: Text(
                'terms_and_conditions'.tr,
                style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
              ),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(RouteName.terms);
              },
            ),
            SizedBox(height: ResponsiveHelper.spacing(8)),
            ListTile(
              leading: Icon(Icons.block, size: ResponsiveHelper.iconSize(24)),
              title: Text(
                'block_'.tr,
                style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
              ),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(RouteName.block);
              },
            ),
            SizedBox(height: ResponsiveHelper.spacing(8)),
            ListTile(
              leading: Icon(
                Icons.translate,
                size: ResponsiveHelper.iconSize(24),
              ),
              title: Text(
                'language'.tr,
                style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
              ),
              subtitle: Obx(() {
                final langController = Get.find<LanguageController>();
                return Text(
                  langController.currentLanguageDisplay,
                  style: TextStyle(fontSize: ResponsiveHelper.fontSize(12)),
                );
              }),
              onTap: () {
                _showLanguageBottomSheet(context);
              },
            ),

            const Spacer(),

            ListTile(
              leading: Icon(
                Icons.logout,
                color: AppColors.errorColor,
                size: ResponsiveHelper.iconSize(24),
              ),
              title: Text(
                'logout'.tr,
                style: TextStyle(
                  color: AppColors.errorColor,
                  fontSize: ResponsiveHelper.fontSize(16),
                ),
              ),
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

void _showLanguageBottomSheet(BuildContext context) {
  final LanguageController controller = Get.find<LanguageController>();

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Obx(() {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: controller.availableLanguageNames.map((language) {
            final isSelected = controller.isLanguageSelected(language);

            return ListTile(
              leading: Icon(
                Icons.check,
                color: isSelected ? Colors.blue : Colors.transparent,
              ),
              title: Text(language),
              onTap: () {
                controller.saveLanguage(language);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      });
    },
  );
}
*/
