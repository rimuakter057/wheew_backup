// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:get/get.dart';
// // import 'package:go_router/go_router.dart';
// //
// // import 'package:platchatapp/utils/extension/base_extension.dart';
// // import '../../../core/router/routes_name.dart';
// // import '../../../helper/responsive_helper/responsive_helper.dart';
// // import '../../../share/widgets/button/outline_button.dart';
// // import '../../../share/widgets/button/primary_button.dart';
// // import '../../../share/widgets/button/toggle_button.dart';
// // import '../../../share/widgets/custom_image/custom_image.dart';
// // import '../../../utils/assets_path/assets_path.dart';
// // import '../../../utils/color/app_colors.dart';
// //
// // class WelcomeScreen extends StatelessWidget {
// //   const WelcomeScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     // Initialize responsive helper
// //     ResponsiveHelper.init(context);
// //
// //     return Scaffold(
// //       body: SafeArea(
// //         child: Column(
// //           children: [
// //             // TOP IMAGE
// //             ClipRRect(
// //               child: CustomImage(
// //                 imageSrc: AssetsPath.person0,
// //                 width: double.infinity,
// //                 fit: BoxFit.cover,
// //               ),
// //             ),
// //
// //             SizedBox(height: ResponsiveHelper.spacing(24)),
// //
// //             // TITLE + FLOATING ICON
// //             Stack(
// //               alignment: Alignment.topCenter,
// //               clipBehavior: Clip.none,
// //               children: [
// //                 // TEXT CONTENT
// //                 Padding(
// //                   padding: EdgeInsets.only(
// //                     top: ResponsiveHelper.spacing(24),
// //                   ),
// //                   child: Column(
// //                     children: [
// //                       Text(
// //                         AppStrings.welcomeMessage.tr,
// //                         textAlign: TextAlign.center,
// //                         style: context.titleLarge.copyWith(
// //                           fontSize: 40,
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                       ),
// //
// //                       SizedBox(height: ResponsiveHelper.spacing(4)),
// //
// //                       Text(
// //                         AppStrings.welcomeMessage1.tr,
// //                         textAlign: TextAlign.center,
// //                         style: context.titleLarge.copyWith(
// //                           fontSize: ResponsiveHelper.fontSize(16),
// //                           fontWeight: FontWeight.w400,
// //                         ),
// //                       ),
// //                       Text(
// //                         AppStrings.welcomeMessage2.tr,
// //                         textAlign: TextAlign.center,
// //                         style: context.titleLarge.copyWith(
// //                           fontSize: ResponsiveHelper.fontSize(16),
// //                           fontWeight: FontWeight.w400,
// //                         ),
// //                       ),
// //                       Text(
// //                         AppStrings.welcomeMessage3.tr,
// //                         textAlign: TextAlign.center,
// //                         style: context.titleLarge.copyWith(
// //                           fontSize: ResponsiveHelper.fontSize(16),
// //                           fontWeight: FontWeight.w400,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //
// //                 // FLOATING CHAT ICON
// //                 Positioned(
// //                   top: -ResponsiveHelper.spacing(2),
// //                   left:0,
// //                   child: Container(
// //                     width: ResponsiveHelper.width(40),
// //                     height: ResponsiveHelper.height(40),
// //                     /*decoration: const BoxDecoration(
// //                       color: Colors.green,
// //                       shape: BoxShape.circle,
// //                     ),*/
// //                     padding: const EdgeInsets.all(0),
// //                     child: const CustomImage(
// //                       imageSrc: AssetsPath.chat,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //
// //             SizedBox(height: ResponsiveHelper.spacing(24)),
// //
// //             /// LANGUAGE TOGGLE
// //             Padding(
// //               padding: EdgeInsets.symmetric(
// //                 horizontal: ResponsiveHelper.padding(24),
// //               ),
// //               child: const LanguageToggleWidget(),
// //             ),
// //
// //             SizedBox(height: ResponsiveHelper.spacing(12)),
// //
// //             // SIGN IN BUTTON
// //             Padding(
// //               padding: EdgeInsets.symmetric(
// //                 horizontal: ResponsiveHelper.padding(24),
// //               ),
// //               child: OutlineButton(
// //                 title: AppStrings.signIn.tr,
// //                 onTap: () {
// //                   context.pushNamed(RouteName.signIn);
// //                 },
// //                 borderColor: Colors.blue,
// //                 textColor: Colors.blue,
// //               ),
// //             ),
// //
// //             SizedBox(height: ResponsiveHelper.spacing(8)),
// //
// //             // SIGN UP BUTTON
// //             /*Padding(
// //               padding: EdgeInsets.symmetric(
// //                 horizontal: ResponsiveHelper.padding(24),
// //               ),
// //               child: PrimaryButton(
// //                 title: AppStrings.signUp.tr,
// //                 onTap: () {
// //                   context.pushNamed(RouteName.signUp);
// //                 },
// //                 backgroundColor: Colors.blue,
// //                 textColor: Colors.white,
// //               ),
// //             ),*/
// //             Padding(
// //               padding: EdgeInsets.symmetric(
// //                 horizontal: ResponsiveHelper.padding(24),
// //               ),
// //               child: PrimaryButton(
// //                 title: AppStrings.signUp.tr,
// //                 onTap: () {
// //                   _showAgeConfirmationDialog(context);
// //                 },
// //                 backgroundColor: Colors.blue,
// //                 textColor: Colors.white,
// //               ),
// //             ),
// //
// //             SizedBox(height: ResponsiveHelper.spacing(24)),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // void _showAgeConfirmationDialog(BuildContext context) {
// //   showDialog(
// //     context: context,
// //     barrierDismissible: false,
// //     builder: (context) {
// //       return AlertDialog(
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(16),
// //         ),
// //         title: Text(
// //           AppStrings.ageConfirmation.tr,
// //           textAlign: TextAlign.center,
// //         ),
// //         content: Text(
// //           AppStrings.sixteenOrNot.tr,
// //           style: context.titleSmall,
// //           textAlign: TextAlign.center,
// //         ),
// //         actions: [
// //           Center(
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 // NO BUTTON
// //                 ElevatedButton(
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: Colors.grey.shade300,
// //                     foregroundColor: Colors.black,
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 24,
// //                       vertical: 12,
// //                     ),
// //                   ),
// //                   onPressed: () {
// //                     Navigator.pop(context);
// //                     Get.snackbar(
// //                       AppStrings.accessDenied.tr,
// //                       AppStrings.ageRestrictionMessage.tr,
// //                       snackPosition: SnackPosition.BOTTOM,
// //                     );
// //                   },
// //                   child: Text(
// //                     AppStrings.no.tr,
// //                     style: context.titleMedium.copyWith(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.w600,
// //                       color: AppColors.errorColor,
// //                     ),
// //                   ),
// //                 ),
// //
// //                 const SizedBox(height: 4),
// //
// //                 // YES BUTTON
// //                 ElevatedButton(
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: Colors.blue,
// //                     foregroundColor: Colors.white,
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 24,
// //                       vertical: 12,
// //                     ),
// //                   ),
// //                   onPressed: () {
// //                     Navigator.pop(context);
// //                     context.pushNamed(RouteName.signUp);
// //                   },
// //                   child: Text(
// //                     AppStrings.yes.tr,
// //                     style: context.titleMedium.copyWith(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.w600,
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       );
// //     },
// //   );
// // }
// //
// // import 'package:auto_size_text/auto_size_text.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:lottie/lottie.dart';
// //
// // import 'package:platchatapp/utils/extension/base_extension.dart';
// // import '../../../core/router/routes_name.dart';
// // import '../../../helper/responsive_helper/responsive_helper.dart';
// // import '../../../share/widgets/button/outline_button.dart';
// // import '../../../share/widgets/button/primary_button.dart';
// // import '../../../share/widgets/button/toggle_button.dart';
// // import '../../../share/widgets/custom_image/custom_image.dart';
// // import '../../../utils/assets_path/assets_path.dart';
// // import '../../../utils/color/app_colors.dart';
// //
// // class WelcomeScreen extends StatelessWidget {
// //   const WelcomeScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     // Initialize responsive helper
// //     ResponsiveHelper.init(context);
// //     final size = MediaQuery.of(context).size;
// //
// //     return Scaffold(
// //       body: SingleChildScrollView(
// //         physics: NeverScrollableScrollPhysics(),
// //
// //         child: Column(
// //           children: [
// //             Container(
// //              // /* height: size.height * 0.42,
// //              //  width: double.infinity,
// //              //  decoration: const BoxDecoration(
// //              //    gradient: LinearGradient(
// //              //      begin: Alignment.topCenter,
// //              //      end: Alignment.bottomCenter,
// //              //      colors: [
// //              //        Color(0xFFD7FFCF),
// //              //        Color(0xFFF2FFF0),
// //              //        Color(0xFFFFFFFF),
// //              //      ],
// //              //      stops: [0.0, 0.6, 1.0],
// //              //    ),
// //              //  ),*/
// //               child: Stack(
// //                 children: [
// //                   /// LANGUAGE TOGGLE
// //                   // SizedBox(height: ResponsiveHelper.spacing(8)),
// //                   //const LanguageToggleWidget(),
// //                   // LANGUAGE TOGGLE
// //                   Positioned(
// //                     top: ResponsiveHelper.spacing(36),
// //                     right: 16, // 👈 push to right side
// //                     child: const LanguageToggleWidget(),
// //                   ),
// //
// //                  /* _avatar(
// //                     AssetsPath.person1,
// //                     topPercent: 0.20,
// //                     leftPercent: 0.45,
// //                     radius: 40,
// //                     size: size,
// //                   ),
// //                   _avatar(
// //                     AssetsPath.person2,
// //                     topPercent: 0.09,
// //                     leftPercent: 0.10,
// //                     radius: 35,
// //                     size: size,
// //                   ),
// //                   _avatar(
// //                     AssetsPath.person2,
// //                     topPercent: 0.30,
// //                     rightPercent: 0.15,
// //                     radius: 35,
// //                     size: size,
// //                   ),
// //                   _avatar(
// //                     AssetsPath.person0,
// //                     topPercent: 0.11,
// //                     rightPercent: 0.45,
// //                     radius: 28,
// //                     size: size,
// //                   ),
// //                   _avatar(
// //                     AssetsPath.person4,
// //                     topPercent: 0.30,
// //                     leftPercent: 0.16,
// //                     radius: 45,
// //                     size: size,
// //                   ),
// //                   _avatar(
// //                     AssetsPath.person5,
// //                     topPercent: 0.20,
// //                     leftPercent: 0.16,
// //                     radius: 30,
// //                     size: size,
// //                   ),
// //                   _avatar(
// //                     AssetsPath.person6,
// //                     topPercent: 0.10,
// //                     rightPercent: 0.08,
// //                     radius: 30,
// //                     size: size,
// //                   ),*/
// //                 ],
// //               ),
// //             ),
// //
// //             SizedBox(height: ResponsiveHelper.spacing(24)),
// //             Lottie.asset(
// //               'assets/animations/logo2Json',
// //               width: ResponsiveHelper.iconSize(90),
// //               height: ResponsiveHelper.iconSize(90),
// //               fit: BoxFit.cover,
// //               repeat: true,
// //             ),
// //             // Row(
// //             //   mainAxisAlignment: MainAxisAlignment.start,
// //             //   crossAxisAlignment: CrossAxisAlignment.center,
// //             //   children: [
// //             //     Lottie.asset(
// //             //       'assets/animations/Chatok.json',
// //             //       width: ResponsiveHelper.iconSize(90),
// //             //       height: ResponsiveHelper.iconSize(90),
// //             //       fit: BoxFit.cover,
// //             //       repeat: true,
// //             //     ),
// //             //     //SizedBox(width: ResponsiveHelper.spacing(8)),
// //             //     CustomImage(
// //             //       imageSrc: AssetsPath.plateChat,
// //             //       height: ResponsiveHelper.height(40),
// //             //       fit: BoxFit.contain,
// //             //     ),
// //             //   ],
// //             // ),
// //
// //             // Lottie.asset(
// //             //   // 'assets/animations/Chat.json',
// //             //   'assets/animations/Chatok.json',
// //             //   width: ResponsiveHelper.iconSize(100),
// //             //   height: ResponsiveHelper.iconSize(100),
// //             //   fit: BoxFit.cover,
// //             //   repeat: true, // animation loop করবে
// //             // ),
// //             // CustomImage(
// //             //   imageSrc: AssetsPath.plateChat,
// //             //   height: ResponsiveHelper.height(28),
// //             //   fit: BoxFit.contain,
// //             // ),
// //
// //             // Stack(
// //             //   //alignment: Alignment.topCenter,
// //             //   alignment: Alignment.topCenter,
// //             //   clipBehavior: Clip.none,
// //             //   children: [
// //             //     // TEXT CONTENT
// //             //     Column(
// //             //       children: [
// //             //         Text(
// //             //           AppStrings.welcomeMessage.tr,
// //             //           textAlign: TextAlign.start,
// //             //           style: context.titleLarge.copyWith(
// //             //             fontSize: 40,
// //             //             fontWeight: FontWeight.w400,
// //             //           ),
// //             //         ),
// //             //
// //             //         SizedBox(height: ResponsiveHelper.spacing(4)),
// //             //
// //             //         Text(
// //             //           AppStrings.welcomeMessage1.tr,
// //             //           //textAlign: TextAlign.center,
// //             //           style: context.titleLarge.copyWith(
// //             //             fontSize: ResponsiveHelper.fontSize(16),
// //             //             fontWeight: FontWeight.w400,
// //             //           ),
// //             //         ),
// //             //         Text(
// //             //           AppStrings.welcomeMessage2.tr,
// //             //           //textAlign: TextAlign.center,
// //             //           style: context.titleLarge.copyWith(
// //             //             fontSize: ResponsiveHelper.fontSize(16),
// //             //             fontWeight: FontWeight.w400,
// //             //           ),
// //             //         ),
// //             //         Text(
// //             //           AppStrings.welcomeMessage3.tr,
// //             //           textAlign: TextAlign.center,
// //             //           style: context.titleLarge.copyWith(
// //             //             fontSize: ResponsiveHelper.fontSize(16),
// //             //             fontWeight: FontWeight.w400,
// //             //           ),
// //             //         ),
// //             //       ],
// //             //     ),
// //             //
// //             //     // // FLOATING CHAT ICON
// //             //     // Positioned(
// //             //     //   top: -ResponsiveHelper.spacing(2),
// //             //     //   left: 0,
// //             //     //   child: Container(
// //             //     //     width: ResponsiveHelper.width(40),
// //             //     //     height: ResponsiveHelper.height(40),
// //             //     //     /*decoration: const BoxDecoration(
// //             //     //       color: Colors.green,
// //             //     //       shape: BoxShape.circle,
// //             //     //     ),*/
// //             //     //     padding: const EdgeInsets.all(0),
// //             //     //     child: const CustomImage(imageSrc: AssetsPath.chat),
// //             //     //   ),
// //             //     // ),
// //             //   ],
// //             // ),
// //             /*Padding(
// //               padding: EdgeInsets.symmetric(
// //                 horizontal: ResponsiveHelper.padding(24),
// //               ),
// //               child: Stack(
// //                 alignment: Alignment.topCenter,
// //                 clipBehavior: Clip.none,
// //                 children: [
// //                   Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     // ✅ align all text to left
// //                     children: [
// //                       Text(
// //                         AppStrings.welcomeMessage.tr,
// //                         style: context.titleLarge.copyWith(
// //                           fontSize: ResponsiveHelper.fontSize(32),
// //                           fontWeight: FontWeight.w400,
// //                         ),
// //                       ),
// //
// //                       SizedBox(height: ResponsiveHelper.spacing(4)),
// //
// //                       Text(
// //                         AppStrings.welcomeMessage1.tr,
// //                         style: context.titleLarge.copyWith(
// //                           fontSize: ResponsiveHelper.fontSize(16),
// //                           fontWeight: FontWeight.w400,
// //                         ),
// //                       ),
// //                       Text(
// //                         AppStrings.welcomeMessage2.tr,
// //                         style: context.titleLarge.copyWith(
// //                           fontSize: ResponsiveHelper.fontSize(16),
// //                           fontWeight: FontWeight.w400,
// //                         ),
// //                       ),
// //                       Text(
// //                         AppStrings.welcomeMessage3.tr,
// //                         style: context.titleLarge.copyWith(
// //                           fontSize: ResponsiveHelper.fontSize(16),
// //                           fontWeight: FontWeight.w400,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),*/
// //             Padding(
// //               padding: EdgeInsets.symmetric(
// //                 horizontal: ResponsiveHelper.padding(24),
// //               ),
// //               child: Stack(
// //                 alignment: Alignment.topCenter,
// //                 clipBehavior: Clip.none,
// //                 children: [
// //                   Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       AutoSizeText(
// //                         AppStrings.welcomeMessage.tr,
// //                         maxLines: 1,
// //                         minFontSize: 18,
// //                         style: context.titleLarge.copyWith(
// //                           fontSize: ResponsiveHelper.fontSize(32),
// //                           fontWeight: FontWeight.w400,
// //                         ),
// //                       ),
// //
// //                       SizedBox(height: ResponsiveHelper.spacing(4)),
// //
// //                       AutoSizeText(
// //                         AppStrings.welcomeMessage1.tr,
// //                         maxLines: 1,
// //                         minFontSize: 10,
// //                         overflow: TextOverflow.ellipsis,
// //                         style: context.titleLarge.copyWith(
// //                           fontSize: ResponsiveHelper.fontSize(16),
// //                           fontWeight: FontWeight.w400,
// //                         ),
// //                       ),
// //
// //                       AutoSizeText(
// //                         AppStrings.welcomeMessage2.tr,
// //                         maxLines: 1,
// //                         minFontSize: 10,
// //                         overflow: TextOverflow.ellipsis,
// //                         style: context.titleLarge.copyWith(
// //                           fontSize: ResponsiveHelper.fontSize(16),
// //                           fontWeight: FontWeight.w400,
// //                         ),
// //                       ),
// //
// //                       AutoSizeText(
// //                         AppStrings.welcomeMessage3.tr,
// //                         maxLines: 1,
// //                         minFontSize: 10,
// //                         overflow: TextOverflow.ellipsis,
// //                         style: context.titleLarge.copyWith(
// //                           fontSize: ResponsiveHelper.fontSize(16),
// //                           fontWeight: FontWeight.w400,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //
// //             SizedBox(height: ResponsiveHelper.spacing(24)),
// //             //
// //             // /// LANGUAGE TOGGLE
// //             // Padding(
// //             //   padding: EdgeInsets.symmetric(
// //             //     horizontal: ResponsiveHelper.padding(24),
// //             //   ),
// //             //   child: const LanguageToggleWidget(),
// //             // ),
// //             //
// //             //SizedBox(height: ResponsiveHelper.spacing(12)),
// //
// //             // SIGN IN BUTTON
// //             Padding(
// //               padding: EdgeInsets.symmetric(
// //                 horizontal: ResponsiveHelper.padding(24),
// //               ),
// //               child: OutlineButton(
// //                 title: AppStrings.signIn.tr,
// //                 onTap: () {
// //                   context.pushNamed(RouteName.signIn);
// //                 },
// //                 borderColor: AppColors.blue,
// //                 textColor: AppColors.blue,
// //               ),
// //             ),
// //
// //             SizedBox(height: ResponsiveHelper.height(8)),
// //
// //             // SIGN UP BUTTON
// //             /*Padding(
// //               padding: EdgeInsets.symmetric(
// //                 horizontal: ResponsiveHelper.padding(24),
// //               ),
// //               child: PrimaryButton(
// //                 title: AppStrings.signUp.tr,
// //                 onTap: () {
// //                   context.pushNamed(RouteName.signUp);
// //                 },
// //                 backgroundColor: Colors.blue,
// //                 textColor: Colors.white,
// //               ),
// //             ),*/
// //             Padding(
// //               padding: EdgeInsets.symmetric(
// //                 horizontal: ResponsiveHelper.padding(24),
// //               ),
// //               child: PrimaryButton(
// //                 title: AppStrings.signUp.tr,
// //                 onTap: () {
// //                   _showAgeConfirmationDialog(context);
// //                 },
// //                 backgroundColor: AppColors.blue,
// //                 textColor: Colors.white, // ✅ correct parameter name
// //               ),
// //             ),
// //
// //             SizedBox(height: ResponsiveHelper.spacing(24)),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // Avatar Widget with percentage-based positioning
// //   Widget _avatar(
// //     String image, {
// //     double? topPercent,
// //     double? leftPercent,
// //     double? rightPercent,
// //     required double radius,
// //     required Size size,
// //   }) {
// //     return Positioned(
// //       top: topPercent != null ? size.height * topPercent : null,
// //       left: leftPercent != null ? size.width * leftPercent : null,
// //       right: rightPercent != null ? size.width * rightPercent : null,
// //       child: CircleAvatar(radius: radius, backgroundImage: AssetImage(image)),
// //     );
// //   }
// // }
// //
// // void _showAgeConfirmationDialog(BuildContext context) {
// //   showDialog(
// //     context: context,
// //     barrierDismissible: false,
// //     builder: (context) {
// //       return AlertDialog(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //         title: Text(
// //           AppStrings.ageConfirmation.tr,
// //           style: context.titleSmall.copyWith(
// //             fontSize: 16,
// //             fontWeight: FontWeight.w600,
// //           ),
// //           textAlign: TextAlign.center,
// //         ),
// //         content: Text(
// //           AppStrings.sixteenOrNot.tr,
// //           style: context.titleSmall,
// //           textAlign: TextAlign.center,
// //         ),
// //
// //         // actions: [
// //         //   Center(
// //         //     child: Column(
// //         //       mainAxisSize: MainAxisSize.min,
// //         //       children: [
// //         //         // NO BUTTON
// //         //         ElevatedButton(
// //         //           style: ElevatedButton.styleFrom(
// //         //             backgroundColor: Colors.grey.shade300,
// //         //             foregroundColor: Colors.black,
// //         //             shape: RoundedRectangleBorder(
// //         //               borderRadius: BorderRadius.circular(12),
// //         //             ),
// //         //             padding: const EdgeInsets.symmetric(
// //         //               horizontal: 24,
// //         //               vertical: 12,
// //         //             ),
// //         //           ),
// //         //           onPressed: () {
// //         //             Navigator.pop(context);
// //         //             Get.snackbar(
// //         //               AppStrings.accessDenied.tr,
// //         //               AppStrings.ageRestrictionMessage.tr,
// //         //               snackPosition: SnackPosition.BOTTOM,
// //         //             );
// //         //           },
// //         //           child: Text(
// //         //             AppStrings.no.tr,
// //         //             style: context.titleMedium.copyWith(
// //         //               fontSize: 16,
// //         //               fontWeight: FontWeight.w600,
// //         //               color: AppColors.errorColor,
// //         //             ),
// //         //           ),
// //         //         ),
// //         //
// //         //         const SizedBox(height: 4),
// //         //
// //         //         // YES BUTTON
// //         //         ElevatedButton(
// //         //           style: ElevatedButton.styleFrom(
// //         //             backgroundColor: AppColors.blue,
// //         //             foregroundColor: Colors.white,
// //         //             shape: RoundedRectangleBorder(
// //         //               borderRadius: BorderRadius.circular(12),
// //         //             ),
// //         //             padding: const EdgeInsets.symmetric(
// //         //               horizontal: 24,
// //         //               vertical: 12,
// //         //             ),
// //         //           ),
// //         //           onPressed: () {
// //         //             Navigator.pop(context);
// //         //             context.pushNamed(RouteName.signUp);
// //         //           },
// //         //           child: Text(
// //         //             AppStrings.yes.tr,
// //         //             style: context.titleMedium.copyWith(
// //         //               fontSize: 16,
// //         //               fontWeight: FontWeight.w600,
// //         //               color: Colors.white,
// //         //             ),
// //         //           ),
// //         //         ),
// //         //       ],
// //         //     ),
// //         //   ),
// //         // ],
// //         actions: [
// //           Row(
// //             crossAxisAlignment: CrossAxisAlignment.center,
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               // NO BUTTON
// //               GestureDetector(
// //                 onTap: () {
// //                   Navigator.pop(context);
// //                 },
// //                 child: Container(
// //                   padding: ResponsiveHelper.symmetric(
// //                     horizontal: 32,
// //                     vertical: 12,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     border: Border.all(color: AppColors.blue),
// //                     borderRadius: BorderRadius.circular(
// //                       ResponsiveHelper.borderRadius(24),
// //                     ),
// //                   ),
// //
// //                   child: Text(AppStrings.no.tr, style: context.bodySmall),
// //                 ),
// //               ),
// //
// //               SizedBox(width: ResponsiveHelper.width(12)),
// //
// //               GestureDetector(
// //                 onTap: () {
// //                   Navigator.pop(context);
// //                   context.pushNamed(RouteName.signUp);
// //                 },
// //
// //                 child: Container(
// //                   padding: ResponsiveHelper.symmetric(
// //                     horizontal: 32,
// //                     vertical: 12,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: AppColors.blue,
// //                     border: Border.all(color: AppColors.blue),
// //                     borderRadius: BorderRadius.circular(
// //                       ResponsiveHelper.borderRadius(24),
// //                     ),
// //                   ),
// //                   child: Text(
// //                     AppStrings.yes.tr,
// //                     style: context.titleSmall.copyWith(color: AppColors.white),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       );
// //     },
// //   );
// // }
//
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'package:platchatapp/helper/custom_image/custom_image.dart';
// import 'package:platchatapp/utils/assets_path/assets_path.dart';
// import 'package:platchatapp/utils/extension/base_extension.dart';
// import 'package:platchatapp/utils/language/app_string.dart';
// import '../../../core/router/routes_name.dart';
// import '../../../helper/responsive_helper/responsive_helper.dart';
// import '../../../share/widgets/button/outline_button.dart';
// import '../../../share/widgets/button/primary_button.dart';
// import '../../../share/widgets/button/toggle_button.dart';
// import '../../../utils/color/app_colors.dart';
//
// class WelcomeScreen extends StatelessWidget {
//   const WelcomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // ─── Language Toggle ───────────────────────────────────────
//               Align(
//                 alignment: Alignment.topRight,
//                 child: Padding(
//                   padding: EdgeInsets.only(
//                     top: ResponsiveHelper.spacing(20),
//                     right: 16,
//                   ),
//                   child: const LanguageToggleWidget(),
//                 ),
//               ),
//
//               SizedBox(height: ResponsiveHelper.spacing(20)),
//
//               // ─── Everything inside one padding ─────────────────────────
//               Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: ResponsiveHelper.padding(24),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//
//                     // Container(
//                     //   width: double.infinity,
//                     //   alignment: Alignment.center,
//                     //   child: Lottie.asset(
//                     //     'assets/animations/logo2_animated.json',
//                     //     width: ResponsiveHelper.iconSize(320),
//                     //     height: ResponsiveHelper.iconSize(340),
//                     //     fit: BoxFit.contain,
//                     //     repeat: true,
//                     //   ),
//                     // ),
//                     //
//
//                     // Logo
//                     CustomImage(
//                       imageSrc: AssetsPath.appLogoUpdate,
//                       width: ResponsiveHelper.iconSize(250),
//                       height: ResponsiveHelper.iconSize(250),
//                     ),
//
//                     SizedBox(height: ResponsiveHelper.spacing(24)),
//
//                     // Welcome Text
//                     AutoSizeText(
//                      // AppStrings.welcomeMessage.tr,
//                       AppStrings.welcomeTitle.tr,
//                       maxLines: 1,
//                       minFontSize: 18,
//                       textAlign: TextAlign.center,
//                       style: context.titleLarge.copyWith(
//                         fontSize: ResponsiveHelper.fontSize(24),
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//
//                     SizedBox(height: ResponsiveHelper.spacing(16)),
//
//                     AutoSizeText(
//                       AppStrings.welcomeSubtitle.tr,
//                       //Register quickly and connect with a wheewer wherever you go
//
//                       minFontSize: 16,
//                       textAlign: TextAlign.center,
//
//                       style: context.titleLarge.copyWith(
//                         fontSize: ResponsiveHelper.fontSize(14),
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                     // SizedBox(height: ResponsiveHelper.spacing(6)),
//                     // AutoSizeText(
//                     //   AppStrings.welcomeMessage2.tr,
//                     //   maxLines: 1,
//                     //   minFontSize: 10,
//                     //   textAlign: TextAlign.center,
//                     //   overflow: TextOverflow.ellipsis,
//                     //   style: context.titleLarge.copyWith(
//                     //     fontSize: ResponsiveHelper.fontSize(16),
//                     //     fontWeight: FontWeight.w400,
//                     //   ),
//                     // ),
//                     // SizedBox(height: ResponsiveHelper.spacing(6)),
//                     // AutoSizeText(
//                     //   AppStrings.welcomeMessage3.tr,
//                     //   maxLines: 1,
//                     //   minFontSize: 10,
//                     //   textAlign: TextAlign.center,
//                     //   overflow: TextOverflow.ellipsis,
//                     //   style: context.titleLarge.copyWith(
//                     //     fontSize: ResponsiveHelper.fontSize(16),
//                     //     fontWeight: FontWeight.w400,
//                     //   ),
//                     // ),
//
//                     SizedBox(height: ResponsiveHelper.spacing(32)),
//
//                     // Sign In
//                     OutlineButton(
//                       title: AppStrings.signIn.tr,
//                       onTap: () => context.pushNamed(RouteName.signIn),
//                       borderColor: AppColors.blue,
//                       textColor: AppColors.blue,
//                     ),
//
//                     SizedBox(height: ResponsiveHelper.height(8)),
//
//                     // Sign Up
//                     PrimaryButton(
//                       title: AppStrings.signUp.tr,
//                       onTap: () => _showAgeConfirmationDialog(context),
//                       backgroundColor: AppColors.blue,
//                       textColor: Colors.white,
//                     ),
//
//                     SizedBox(height: ResponsiveHelper.spacing(24)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Age Confirmation Dialog ───────────────────────────────────────────────────
//
// void _showAgeConfirmationDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: Text(
//           AppStrings.ageConfirmation.tr,
//           textAlign: TextAlign.center,
//           style: context.titleSmall.copyWith(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: Text(
//           AppStrings.sixteenOrNot.tr,
//           textAlign: TextAlign.center,
//           style: context.titleSmall,
//         ),
//         actions: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // No
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   padding: ResponsiveHelper.symmetric(
//                     horizontal: 32,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: AppColors.blue),
//                     borderRadius: BorderRadius.circular(
//                       ResponsiveHelper.borderRadius(24),
//                     ),
//                   ),
//                   child: Text(AppStrings.no.tr, style: context.bodySmall),
//                 ),
//               ),
//
//               SizedBox(width: ResponsiveHelper.width(12)),
//
//               // Yes
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                   context.pushNamed(RouteName.signUp);
//                 },
//                 child: Container(
//                   padding: ResponsiveHelper.symmetric(
//                     horizontal: 32,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColors.blue,
//                     border: Border.all(color: AppColors.blue),
//                     borderRadius: BorderRadius.circular(
//                       ResponsiveHelper.borderRadius(24),
//                     ),
//                   ),
//                   child: Text(
//                     AppStrings.yes.tr,
//                     style: context.titleSmall.copyWith(color: AppColors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       );
//     },
//   );
// }
//
//
//
// /*
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'package:lottie/lottie.dart';
// import 'package:platchatapp/utils/extension/base_extension.dart';
// import '../../../core/router/routes_name.dart';
// import '../../../helper/responsive_helper/responsive_helper.dart';
// import '../../../share/widgets/button/outline_button.dart';
// import '../../../share/widgets/button/primary_button.dart';
// import '../../../share/widgets/button/toggle_button.dart';
// import '../../../utils/assets_path/assets_path.dart';
// import '../../../utils/color/app_colors.dart';
//
// class WelcomeScreen extends StatelessWidget {
//   const WelcomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     ResponsiveHelper.init(context);
//
//     return Scaffold(
//       body: Column(
//         children: [
//           /// Language Toggle
//           Align(
//             alignment: Alignment.topRight,
//             child: Padding(
//               padding: EdgeInsets.only(
//                 top: ResponsiveHelper.spacing(36),
//                 right: 16,
//               ),
//               child: const LanguageToggleWidget(),
//             ),
//           ),
//
//           SizedBox(height: ResponsiveHelper.spacing(30)),
//
//           /// Logo Animation
//           Lottie.asset(
//             'assets/animations/logo2_animated.json',
//             width: ResponsiveHelper.iconSize(290),
//             height: ResponsiveHelper.iconSize(320),
//             fit: BoxFit.cover,
//             repeat: true,
//           ),
//
//           SizedBox(height: ResponsiveHelper.spacing(40)),
//
//           /// Welcome Text
//           Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: ResponsiveHelper.padding(24),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 AutoSizeText(
//                   AppStrings.welcomeMessage.tr,
//                   maxLines: 1,
//                   minFontSize: 18,
//                   style: context.titleLarge.copyWith(
//                     fontSize: ResponsiveHelper.fontSize(32),
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//
//                 SizedBox(height: ResponsiveHelper.spacing(4)),
//
//                 AutoSizeText(
//                   AppStrings.welcomeMessage1.tr,
//                   maxLines: 1,
//                   minFontSize: 10,
//                   overflow: TextOverflow.ellipsis,
//                   style: context.titleLarge.copyWith(
//                     fontSize: ResponsiveHelper.fontSize(16),
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//
//                 AutoSizeText(
//                   AppStrings.welcomeMessage2.tr,
//                   maxLines: 1,
//                   minFontSize: 10,
//                   overflow: TextOverflow.ellipsis,
//                   style: context.titleLarge.copyWith(
//                     fontSize: ResponsiveHelper.fontSize(16),
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//
//                 AutoSizeText(
//                   AppStrings.welcomeMessage3.tr,
//                   maxLines: 1,
//                   minFontSize: 10,
//                   overflow: TextOverflow.ellipsis,
//                   style: context.titleLarge.copyWith(
//                     fontSize: ResponsiveHelper.fontSize(16),
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           const Spacer(), // ✅ pushes buttons to bottom
//
//           /// Sign In Button
//           Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: ResponsiveHelper.padding(24),
//             ),
//             child: OutlineButton(
//               title: AppStrings.signIn.tr,
//               onTap: () => context.pushNamed(RouteName.signIn),
//               borderColor: AppColors.blue,
//               textColor: AppColors.blue,
//             ),
//           ),
//
//           SizedBox(height: ResponsiveHelper.height(8)),
//
//           /// Sign Up Button
//           Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: ResponsiveHelper.padding(24),
//             ),
//             child: PrimaryButton(
//               title: AppStrings.signUp.tr,
//               onTap: () => _showAgeConfirmationDialog(context),
//               backgroundColor: AppColors.blue,
//               textColor: Colors.white,
//             ),
//           ),
//
//           SizedBox(height: ResponsiveHelper.spacing(24)),
//         ],
//       ),
//     );
//   }
// }
//
// void _showAgeConfirmationDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: Text(
//           AppStrings.ageConfirmation.tr,
//           style: context.titleSmall.copyWith(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         content: Text(
//           AppStrings.sixteenOrNot.tr,
//           style: context.titleSmall,
//           textAlign: TextAlign.center,
//         ),
//         actions: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               /// No Button
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   padding: ResponsiveHelper.symmetric(
//                     horizontal: 32,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: AppColors.blue),
//                     borderRadius: BorderRadius.circular(
//                       ResponsiveHelper.borderRadius(24),
//                     ),
//                   ),
//                   child: Text(AppStrings.no.tr, style: context.bodySmall),
//                 ),
//               ),
//
//               SizedBox(width: ResponsiveHelper.width(12)),
//
//               /// Yes Button
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                   context.pushNamed(RouteName.signUp);
//                 },
//                 child: Container(
//                   padding: ResponsiveHelper.symmetric(
//                     horizontal: 32,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColors.blue,
//                     border: Border.all(color: AppColors.blue),
//                     borderRadius: BorderRadius.circular(
//                       ResponsiveHelper.borderRadius(24),
//                     ),
//                   ),
//                   child: Text(
//                     AppStrings.yes.tr,
//                     style: context.titleSmall.copyWith(
//                       color: AppColors.white,
//                     ),
//                   ),
//                 ),
//               ),
//
//             ],
//           ),
//         ],
//       );
//     },
//   );
// }
// */
//
// /*
// class WelcomeScreen extends StatelessWidget {
//   const WelcomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     ResponsiveHelper.init(context);
//
//     return Scaffold(
//       body: SingleChildScrollView(
//         physics: const NeverScrollableScrollPhysics(),
//         child: Column(
//           children: [
//             /// Language Toggle
//             Align(
//               alignment: Alignment.topRight,
//               child: Padding(
//                 padding: EdgeInsets.only(
//                   top: ResponsiveHelper.spacing(36),
//                   right: 16,
//                 ),
//                 child: const LanguageToggleWidget(),
//               ),
//             ),
//
//             SizedBox(height: ResponsiveHelper.spacing(30)),
//
//             /// Logo Animation
//             Align(
//               alignment: Alignment.center,
//               child: Lottie.asset(
//                 'assets/animations/logo2_animated.json',
//                 width: ResponsiveHelper.iconSize(290),
//                 height: ResponsiveHelper.iconSize(320),
//                 fit: BoxFit.cover,
//                 repeat: true,
//               ),
//             ),
//
//             SizedBox(height: ResponsiveHelper.spacing(40)),
//
//             /// Welcome Text
//             Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: ResponsiveHelper.padding(24),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   AutoSizeText(
//                     AppStrings.welcomeMessage.tr,
//                     maxLines: 1,
//                     minFontSize: 18,
//                     style: context.titleLarge.copyWith(
//                       fontSize: ResponsiveHelper.fontSize(32),
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//
//                   SizedBox(height: ResponsiveHelper.spacing(4)),
//
//                   AutoSizeText(
//                     AppStrings.welcomeMessage1.tr,
//                     maxLines: 1,
//                     minFontSize: 10,
//                     overflow: TextOverflow.ellipsis,
//                     style: context.titleLarge.copyWith(
//                       fontSize: ResponsiveHelper.fontSize(16),
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//
//                   AutoSizeText(
//                     AppStrings.welcomeMessage2.tr,
//                     maxLines: 1,
//                     minFontSize: 10,
//                     overflow: TextOverflow.ellipsis,
//                     style: context.titleLarge.copyWith(
//                       fontSize: ResponsiveHelper.fontSize(16),
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//
//                   AutoSizeText(
//                     AppStrings.welcomeMessage3.tr,
//                     maxLines: 1,
//                     minFontSize: 10,
//                     overflow: TextOverflow.ellipsis,
//                     style: context.titleLarge.copyWith(
//                       fontSize: ResponsiveHelper.fontSize(16),
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             SizedBox(height: ResponsiveHelper.spacing(24)),
//
//             /// Sign In Button
//             Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: ResponsiveHelper.padding(24),
//               ),
//               child: OutlineButton(
//                 title: AppStrings.signIn.tr,
//                 onTap: () => context.pushNamed(RouteName.signIn),
//                 borderColor: AppColors.blue,
//                 textColor: AppColors.blue,
//               ),
//             ),
//
//             SizedBox(height: ResponsiveHelper.height(8)),
//
//             /// Sign Up Button
//             Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: ResponsiveHelper.padding(24),
//               ),
//               child: PrimaryButton(
//                 title: AppStrings.signUp.tr,
//                 onTap: () => _showAgeConfirmationDialog(context),
//                 backgroundColor: AppColors.blue,
//                 textColor: Colors.white,
//               ),
//             ),
//
//             SizedBox(height: ResponsiveHelper.spacing(24)),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// void _showAgeConfirmationDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: Text(
//           AppStrings.ageConfirmation.tr,
//           style: context.titleSmall.copyWith(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         content: Text(
//           AppStrings.sixteenOrNot.tr,
//           style: context.titleSmall,
//           textAlign: TextAlign.center,
//         ),
//         actions: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               /// No Button
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   padding: ResponsiveHelper.symmetric(
//                     horizontal: 32,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: AppColors.blue),
//                     borderRadius: BorderRadius.circular(
//                       ResponsiveHelper.borderRadius(24),
//                     ),
//                   ),
//                   child: Text(AppStrings.no.tr, style: context.bodySmall),
//                 ),
//               ),
//
//               SizedBox(width: ResponsiveHelper.width(12)),
//
//               /// Yes Button
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                   context.pushNamed(RouteName.signUp);
//                 },
//                 child: Container(
//                   padding: ResponsiveHelper.symmetric(
//                     horizontal: 32,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColors.blue,
//                     border: Border.all(color: AppColors.blue),
//                     borderRadius: BorderRadius.circular(
//                       ResponsiveHelper.borderRadius(24),
//                     ),
//                   ),
//                   child: Text(
//                     AppStrings.yes.tr,
//                     style: context.titleSmall.copyWith(
//                       color: AppColors.white,
//                     ),
//                   ),
//                 ),
//               ),
//
//             ],
//           ),
//         ],
//       );
//     },
//   );
// }
// */
