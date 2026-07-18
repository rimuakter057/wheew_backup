// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
// import 'package:platchatapp/feature/scan/controller/scan_controller.dart';
// import 'package:platchatapp/helper/common_container/common_container.dart';
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
// import 'package:platchatapp/language/language_controller.dart';
// import 'package:platchatapp/utils/color/app_colors.dart';
// import 'package:platchatapp/utils/extension/base_extension.dart';
// import '../../../../utils/language/app_string.dart';
// import '../widgets/profile_nav/profile_header.dart';
// import '../widgets/profile_nav/profile_logout_button.dart';
// import '../widgets/profile_nav/profile_menu_item_card.dart';
// import '../widgets/profile_nav/profile_nav_appbar.dart';
//
// class ProfileNavScreen extends StatefulWidget {
//   const ProfileNavScreen({super.key});
//
//   @override
//   State<ProfileNavScreen> createState() => _ProfileNavScreenState();
// }
//
// class _ProfileNavScreenState extends State<ProfileNavScreen> {
//   final LanguageController languageController = Get.find<LanguageController>();
//   final ScanController scanController = Get.put(ScanController());
//   late final ProfileController profileController;
//
//   @override
//   void initState() {
//     super.initState();
//     profileController = Get.put(ProfileController(), permanent: false);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!profileController.isEditing) {
//         profileController.reloadProfile();
//       }
//     });
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       appBar: ProfileNavAppBar(),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: AppColors.primaryBackgroundGradient,
//         ),
//         child: GetBuilder<ProfileController>(
//           builder: (controller) {
//             return SingleChildScrollView(
//               child: Center(
//                 child: Container(
//                   constraints: BoxConstraints(
//                     maxWidth: ResponsiveHelper.maxContentWidth,
//                   ),
//                   padding: ResponsiveHelper.symmetric(horizontal: 20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ///profile card====================
//                       ProfileHeaderCard(
//                         controller: controller,
//
//                         scanController: scanController,
//                       ),
//                       SizedBox(height: ResponsiveHelper.spacing(16)),
//
//                       Divider(color: AppColors.divider),
//                       SizedBox(height: ResponsiveHelper.spacing(12)),
//                       ///profile menu item==========================
//                       Text(
//                           AppStrings.accountAndSettings.tr,
//                         style: context.bodyLarge.copyWith(
//                           color: AppColors.black,
//                           fontWeight: FontWeight.w600
//                         ),
//                       ),
//                       SizedBox(height: ResponsiveHelper.spacing(12)),
//                       CommonContainer(
//                           bgColor: Color(0xFFD8E0EB),
//                           child: buildMenuItems(context: context,
//                               profileController: profileController,
//                               languageController: languageController)
//                       ),
//                       SizedBox(height: ResponsiveHelper.spacing(30)),
//                       ///build logout button==============
//                       buildLogoutButton(context: context),
//                       SizedBox(height: ResponsiveHelper.spacing(200)),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
// }




import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/router/routes.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/core/service/storage_service.dart';
import 'package:platchatapp/feature/auth/repository/auth_controller.dart';
import 'package:platchatapp/feature/faq/presentation/screens/faq_screen.dart';
import 'package:platchatapp/feature/privacy_policy/help_suppoor_screen.dart';
import 'package:platchatapp/feature/privacy_policy/privacy_policy_screen.dart';
import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
import 'package:platchatapp/feature/profile/view/widgets/share_link_dialog.dart';
import 'package:platchatapp/feature/scan/controller/qr_card_webview.dart';
import 'package:platchatapp/feature/scan/controller/scan_controller.dart';
import 'package:platchatapp/feature/scan/presentation/widget/download_qr_code.dart';
import 'package:platchatapp/feature/scan/presentation/widget/my_qr_view.dart';
import 'package:platchatapp/feature/terms_condition/web_view_screen.dart';
import 'package:platchatapp/helper/custom_image/custom_image.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
import 'package:platchatapp/helper/fromate_rating/formate_rating.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/language/language_controller.dart';
import 'package:platchatapp/share/widgets/avatar/user_avatar.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:platchatapp/utils/language/app_string.dart';

class ProfileNavScreen extends StatefulWidget {
  const ProfileNavScreen({super.key});

  @override
  State<ProfileNavScreen> createState() => _ProfileNavScreenState();
}

class _ProfileNavScreenState extends State<ProfileNavScreen> {
  final LanguageController languageController = Get.find<LanguageController>();
  final ScanController scanController = Get.put(ScanController());
  late final ProfileController profileController;

  @override
  void initState() {
    super.initState();
    profileController = Get.put(
      ProfileController(),
      permanent: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!profileController.isEditing) {
        profileController.reloadProfile();
      }
    });
  }

  /// ✅ vehicle color name → actual Color
  Color _getVehicleColor(String? colorName) {
    switch (colorName) {
      case 'Bianco':
        return const Color(0xFFF4F4F2);
      case 'Nero':
        return const Color(0xFF1B1B1D);
      case 'Grigio':
        return const Color(0xFF6E7074);
      case 'Blu':
        return const Color(0xFF2C3E5C);
      case 'Rosso':
        return const Color(0xFFB11724);
      case 'Bianco2':
        return Colors.white;
      default:
        return Colors.grey;
    }
  }

  /// ✅ backend vehicle_type string → icon asset path
  String _getVehicleTypeIcon(String? type) {
    switch (type) {
      case 'VAN':
        return AssetsPath.van;
      case 'SUV':
        return AssetsPath.suv;
      case 'TRUCK':
        return AssetsPath.truck;
      case 'CAMPER':
        return AssetsPath.camper;
      case 'SCOOTER':
        return AssetsPath.scooter;
      case 'MOTORCYCLE':
        return AssetsPath.motorcycle;
      case 'PICKUP':
        return AssetsPath.pickup;
      case 'MICRO_CAR':
        return AssetsPath.microCar;
      case 'CITY_CAR':
        return AssetsPath.cityCar;
      case 'E_SCOOTER':
        return AssetsPath.eScooter;
      default:
        return AssetsPath.camper;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppStrings.profile.tr,
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
                    ///profile card====================
                    _buildProfileCard(context, controller),
                    SizedBox(height: ResponsiveHelper.spacing(20)),
                    ///profile menu item==========================
                    _buildMenuItems(context),
                    SizedBox(height: ResponsiveHelper.spacing(30)),
                    ///build logout button==============
                    _buildLogoutButton(context),
                    SizedBox(height: ResponsiveHelper.spacing(180)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  ///profile card=====================================================================
//   Widget _buildProfileCard(BuildContext context, ProfileController controller) {
//     final user = controller.userProfile.value;
//     final avatarUrl = user?.avatar;
//     final isVerified = user?.isVehicleVerified;
//
//     debugPrint("rating===========================${user?.rating?.toString()}");
//
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
//         gradient: const LinearGradient(
//           colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
//         child: Stack(
//           children: [
//             ///  BACKGROUND DESIGN (THE SOFT CIRCLE) ───
//             Positioned(
//               right: -ResponsiveHelper.width(90),
//               bottom: ResponsiveHelper.height(50),
//               child: Container(
//                 width: ResponsiveHelper.width(280),
//                 height: ResponsiveHelper.width(280),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.white.withOpacity(0.08),
//                 ),
//               ),
//             ),
//
//             /// ─── CARD CONTENT ───=======================
//             Padding(
//               padding: ResponsiveHelper.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       /// Avatar Section with Loading Overlay
//                       GestureDetector(
//                         onTap: () {
//                           if (avatarUrl != null && avatarUrl.isNotEmpty) {
//                             context.pushNamed(RouteName.showProfile, extra: avatarUrl);
//                           }
//                         },
//                         child: Stack(
//                           children: [
//                             Container(
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: Colors.white24, width: 2),
//                               ),
//                               child: CircleAvatar(
//                                 radius: ResponsiveHelper.width(40),
//                                 backgroundColor: Colors.white.withOpacity(0.15),
//                                 backgroundImage: NetworkImage(
//                                   (avatarUrl != null && avatarUrl.isNotEmpty) ? avatarUrl : AppConst.unknown,
//                                 ),
//                               ),
//                             ),
//                             if (controller.isLoading)
//                               Positioned.fill(
//                                 child: Container(
//                                   decoration: const BoxDecoration(
//                                     color: Colors.black38,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Center(
//                                     child: SizedBox(
//                                       width: 20,
//                                       height: 20,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//
//                       ///=================scan================================
//                       FutureBuilder<bool?>(
//                         future: SharePrefsHelper.getBool(AppConst.licenseNoVerified),
//                         builder: (context, snapshot) {
//                           final bool isVerified = snapshot.data ?? false;
//
//                           return InkWell(
//                             onTap: () {
//                               if (scanController.qrCardHtml.value.isEmpty) {
//                                 scanController.getQrCode();
//                               }
//
//                               debugPrint("Current context: ${qrCardKey.currentContext}");
//
//                               showModalBottomSheet(
//                                 context: context,
//                                 backgroundColor: AppColors.white,
//                                 isScrollControlled: true,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.vertical(
//                                     top: Radius.circular(
//                                       ResponsiveHelper.borderRadius(24),
//                                     ),
//                                   ),
//                                 ),
//                                 builder: (context) {
//                                   return Padding(
//                                     padding: EdgeInsets.only(
//                                       bottom: MediaQuery.of(context).viewInsets.bottom +
//                                           ResponsiveHelper.padding(24),
//                                       left: ResponsiveHelper.padding(16),
//                                       right: ResponsiveHelper.padding(16),
//                                     ),
//                                     child: Container(
//                                       width: double.infinity,
//                                       padding: ResponsiveHelper.all(20),
//                                       constraints: BoxConstraints(
//                                         minHeight: ResponsiveHelper.height(650),
//                                         maxHeight: ResponsiveHelper.height(650),
//                                       ),
//                                       child: Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                         children: [
//                                           Row(
//                                             mainAxisAlignment: MainAxisAlignment.end,
//                                             children: [
//                                               IconButton(
//                                                 onPressed: () => context.pop(),
//                                                 icon: Icon(
//                                                   Icons.close,
//                                                   color: AppColors.black,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           Expanded(
//                                             child: Obx(() {
//                                               if (scanController.isLoadingQr.value) {
//                                                 return const Center(
//                                                   child: CircularProgressIndicator(
//                                                     color: AppColors.blue,
//                                                     strokeWidth: 2.5,
//                                                   ),
//                                                 );
//                                               }
//
//                                               if (scanController.qrCardHtml.value.isEmpty) {
//                                                 return Center(
//                                                   child: GestureDetector(
//                                                     onTap: () =>
//                                                         scanController.getQrCode(),
//                                                     child: Column(
//                                                       mainAxisAlignment:
//                                                       MainAxisAlignment.center,
//                                                       children: [
//                                                         Icon(
//                                                           Icons.refresh_rounded,
//                                                           color: Colors.grey.shade400,
//                                                           size: 36,
//                                                         ),
//                                                         SizedBox(
//                                                           height:
//                                                           ResponsiveHelper.spacing(8),
//                                                         ),
//                                                         Text(
//                                                           AppStrings.tapToRetry.tr,
//                                                           style: GoogleFonts.poppins(
//                                                             fontSize:
//                                                             ResponsiveHelper.fontSize(
//                                                                 13),
//                                                             color: Colors.grey.shade400,
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 );
//                                               }
//
//                                               return RepaintBoundary(
//                                                 key: qrCardKey,
//                                                 child: ClipRRect(
//                                                   borderRadius: BorderRadius.circular(
//                                                     ResponsiveHelper.borderRadius(16),
//                                                   ),
//                                                   child: QrCardWebView(
//                                                     htmlContent:
//                                                     scanController.qrCardHtml.value,
//                                                   ),
//                                                 ),
//                                               );
//                                             }),
//                                           ),
//                                           SizedBox(
//                                             height: ResponsiveHelper.spacing(16),
//                                           ),
//                                           Obx(() {
//                                             if (scanController.qrCardHtml.value.isEmpty) {
//                                               return const SizedBox.shrink();
//                                             }
//
//                                             return SizedBox(
//                                               width: double.infinity,
//                                               child: ElevatedButton.icon(
//                                                 onPressed:
//                                                 scanController.isDownloadingQr.value
//                                                     ? null
//                                                     : () async {
//                                                   scanController
//                                                       .isDownloadingQr
//                                                       .value = true;
//
//                                                   try {
//                                                     await downloadQrCard(
//                                                         context);
//
//                                                     if (context.mounted) Navigator.pop(context);
//                                                   } finally {
//                                                     scanController
//                                                         .isDownloadingQr
//                                                         .value = false;
//                                                   }
//                                                 },
//                                                 icon: scanController
//                                                     .isDownloadingQr.value
//                                                     ? const SizedBox(
//                                                   width: 18,
//                                                   height: 18,
//                                                   child:
//                                                   CircularProgressIndicator(
//                                                     strokeWidth: 2,
//                                                     color: Colors.white,
//                                                   ),
//                                                 )
//                                                     : const Icon(
//                                                   Icons.download_rounded,
//                                                   color: Colors.white,
//                                                 ),
//                                                 label: Text(
//                                                   scanController
//                                                       .isDownloadingQr.value
//                                                       ? AppStrings.downloading.tr
//                                                       : AppStrings.download.tr,
//                                                   style: GoogleFonts.poppins(
//                                                     fontSize:
//                                                     ResponsiveHelper.fontSize(15),
//                                                     fontWeight: FontWeight.w600,
//                                                     color: Colors.white,
//                                                   ),
//                                                 ),
//                                                 style: ElevatedButton.styleFrom(
//                                                   backgroundColor:
//                                                   const Color(0xFF3D72E8),
//                                                   padding: EdgeInsets.symmetric(
//                                                     vertical:
//                                                     ResponsiveHelper.padding(14),
//                                                   ),
//                                                   shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                     BorderRadius.circular(
//                                                       ResponsiveHelper
//                                                           .borderRadius(12),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             );
//                                           }),
//                                           SizedBox(
//                                             height: ResponsiveHelper.spacing(46),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                             borderRadius: BorderRadius.circular(
//                               ResponsiveHelper.borderRadius(16),
//                             ),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Container(
//                                   width: ResponsiveHelper.width(54),
//                                   height: ResponsiveHelper.width(54),
//                                   alignment: Alignment.center,
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFFFFFFF).withOpacity(0.4),
//                                     borderRadius: BorderRadius.circular(
//                                       ResponsiveHelper.borderRadius(16),
//                                     ),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.05),
//                                         blurRadius: 10,
//                                         offset: const Offset(0, 4),
//                                       ),
//                                     ],
//                                   ),
//                                   child: CustomImage(
//                                     imageSrc: AssetsPath.scanIcon,
//                                     width: ResponsiveHelper.width(24),
//                                     height: ResponsiveHelper.width(24),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       )
//                     ],
//                   ),
//                   SizedBox(height: ResponsiveHelper.spacing(15)),
//
//                   /// ✅ Nick name from controller=====================================
//                   Row(
//                     children: [
//                       Text(
//                         user?.nickName.isNotEmpty == true ? user!.nickName : 'unknown',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: ResponsiveHelper.titleFontSize(22),
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(height: ResponsiveHelper.spacing(8)),
//                       GestureDetector(
//                         onTap: () async {
//                           if (isVerified == false) {
//                             await context.pushNamed(RouteName.profile);
//                             profileController.reloadProfile();
//                           } else {
//                             CustomSnackbar.success(context: context, message: "You are already verified");
//                           }
//                         },
//                         child: CustomImage(
//                           imageSrc: isVerified == true
//                               ? AssetsPath.verified
//                               : AssetsPath.unverified,
//                           height: ResponsiveHelper.iconSize(20),
//                           width: ResponsiveHelper.iconSize(20),
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   Text(
//                     user?.licenceId??"",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: ResponsiveHelper.titleFontSize(16),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
// SizedBox(height: ResponsiveHelper.height(4),),
//                   /// ✅ Rating + Location + Vehicle info — fully dynamic
//                   Wrap(
//                     crossAxisAlignment: WrapCrossAlignment.center,
//                     spacing: ResponsiveHelper.width(4),
//                     runSpacing: ResponsiveHelper.height(4),
//                     children: [
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.star,
//                             color: Colors.white,
//                             size: ResponsiveHelper.iconSize(18),
//                           ),
//                           SizedBox(width: ResponsiveHelper.spacing(4)),
//                           Text(
//                             user != null ? formatRating(user.rating) : '0.0',
//                             style: context.bodyMedium.copyWith(color: AppColors.white),
//                           ),
//                           Text(
//                             "(${user?.totalRatings ?? 0})",
//                             style: context.bodySmall.copyWith(color: AppColors.white, fontSize: 8),
//                           ),
//                         ],
//                       ),
//
//                       SizedBox(width: ResponsiveHelper.width(4),),
//                       /// ✅ location — city/country থেকে dynamic, না থাকলে hide
//                       // if ((user?.city != null && user!.city!.isNotEmpty) ||
//                       //     (user?.country != null && user!.country!.isNotEmpty))
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             SizedBox(width: ResponsiveHelper.width(4)),
//                             CustomImage(imageSrc: "assets/icons/location.svg"),
//                             SizedBox(width: ResponsiveHelper.width(4)),
//                             Text(
//                                   () {
//                                 final parts = [user?.city, user?.country]
//                                     .where((e) => e != null && e.isNotEmpty)
//                                     .join(", ");
//                                 return parts.isEmpty ? "N/A" : parts;
//                               }(),
//                               style: context.bodyMedium.copyWith(color: AppColors.white),
//                             ),
//                           ],
//                         ),
// SizedBox(width: ResponsiveHelper.width(8),),
//                       /// ✅ vehicle model — real data
//                    //   if (user?.vehicleModel != null && user!.vehicleModel!.isNotEmpty)
//                         Row(
//                           children: [
//                             Text(
//                               user?.vehicleModel??"N/A",
//                               style: context.bodyMedium.copyWith(color: AppColors.white),
//                             ),
//
//                                                   /// ✅ vehicle color circle
//                                                 //  if (user?.vehicleColor != null && user!.vehicleColor!.isNotEmpty)
//                             Container(
//                               width: ResponsiveHelper.iconSize(14),
//                               height: ResponsiveHelper.iconSize(14),
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: _getVehicleColor(user?.vehicleColor??"N/A"),
//                                 border: Border.all(color: Colors.white, width: 1),
//                               ),
//                             ),
//
//                                                   /// ✅ vehicle type icon — dynamic
//                                                   CustomImage(
//                             imageSrc: _getVehicleTypeIcon(user?.vehicleType),
//                             width: ResponsiveHelper.iconSize(18),
//                             height: ResponsiveHelper.iconSize(18),
//                             imageColor: AppColors.white,
//                                                   ),
//                           ],
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

  ///profile card=====================================================================
  Widget _buildProfileCard(BuildContext context, ProfileController controller) {
    final user = controller.userProfile.value;
    final avatarUrl = user?.avatar;
    final isVerified = user?.isVehicleVerified;

    final bool hasRating = (user?.rating ?? 0) > 0;

    debugPrint("rating===========================${user?.rating?.toString()}");

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
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
            ///  BACKGROUND DESIGN (THE SOFT CIRCLE) ───
            Positioned(
              right: -ResponsiveHelper.width(90),
              bottom: ResponsiveHelper.height(50),
              child: Container(
                width: ResponsiveHelper.width(280),
                height: ResponsiveHelper.width(280),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),

            /// ─── CARD CONTENT ───=======================
            Padding(
              padding: ResponsiveHelper.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Avatar Section with Scan/QR Overlay on Top-Left
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
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

                                ///================= scan overlay ================================
                                Positioned(
                                  top: -ResponsiveHelper.height(4),
                                  left: -ResponsiveHelper.width(4),
                                  child: FutureBuilder<bool?>(
                                    future: SharePrefsHelper.getBool(AppConst.licenseNoVerified),
                                    builder: (context, snapshot) {
                                      final bool isVerified = snapshot.data ?? false;

                                      return InkWell(
                                        onTap: () {
                                          if (scanController.qrCardHtml.value.isEmpty) {
                                            scanController.getQrCode();
                                          }

                                          debugPrint("Current context: ${qrCardKey.currentContext}");

                                          showModalBottomSheet(
                                            context: context,
                                            backgroundColor: AppColors.white,
                                            isScrollControlled: true,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(
                                                  ResponsiveHelper.borderRadius(24),
                                                ),
                                              ),
                                            ),
                                            builder: (context) {
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: MediaQuery.of(context).viewInsets.bottom +
                                                      ResponsiveHelper.padding(24),
                                                  left: ResponsiveHelper.padding(16),
                                                  right: ResponsiveHelper.padding(16),
                                                ),
                                                child: Container(
                                                  width: double.infinity,
                                                  padding: ResponsiveHelper.all(20),
                                                  constraints: BoxConstraints(
                                                    minHeight: ResponsiveHelper.height(650),
                                                    maxHeight: ResponsiveHelper.height(650),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          IconButton(
                                                            onPressed: () => context.pop(),
                                                            icon: Icon(
                                                              Icons.close,
                                                              color: AppColors.black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Expanded(
                                                        child: Obx(() {
                                                          if (scanController.isLoadingQr.value) {
                                                            return const Center(
                                                              child: CircularProgressIndicator(
                                                                color: AppColors.blue,
                                                                strokeWidth: 2.5,
                                                              ),
                                                            );
                                                          }

                                                          if (scanController.qrCardHtml.value.isEmpty) {
                                                            return Center(
                                                              child: GestureDetector(
                                                                onTap: () =>
                                                                    scanController.getQrCode(),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment.center,
                                                                  children: [
                                                                    Icon(
                                                                      Icons.refresh_rounded,
                                                                      color: Colors.grey.shade400,
                                                                      size: 36,
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                      ResponsiveHelper.spacing(8),
                                                                    ),
                                                                    Text(
                                                                      AppStrings.tapToRetry.tr,
                                                                      style: GoogleFonts.poppins(
                                                                        fontSize:
                                                                        ResponsiveHelper.fontSize(
                                                                            13),
                                                                        color: Colors.grey.shade400,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          }

                                                          return RepaintBoundary(
                                                            key: qrCardKey,
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(
                                                                ResponsiveHelper.borderRadius(16),
                                                              ),
                                                              child: QrCardWebView(
                                                                htmlContent:
                                                                scanController.qrCardHtml.value,
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                      ),
                                                      SizedBox(
                                                        height: ResponsiveHelper.spacing(16),
                                                      ),
                                                      Obx(() {
                                                        if (scanController.qrCardHtml.value.isEmpty) {
                                                          return const SizedBox.shrink();
                                                        }

                                                        return SizedBox(
                                                          width: double.infinity,
                                                          child: ElevatedButton.icon(
                                                            onPressed:
                                                            scanController.isDownloadingQr.value
                                                                ? null
                                                                : () async {
                                                              scanController
                                                                  .isDownloadingQr
                                                                  .value = true;

                                                              try {
                                                                await downloadQrCard(
                                                                    context);

                                                                if (context.mounted) Navigator.pop(context);
                                                              } finally {
                                                                scanController
                                                                    .isDownloadingQr
                                                                    .value = false;
                                                              }
                                                            },
                                                            icon: scanController
                                                                .isDownloadingQr.value
                                                                ? const SizedBox(
                                                              width: 18,
                                                              height: 18,
                                                              child:
                                                              CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: Colors.white,
                                                              ),
                                                            )
                                                                : const Icon(
                                                              Icons.download_rounded,
                                                              color: Colors.white,
                                                            ),
                                                            label: Text(
                                                              scanController
                                                                  .isDownloadingQr.value
                                                                  ? AppStrings.downloading.tr
                                                                  : AppStrings.download.tr,
                                                              style: GoogleFonts.poppins(
                                                                fontSize:
                                                                ResponsiveHelper.fontSize(15),
                                                                fontWeight: FontWeight.w600,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                              const Color(0xFF3D72E8),
                                                              padding: EdgeInsets.symmetric(
                                                                vertical:
                                                                ResponsiveHelper.padding(14),
                                                              ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(
                                                                  ResponsiveHelper
                                                                      .borderRadius(12),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                      SizedBox(
                                                        height: ResponsiveHelper.spacing(46),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(
                                          ResponsiveHelper.borderRadius(12),
                                        ),
                                        child: Container(
                                          width: ResponsiveHelper.width(32),
                                          height: ResponsiveHelper.width(32),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color:  Color(0xFF70ADDF),
                                            borderRadius: BorderRadius.circular(
                                              ResponsiveHelper.borderRadius(8),
                                            ),
                                          ),
                                          child: CustomImage(
                                            imageSrc: AssetsPath.scanIcon,
                                            width: ResponsiveHelper.width(16),
                                            height: ResponsiveHelper.width(16),
                                            imageColor: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),


                          ],
                        ),
                        SizedBox(height: ResponsiveHelper.spacing(15)),

                        /// ✅ Nick name from controller=====================================
                        Row(
                          children: [
                            Text(
                              user?.nickName.isNotEmpty == true ? user!.nickName : 'unknown',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ResponsiveHelper.titleFontSize(22),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: ResponsiveHelper.spacing(8)),
                            GestureDetector(
                              onTap: () async {
                                if (isVerified == false) {
                                  await context.pushNamed(RouteName.profile);
                                  profileController.reloadProfile();
                                } else {
                                  CustomSnackbar.success(context: context, message: "You are already verified");
                                }
                              },
                              child: CustomImage(
                                imageSrc: isVerified == true
                                    ? AssetsPath.verified
                                    : AssetsPath.unverified,
                                height: ResponsiveHelper.iconSize(20),
                                width: ResponsiveHelper.iconSize(20),
                              ),
                            ),
                          ],
                        ),

                        Text(
                          user?.licenceId??"",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveHelper.titleFontSize(14),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.height(8)),

                        // /// ✅ Rating + Location + Vehicle info — fully dynamic
                        // Row(
                        //   children: [
                        //     Row(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         Icon(
                        //           Icons.star,
                        //           color: Colors.white,
                        //           size: ResponsiveHelper.iconSize(18),
                        //         ),
                        //         SizedBox(width: ResponsiveHelper.spacing(4)),
                        //         Text(
                        //           user != null ? formatRating(user.rating) : '0.0',
                        //           style: context.bodyMedium.copyWith(color: AppColors.white),
                        //         ),
                        //         Text(
                        //           "(${user?.totalRatings ?? 0})",
                        //           style: context.bodySmall.copyWith(color: AppColors.white, fontSize: 8),
                        //         ),
                        //       ],
                        //     ),
                        //
                        //     SizedBox(width: ResponsiveHelper.width(4)),
                        //     Row(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         SizedBox(width: ResponsiveHelper.width(4)),
                        //         CustomImage(imageSrc: "assets/icons/location.svg"),
                        //         SizedBox(width: ResponsiveHelper.width(4)),
                        //         Text(
                        //               () {
                        //             final parts = [user?.city, user?.country]
                        //                 .where((e) => e != null && e.isNotEmpty)
                        //                 .join(", ");
                        //             return parts.isEmpty ? "N/A" : parts;
                        //           }(),
                        //           style: context.bodyMedium.copyWith(color: AppColors.white),
                        //         ),
                        //       ],
                        //     ),
                        //     SizedBox(width: ResponsiveHelper.width(8)),
                        //   ],
                        // ),






                        //final bool hasRating = profile.rating > 0;
//


                        Row(
                          children: [
                            /// ⭐ Rating
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: hasRating ? Colors.orange : Colors.grey,
                                  size: ResponsiveHelper.iconSize(18),
                                ),
                                SizedBox(width: ResponsiveHelper.width(4)),

                                Text(
                                  (user?.rating ?? 0).toStringAsFixed(1),
                                  style: context.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                Text(
                                  " (${user?.totalRatings ?? 0})",
                                  style: context.bodySmall.copyWith(
                                    color: Colors.white70,
                                    fontSize: ResponsiveHelper.fontSize(10),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(width: ResponsiveHelper.width(10)),

                            /// 📍 Location
                            Expanded(
                              child: Row(

                                children: [
                                  CustomImage(
                                    imageSrc: "assets/icons/location.svg",
                                    width: ResponsiveHelper.iconSize(14),
                                    height: ResponsiveHelper.iconSize(14),
                                    imageColor: Colors.white,
                                  ),

                                  SizedBox(width: ResponsiveHelper.width(4)),

                                  Expanded(
                                    child: Text(
                                          () {
                                        final location = [
                                          user?.city,
                                          user?.country,
                                        ].where((e) => e != null && e.isNotEmpty).join(", ");

                                        return location.isEmpty ? "N/A" : location;
                                      }(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.bodyMedium.copyWith(
                                        color: AppColors.white,

                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),



                        SizedBox(height: ResponsiveHelper.height(6)),
                        /// ✅ vehicle model — real data
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user?.vehicleModel??"N/A",
                              style: context.bodyMedium.copyWith(color: AppColors.white),
                            ),
                            SizedBox(width: ResponsiveHelper.width(6)),
                            Container(
                              width: ResponsiveHelper.iconSize(14),
                              height: ResponsiveHelper.iconSize(14),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getVehicleColor(user?.vehicleColor??"N/A"),
                                border: Border.all(color: Colors.white, width: 1),
                              ),
                            ),
                            SizedBox(width: ResponsiveHelper.width(6)),
                            CustomImage(
                              imageSrc: _getVehicleTypeIcon(user?.vehicleType),
                              width: ResponsiveHelper.iconSize(18),
                              height: ResponsiveHelper.iconSize(18),
                              imageColor: AppColors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),








                  /// ✅ 4 Right side icons and text list ───
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      //_buildRightIndicatorRow("${user?.daysLeftOne ?? 65} days left", AssetsPath.profileOneIcon),
                      _buildRightIndicatorRow("65 \n days left", AssetsPath.profileOneIcon),
                      SizedBox(height: ResponsiveHelper.height(8)),
                      //_buildRightIndicatorRow("${user?.daysLeftTwo ?? 65} days left", AssetsPath.profileTwoIcon),
                      _buildRightIndicatorRow("65 \n days left", AssetsPath.profileTwoIcon),
                      SizedBox(height: ResponsiveHelper.height(8)),
                      // _buildRightIndicatorRow("${user?.daysLeftThree ?? 65} days left", AssetsPath.profileThreeIcon),
                      _buildRightIndicatorRow("65 \n days left", AssetsPath.profileThreeIcon),
                      SizedBox(height: ResponsiveHelper.height(8)),
                      // _buildRightIndicatorRow("${user?.daysLeftFour ?? 65} days left", AssetsPath.profileFourIcon),
                      _buildRightIndicatorRow("65 \n days left", AssetsPath.profileFourIcon),
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

  /// Helper widget to build the right-side dynamic indicator rows
  Widget _buildRightIndicatorRow(String text, String iconPath) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: context.bodyMedium.copyWith(color: AppColors.white,fontSize: ResponsiveHelper.fontSize(12)),
          textAlign: TextAlign.end,
        ),
        SizedBox(width: ResponsiveHelper.spacing(8)),
        CustomImage(
          imageSrc: iconPath,
          width: ResponsiveHelper.width(28),
          height: ResponsiveHelper.width(28),
          imageColor: AppColors.white,
        ),
      ],
    );
  }








  Widget _buildMenuItems(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'icon': AssetsPath.profile,
        'title': AppStrings.profile.tr,
        'onTap': () async {
          await context.pushNamed(RouteName.profile);
          profileController.reloadProfile();
        },
      },
      {
        'icon': AssetsPath.usefulNumber,
        'title': AppStrings.usefulNumber.tr,
        'onTap': () {
          context.pushNamed(RouteName.usefulMemberScreen);
        },
      },
      {
        'icon': AssetsPath.terms,
        'title': AppStrings.termsAndConditions.tr,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WebViewScreen(url: ApiUrl.terms)),
          );
        },
      },
      {
        'icon': AssetsPath.privacy,
        'title': AppStrings.privacyPolicy.tr,
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
        'title': AppStrings.helpSupport.tr,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HelpSupportScreen()),
          );
        },
      },
      {
        'icon': AssetsPath.faq,
        'title': AppStrings.faq.tr,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FaqScreen()),
          );
        },
      },
      {
        'icon': AssetsPath.share,
        'title': AppStrings.shareLink.tr,
        'onTap': () {
          showDialog(
            context: context,
            builder: (_) => ShareLinkDialog(
              shareUrl: 'https://yourapp.com/invite/abc123',
              shareMessage: AppStrings.tryAmazingApp.tr,
            ),
          );
        },
      },
      {
        'icon': AssetsPath.blocked,
        'title': AppStrings.blockedUser5.tr,
        'onTap': () {
          context.pushNamed(RouteName.block);
        },
      },
      {
        'icon': AssetsPath.remove,
        'title': AppStrings.delete.tr,
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
        onPressed: () async {
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