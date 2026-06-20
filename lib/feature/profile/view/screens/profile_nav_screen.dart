import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart'; // GoRouter ইম্পোর্ট করুন
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/router/routes.dart';
import 'package:platchatapp/core/router/routes_name.dart'; // RouteName ইম্পোর্ট করুন
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/core/service/storage_service.dart';
import 'package:platchatapp/feature/auth/repository/auth_controller.dart';
import 'package:platchatapp/feature/privacy_policy/help_suppoor_screen.dart';
import 'package:platchatapp/feature/privacy_policy/privacy_policy_screen.dart';
import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
import 'package:platchatapp/feature/profile/view/widgets/share_link_dialog.dart';
import 'package:platchatapp/feature/scan/controller/scan_controller.dart';
import 'package:platchatapp/feature/scan/presentation/widget/my_qr_view.dart';
import 'package:platchatapp/feature/terms_condition/web_view_screen.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:platchatapp/helper/fromate_rating/formate_rating.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/language/language_controller.dart';
import 'package:platchatapp/share/widgets/avatar/user_avatar.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';

class ProfileNavScreen extends StatelessWidget {
  ProfileNavScreen({super.key});

  final LanguageController languageController = Get.find<LanguageController>();
  final ScanController scanController = Get.put(ScanController());
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
                                backgroundImage: NetworkImage(
                                  (avatarUrl != null && avatarUrl.isNotEmpty) ? avatarUrl : AppConst.unknown,
                                ),
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




                      FutureBuilder<bool?>(
                        future: SharePrefsHelper.getBool(AppConst.licenseNoVerified),
                        builder: (context, snapshot) {
                          final bool isVerified = snapshot.data ?? false;

                          // ✅ Verified State — Clean & Premium Label
                          if (isVerified) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                              CustomImage(imageSrc: "assets/icons/verified.svg"),
                                SizedBox(height: ResponsiveHelper.height(6)),
                                Text(
                                  'verified'.tr,
                                  style: context.bodyMedium.copyWith(color: AppColors.white)
                                ),
                              ],
                            );
                          }

                          return InkWell(
                            onTap: () {
                              // QR না থাকলে আগে fetch করে নিন
                              if (scanController.qrBase64.value.isEmpty) {
                                scanController.getQrCode();
                              }

                              showModalBottomSheet(
                                context: context,
                                backgroundColor:AppColors.white,// card-এর পেছনের কালো background
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(ResponsiveHelper.borderRadius(24)),
                                  ),
                                ),
                                builder: (context) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                     // top: ResponsiveHelper.padding(24),
                                      bottom: MediaQuery.of(context).viewInsets.bottom + ResponsiveHelper.padding(24),
                                      left: ResponsiveHelper.padding(16),
                                      right: ResponsiveHelper.padding(16),
                                    ),
                                    // child: MyQrView(
                                    //   scanController: scanController,
                                    //   avatarUrl: profileController.userProfile.value?.avatar,
                                    //   name: profileController.userProfile.value?.nickName,
                                    //   rating: profileController.userProfile.value?.rating,
                                    //
                                    // ),


                                    child: Container(
                                      width: double.infinity,
                                      padding: ResponsiveHelper.all(20),
                                      constraints: BoxConstraints(
                                        minHeight: ResponsiveHelper.height(650),
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(24)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 24,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          // ── Avatar ─────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(onPressed: (){
                            context.pop();

                          }, icon: Icon(Icons.close,color: AppColors.black,))
                        ],
                        
                      ),
                                          Text("My QR Code",style: context.bodyMedium.copyWith(color: AppColors.black),),
                                          SizedBox(height: ResponsiveHelper.spacing(32)),
                                          UserAvatar(imagePath: profileController.userProfile.value?.avatar??AppConst.unknown),

                                          SizedBox(height: ResponsiveHelper.spacing(12)),

                                          // ── Name ───────────────────────────────────
                                          Text(
                                              profileController.userProfile.value?.nickName??"unknown",
                                            style: GoogleFonts.poppins(
                                              fontSize: ResponsiveHelper.fontSize(18),
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),

                                          SizedBox(height: ResponsiveHelper.spacing(6)),

                                          // ── Rating + Location ─────────────────────
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.star, color: Colors.amber, size: ResponsiveHelper.iconSize(16)),
                                              SizedBox(width: ResponsiveHelper.spacing(4)),
                                              Text(
                                                ((profileController.userProfile.value?.rating as num?)?.toDouble() ?? 0.0).toStringAsFixed(1),
                                                style: GoogleFonts.poppins(
                                                  fontSize: ResponsiveHelper.fontSize(13),
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              SizedBox(width: ResponsiveHelper.spacing(10)),


                                            ],
                                          ),

                                          SizedBox(height: ResponsiveHelper.spacing(24)),

                                          // ── QR Box ─────────────────────────────────
                                          Obx(() {
                                            if (scanController.isLoadingQr.value) {
                                              return Container(
                                                width: ResponsiveHelper.width(200),
                                                height: ResponsiveHelper.width(200),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF5F5F5),
                                                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
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


                                              return SizedBox(
                                                width: ResponsiveHelper.width(200),
                                                height: ResponsiveHelper.width(200),
                                                child: Card(
                                                  elevation: 10,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
                                                  ),
                                                  color: AppColors.black,
                                                  clipBehavior: Clip.antiAlias, // ⬅️ এটা দিলে ভেতরের Image-ও radius অনুযায়ী কাটা যাবে
                                                  child: Image.memory(base64Decode(base64Str), fit: BoxFit.contain),
                                                ),
                                              );
                                            }

                                            return GestureDetector(
                                              onTap: () => scanController.getQrCode(),
                                              child: Container(
                                                width: ResponsiveHelper.width(200),
                                                height: ResponsiveHelper.width(200),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF5F5F5),
                                                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.refresh_rounded,
                                                      color: Colors.grey.shade400,
                                                      size: 36,
                                                    ),
                                                    SizedBox(height: ResponsiveHelper.spacing(8)),
                                                    Text(
                                                      'Tap to retry',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: ResponsiveHelper.fontSize(13),
                                                        color: Colors.grey.shade400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),

                                          SizedBox(height: ResponsiveHelper.spacing(24)),

                                          // ── Caption ────────────────────────────────
                                          Text(
                                            'let_others_scan'.tr,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              fontSize: ResponsiveHelper.fontSize(13),
                                              color: Colors.grey.shade500,
                                            ),
                                          ),


                                          SizedBox(height: ResponsiveHelper.spacing(12)),
                                        ],
                                      ),
                                    ),

                                  );
                                },
                              );
                            },
                            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: ResponsiveHelper.width(54),
                                  height: ResponsiveHelper.width(54),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF).withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: CustomImage(
                                    imageSrc: AssetsPath.scanIcon,
                                    width: ResponsiveHelper.width(24),
                                    height: ResponsiveHelper.width(24),
                                  ),
                                ),
                              ],
                            ),
                          );


                          // return InkWell(
                          //   onTap: () {
                          //     showModalBottomSheet(
                          //       context: context,
                          //       backgroundColor: const Color(0xFF1E1E1E), // MyQrView এর dark theme এর সাথে match
                          //       isScrollControlled: true,
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.vertical(
                          //           top: Radius.circular(ResponsiveHelper.borderRadius(24)),
                          //         ),
                          //       ),
                          //       builder: (context) {
                          //         return Padding(
                          //           padding: EdgeInsets.only(
                          //             top: ResponsiveHelper.padding(24),
                          //             bottom: MediaQuery.of(context).viewInsets.bottom +
                          //                 ResponsiveHelper.padding(24),
                          //             left: ResponsiveHelper.padding(16),
                          //             right: ResponsiveHelper.padding(16),
                          //           ),
                          //           child: MyQrView(scanController: scanController),
                          //         );
                          //       },
                          //     );
                          //   },
                          //   borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
                          //   child: Column(
                          //     mainAxisSize: MainAxisSize.min,
                          //     children: [
                          //       Container(
                          //         width: ResponsiveHelper.width(54),
                          //         height: ResponsiveHelper.width(54),
                          //         alignment: Alignment.center,
                          //         decoration: BoxDecoration(
                          //           color:  const Color(0xFFFFFFFF).withOpacity(0.4),
                          //           borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
                          //
                          //           boxShadow: [
                          //             BoxShadow(
                          //               color: Colors.black.withOpacity(0.05),
                          //               blurRadius: 10,
                          //               offset: const Offset(0, 4),
                          //             ),
                          //           ],
                          //         ),
                          //         child: CustomImage(
                          //           imageSrc: AssetsPath.scanIcon,
                          //           width: ResponsiveHelper.width(24),
                          //           height: ResponsiveHelper.width(24),
                          //           // color: AppColors.white, // আপনার প্রোজেক্ট অনুযায়ী কালার ফিল্টার দিতে পারেন
                          //         ),
                          //       ),
                          //
                          //     ],
                          //   ),
                          // );
                        },
                      )


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
        'icon': AssetsPath.profile,
        'title': 'profile'.tr,
        'onTap': () {
          context.pushNamed(RouteName.profile);
        },
      },
      {
        'icon': AssetsPath.usefulNumber,
        'title': 'useful_number'.tr,
        'onTap': () {
          context.pushNamed(RouteName.usefulMemberScreen);
        },
      },
      {
        'icon': AssetsPath.terms,
        'title': 'terms_and_conditions'.tr,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WebViewScreen(url: ApiUrl.terms)),
          );
        },
      },
      {
        'icon': AssetsPath.privacy,
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
        'icon': AssetsPath.help,
        'title': 'help_support'.tr,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HelpSupportScreen()),
          );
        },
      },

      {
        'icon': AssetsPath.share,
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
        'icon': AssetsPath.blocked,
        'title': 'blocked_user5'.tr,
        'onTap': () {
          context.pushNamed(RouteName.block);
        },
      },
      {
        'icon': AssetsPath.remove,
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
                leading: SvgPicture.asset(
                  item['icon'],
                  width: ResponsiveHelper.iconSize(24),
                  height: ResponsiveHelper.iconSize(24),
                  colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcIn),
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
        onPressed: () async{
    await SharePrefsHelper.remove(AppConst.token);
    await SharePrefsHelper.remove(AppConst.userID);
    await SharePrefsHelper.remove(AppConst.userData);
    await SharePrefsHelper.remove(AppConst.licenceId);
    await SharePrefsHelper.remove(AppConst.nickName);
    await SharePrefsHelper.remove(AppConst.avatar);
    await SharePrefsHelper.remove(AppConst.loginUser);
    await SharePrefsHelper.remove(AppConst.loginPass);
    await SharePrefsHelper.remove(AppConst.licenseNoVerified);
    await SharePrefsHelper.setBool(AppConst.isLoggedIn, false);

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
