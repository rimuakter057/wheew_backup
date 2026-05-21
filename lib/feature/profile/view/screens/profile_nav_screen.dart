import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart'; // GoRouter ইম্পোর্ট করুন
import 'package:platchatapp/core/router/routes_name.dart'; // RouteName ইম্পোর্ট করুন
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/privacy_policy/help_suppoor_screen.dart';
import 'package:platchatapp/feature/privacy_policy/privacy_policy_screen.dart';
import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
import 'package:platchatapp/feature/profile/view/widgets/share_link_dialog.dart';
import 'package:platchatapp/feature/scan/controller/scan_controller.dart';
import 'package:platchatapp/feature/scan/presentation/widget/my_qr_view.dart';
import 'package:platchatapp/feature/terms_condition/web_view_screen.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:platchatapp/helper/fromate_rating/formate_rating.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/language/language_controller.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';

class ProfileNavScreen extends StatelessWidget {
  ProfileNavScreen({super.key});

  final LanguageController languageController = Get.find<LanguageController>();
  final ProfileController profileController = Get.put(
    ProfileController(),
    permanent: false,
  );


// rating display করার সময়

  @override
  Widget build(BuildContext context) {
    // ✅ Screen খুলতেই fresh data load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.reloadProfile();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'profile'.tr,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: ResponsiveHelper.titleFontSize(18),
          ),
        ),
      ),
      body: GetBuilder<ProfileController>(
        builder: (controller) {
          return SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveHelper.maxContentWidth,
                ),
                padding: ResponsiveHelper.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildProfileCard(context, controller),
                    SizedBox(height: ResponsiveHelper.spacing(20)),
                    _buildMenuItems(context),
                    SizedBox(height: ResponsiveHelper.spacing(30)),
                    _buildLogoutButton(context),
                    SizedBox(height: ResponsiveHelper.spacing(30)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }






  Widget _buildProfileCard(BuildContext context, ProfileController controller) {
    final user = controller.userProfile.value;
    final avatarUrl = user?.avatar;

    debugPrint("rating===========================${user?.rating?.toString()}");

    return Container(
      width: double.infinity,
      // Background design achieve korar jonno amra ClipRRect and Stack use korbo
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
        child: Stack(
          children: [
            // ─── 🔵 BACKGROUND DESIGN (THE SOFT CIRCLE) ───
            Positioned(
              right: -ResponsiveHelper.width(90),
            //  top: -ResponsiveHelper.width(40),
              bottom:ResponsiveHelper.height(50),
              child: Container(
                width: ResponsiveHelper.width(280),
                height: ResponsiveHelper.width(280),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08), // Soft circular overlay
                ),
              ),
            ),

            // ─── CARD CONTENT ───
            Padding(
              padding: ResponsiveHelper.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Avatar Section with Loading Overlay
                      GestureDetector(
                        onTap: () {
                          if (avatarUrl != null && avatarUrl.isNotEmpty) {
                            context.pushNamed(RouteName.showProfile, extra: avatarUrl);
                          }
                        },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: ResponsiveHelper.width(40),
                                backgroundColor: Colors.white.withOpacity(0.15),
                                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                                    ? NetworkImage(avatarUrl)
                                    : null,
                                child: (avatarUrl == null || avatarUrl.isEmpty)
                                    ? Icon(
                                  Icons.person,
                                  size: ResponsiveHelper.iconSize(36),
                                  color: Colors.white,
                                )
                                    : null,
                              ),
                            ),
                            if (controller.isLoading)
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black38,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // ✅ SCANNER DESIGN (MATCHED WITH YOUR IMAGE)
                      InkWell(


                        onTap: () {
                          final scanController = Get.find<ScanController>();
                          scanController.getQrCode();

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (ctx) {
                              final user = controller.userProfile.value;
                              return Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                ),
                                padding: EdgeInsets.fromLTRB(
                                  ResponsiveHelper.padding(24),
                                  ResponsiveHelper.padding(12),
                                  ResponsiveHelper.padding(24),
                                  ResponsiveHelper.padding(36),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                    // ── Drag Handle ──
                                    Container(
                                      width: ResponsiveHelper.width(40),
                                      height: ResponsiveHelper.height(4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(10)),
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveHelper.spacing(16)),

                                    // ── Title + Close Button ──
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'My QR Code',
                                          style: TextStyle(
                                            fontSize: ResponsiveHelper.fontSize(18),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => Navigator.pop(ctx),
                                          child: Container(
                                            width: ResponsiveHelper.width(32),
                                            height: ResponsiveHelper.width(32),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              size: ResponsiveHelper.iconSize(18),
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: ResponsiveHelper.spacing(24)),

                                    // ── Avatar ──
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                          width: ResponsiveHelper.width(3),
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: ResponsiveHelper.width(42),
                                        backgroundColor: Colors.grey.shade200,
                                        backgroundImage: (user?.avatar != null && user!.avatar!.isNotEmpty)
                                            ? NetworkImage(user.avatar!)
                                            : null,
                                        child: (user?.avatar == null || user!.avatar!.isEmpty)
                                            ? Icon(
                                          Icons.person,
                                          size: ResponsiveHelper.iconSize(38),
                                          color: Colors.grey,
                                        )
                                            : null,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveHelper.spacing(12)),

                                    // ── Name ──
                                    Text(
                                      user?.nickName.isNotEmpty == true ? user!.nickName : '---',
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.fontSize(20),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: ResponsiveHelper.spacing(6)),

                                    // ── Rating + Location ──
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.star_rounded,
                                          color: const Color(0xFFFFC107),
                                          size: ResponsiveHelper.iconSize(16),
                                        ),
                                        SizedBox(width: ResponsiveHelper.spacing(3)),
                                        Text(
                                          user != null ? formatRating(user.rating) : '0.0',
                                          style: TextStyle(
                                            fontSize: ResponsiveHelper.fontSize(14),
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(width: ResponsiveHelper.spacing(12)),

                                      ],
                                    ),
                                    SizedBox(height: ResponsiveHelper.spacing(28)),

                                    // ── QR Code Box ──
                                    Obx(() {
                                      if (scanController.isLoadingQr.value) {
                                        return Container(
                                          width: ResponsiveHelper.width(200),
                                          height: ResponsiveHelper.width(200),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
                                          ),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              color: Color(0xFF3D72E8),
                                              strokeWidth: 2.5,
                                            ),
                                          ),
                                        );
                                      }

                                      if (scanController.qrBase64.value.isNotEmpty) {
                                        final base64Str = scanController.qrBase64.value.replaceFirst(
                                          'data:image/png;base64,',
                                          '',
                                        );
                                        return Container(
                                          width: ResponsiveHelper.width(200),
                                          height: ResponsiveHelper.width(200),
                                          padding: EdgeInsets.all(ResponsiveHelper.padding(16)),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.08),
                                                blurRadius: ResponsiveHelper.width(20),
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Image.memory(
                                            base64Decode(base64Str),
                                            fit: BoxFit.contain,
                                          ),
                                        );
                                      }

                                      // ── Error / Retry ──
                                      return GestureDetector(
                                        onTap: () => scanController.getQrCode(),
                                        child: Container(
                                          width: ResponsiveHelper.width(200),
                                          height: ResponsiveHelper.width(200),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.refresh_rounded,
                                                color: Colors.grey.shade400,
                                                size: ResponsiveHelper.iconSize(40),
                                              ),
                                              SizedBox(height: ResponsiveHelper.spacing(8)),
                                              Text(
                                                'Tap to retry',
                                                style: TextStyle(
                                                  fontSize: ResponsiveHelper.fontSize(13),
                                                  color: Colors.grey.shade400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),

                                    SizedBox(height: ResponsiveHelper.spacing(20)),

                                    // ── Bottom Text ──
                                    Text(
                                      'Let other drivers scan this to chat with you.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.fontSize(13),
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },











                        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(18)),
                        child: Container(
                          width: ResponsiveHelper.width(54),
                          height: ResponsiveHelper.width(54),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            // Image dynamic background color (Match color tone)
                            color: const Color(0xFFFFFFFFF).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(18)),
                          ),
                          child: CustomImage(
                            imageSrc: AssetsPath.scanIcon,
                            width: ResponsiveHelper.width(26),
                            height: ResponsiveHelper.width(26),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(15)),

                  // ✅ Nick name from controller
                  Text(
                    user?.nickName.isNotEmpty == true ? user!.nickName : '---',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.titleFontSize(24),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(6)),

                  // ✅ Rating from controller
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.white,
                        size: ResponsiveHelper.iconSize(18),
                      ),
                      SizedBox(width: ResponsiveHelper.spacing(4)),
                      Text(
                        user != null ? formatRating(user.rating) : '0.0',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveHelper.fontSize(16),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }




  Widget _buildMenuItems(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'icon': Icons.person_outline,
        'title': 'profile'.tr,
        'onTap': () {
          context.pushNamed(RouteName.profile);
        },
      },
      {
        'icon': Icons.local_phone_outlined,
        'title': 'useful_number'.tr,
        'onTap': () {
          context.pushNamed(RouteName.usefulMemberScreen);
        },
      },
      {
        'icon': Icons.description_outlined,
        'title': 'terms_and_conditions'.tr,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WebViewScreen(url: ApiUrl.terms)),
          );
        },
      },
      {
        'icon': Icons.verified_user_outlined,
        'title': 'privacy_policy'.tr,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrivacyPolicyScreen(url: ApiUrl.privacy),
            ),
          );
        },
      },
      {
        'icon': Icons.help_outline,
        'title': 'help_support'.tr,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HelpSupportScreen()),
          );
        },
      },

      {
        'icon': Icons.share_outlined,
        'title': 'share_link'.tr,
        'onTap': () {
          showDialog(
            context: context,
            builder: (_) => ShareLinkDialog(
              shareUrl: 'https://yourapp.com/invite/abc123',
              shareMessage: 'try_amazing_app'.tr,
            ),
          );
        },
      },

      {
        'icon': Icons.remove_circle_outline,
        'title': 'blocked_user5'.tr,
        'onTap': () {
          context.pushNamed(RouteName.block);
        },
      },
      {
        'icon': Icons.delete_outline,
        'title': 'delete'.tr,
        'onTap': () {
          context.pushNamed(RouteName.delete);
        },
      },
    ];

    return Column(
      children: [
        ...items.map(
          (item) => Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  item['icon'],
                  size: ResponsiveHelper.iconSize(24),
                  color: Colors.black54,
                ),
                title: Text(
                  item['title'],
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(16),
                    color: Colors.black87,
                  ),
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: item['onTap'],
              ),
              const Divider(height: 1),
            ],
          ),
        ),
        _buildLanguageDropdown(context),
      ],
    );
  }

  Widget _buildLanguageDropdown(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            Icons.translate,
            size: ResponsiveHelper.iconSize(24),
            color: Colors.black54,
          ),
          title: Text(
            'language'.tr,
            style: context.titleSmall.copyWith(
              fontSize: ResponsiveHelper.fontSize(16),
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Obx(
            () => Text(
              languageController.currentLanguageDisplay,
              style: TextStyle(fontSize: ResponsiveHelper.fontSize(12)),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            size: ResponsiveHelper.iconSize(20),
          ),
          onTap: () => _showLanguageBottomSheet(context),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveHelper.buttonHeight(55),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFEBEE),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.borderRadius(30),
            ),
          ),
        ),
        onPressed: () {
          // লগআউট করার পর ওয়েলকাম স্ক্রিনে নিয়ে যাওয়া
          context.goNamed(RouteName.welcome);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: Colors.redAccent,
              size: ResponsiveHelper.iconSize(20),
            ),
            SizedBox(width: ResponsiveHelper.spacing(10)),
            Text(
              'log_out'.tr,
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: ResponsiveHelper.fontSize(16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final controller = Get.find<LanguageController>();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveHelper.borderRadius(20)),
        ),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.spacing(16)),
          child: Obx(() {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: ResponsiveHelper.spacing(8)),
                Text(
                  'language'.tr,
                  style: context.titleSmall.copyWith(
                    fontSize: ResponsiveHelper.fontSize(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.spacing(12)),

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
}
