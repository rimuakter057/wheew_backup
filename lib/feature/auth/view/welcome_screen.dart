// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
//
// import 'package:platchatapp/utils/extension/base_extension.dart';
// import '../../../core/router/routes_name.dart';
// import '../../../helper/responsive_helper/responsive_helper.dart';
// import '../../../share/widgets/button/outline_button.dart';
// import '../../../share/widgets/button/primary_button.dart';
// import '../../../share/widgets/button/toggle_button.dart';
// import '../../../share/widgets/custom_image/custom_image.dart';
// import '../../../utils/assets_path/assets_path.dart';
// import '../../../utils/color/app_colors.dart';
//
// class WelcomeScreen extends StatelessWidget {
//   const WelcomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // Initialize responsive helper
//     ResponsiveHelper.init(context);
//
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             // TOP IMAGE
//             ClipRRect(
//               child: CustomImage(
//                 imageSrc: AssetsPath.person0,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//             ),
//
//             SizedBox(height: ResponsiveHelper.spacing(24)),
//
//             // TITLE + FLOATING ICON
//             Stack(
//               alignment: Alignment.topCenter,
//               clipBehavior: Clip.none,
//               children: [
//                 // TEXT CONTENT
//                 Padding(
//                   padding: EdgeInsets.only(
//                     top: ResponsiveHelper.spacing(24),
//                   ),
//                   child: Column(
//                     children: [
//                       Text(
//                         'welcome_message'.tr,
//                         textAlign: TextAlign.center,
//                         style: context.titleLarge.copyWith(
//                           fontSize: 40,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//
//                       SizedBox(height: ResponsiveHelper.spacing(4)),
//
//                       Text(
//                         'welcome_message1'.tr,
//                         textAlign: TextAlign.center,
//                         style: context.titleLarge.copyWith(
//                           fontSize: ResponsiveHelper.fontSize(16),
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                       Text(
//                         'welcome_message2'.tr,
//                         textAlign: TextAlign.center,
//                         style: context.titleLarge.copyWith(
//                           fontSize: ResponsiveHelper.fontSize(16),
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                       Text(
//                         'welcome_message3'.tr,
//                         textAlign: TextAlign.center,
//                         style: context.titleLarge.copyWith(
//                           fontSize: ResponsiveHelper.fontSize(16),
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // FLOATING CHAT ICON
//                 Positioned(
//                   top: -ResponsiveHelper.spacing(2),
//                   left:0,
//                   child: Container(
//                     width: ResponsiveHelper.width(40),
//                     height: ResponsiveHelper.height(40),
//                     /*decoration: const BoxDecoration(
//                       color: Colors.green,
//                       shape: BoxShape.circle,
//                     ),*/
//                     padding: const EdgeInsets.all(0),
//                     child: const CustomImage(
//                       imageSrc: AssetsPath.chat,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//
//             SizedBox(height: ResponsiveHelper.spacing(24)),
//
//             /// LANGUAGE TOGGLE
//             Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: ResponsiveHelper.padding(24),
//               ),
//               child: const LanguageToggleWidget(),
//             ),
//
//             SizedBox(height: ResponsiveHelper.spacing(12)),
//
//             // SIGN IN BUTTON
//             Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: ResponsiveHelper.padding(24),
//               ),
//               child: OutlineButton(
//                 title: 'sign_in'.tr,
//                 onTap: () {
//                   context.pushNamed(RouteName.signIn);
//                 },
//                 borderColor: Colors.blue,
//                 textColor: Colors.blue,
//               ),
//             ),
//
//             SizedBox(height: ResponsiveHelper.spacing(8)),
//
//             // SIGN UP BUTTON
//             /*Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: ResponsiveHelper.padding(24),
//               ),
//               child: PrimaryButton(
//                 title: 'sign_up'.tr,
//                 onTap: () {
//                   context.pushNamed(RouteName.signUp);
//                 },
//                 backgroundColor: Colors.blue,
//                 textColor: Colors.white,
//               ),
//             ),*/
//             Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: ResponsiveHelper.padding(24),
//               ),
//               child: PrimaryButton(
//                 title: 'sign_up'.tr,
//                 onTap: () {
//                   _showAgeConfirmationDialog(context);
//                 },
//                 backgroundColor: Colors.blue,
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
//           'age_confirmation'.tr,
//           textAlign: TextAlign.center,
//         ),
//         content: Text(
//           '16_or_not'.tr,
//           style: context.titleSmall,
//           textAlign: TextAlign.center,
//         ),
//         actions: [
//           Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // NO BUTTON
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey.shade300,
//                     foregroundColor: Colors.black,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 12,
//                     ),
//                   ),
//                   onPressed: () {
//                     Navigator.pop(context);
//                     Get.snackbar(
//                       'access_denied'.tr,
//                       'age_restriction_message'.tr,
//                       snackPosition: SnackPosition.BOTTOM,
//                     );
//                   },
//                   child: Text(
//                     'no'.tr,
//                     style: context.titleMedium.copyWith(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.errorColor,
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 4),
//
//                 // YES BUTTON
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 12,
//                     ),
//                   ),
//                   onPressed: () {
//                     Navigator.pop(context);
//                     context.pushNamed(RouteName.signUp);
//                   },
//                   child: Text(
//                     'yes'.tr,
//                     style: context.titleMedium.copyWith(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       );
//     },
//   );
// }




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:platchatapp/utils/extension/base_extension.dart';
import '../../../core/router/routes_name.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../share/widgets/button/outline_button.dart';
import '../../../share/widgets/button/primary_button.dart';
import '../../../share/widgets/button/toggle_button.dart';
import '../../../share/widgets/custom_image/custom_image.dart';
import '../../../utils/assets_path/assets_path.dart';
import '../../../utils/color/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize responsive helper
    ResponsiveHelper.init(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [




              Container(
                height: size.height * 0.40,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFD7FFCF),
                      Color(0xFFF2FFF0),
                      Color(0xFFFFFFFF),
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                ),
                child: Stack(

                  children: [
                    /// LANGUAGE TOGGLE
                   // SizedBox(height: ResponsiveHelper.spacing(8)),
                    //const LanguageToggleWidget(),
                    // LANGUAGE TOGGLE
                    Positioned(
                      top: 16,
                      right: 16,  // 👈 push to right side
                      child: const LanguageToggleWidget(),
                    ),




                    _avatar(
                      AssetsPath.person1,
                      topPercent: 0.20,
                      leftPercent: 0.45,
                      radius: 40,
                      size: size,
                    ),
                    _avatar(
                      AssetsPath.person2,
                      topPercent: 0.09,
                      leftPercent: 0.10,
                      radius: 35,
                      size: size,
                    ),
                    _avatar(
                      AssetsPath.person2,
                      topPercent: 0.30,
                      rightPercent: 0.15,
                      radius: 35,
                      size: size,
                    ),
                    _avatar(
                      AssetsPath.person0,
                      topPercent: 0.11,
                      rightPercent: 0.45,
                      radius: 28,
                      size: size,
                    ),
                    _avatar(
                      AssetsPath.person4,
                      topPercent: 0.30,
                      leftPercent: 0.16,
                      radius: 45,
                      size: size,
                    ),
                    _avatar(
                      AssetsPath.person5,
                      topPercent: 0.20,
                      leftPercent: 0.16,
                      radius: 30,
                      size: size,
                    ),
                    _avatar(
                      AssetsPath.person6,
                      topPercent: 0.10,
                      rightPercent: 0.08,
                      radius: 30,
                      size: size,
                    ),
                  ],
                ),
              ),
          
          
              SizedBox(height: ResponsiveHelper.spacing(24)),
          
              // TITLE + FLOATING ICON
              Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  // TEXT CONTENT
                  Padding(
                    padding: EdgeInsets.only(
                      top: ResponsiveHelper.spacing(24),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'welcome_message'.tr,
                          textAlign: TextAlign.center,
                          style: context.titleLarge.copyWith(
                            fontSize: 40,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
          
                        SizedBox(height: ResponsiveHelper.spacing(4)),
          
                        Text(
                          'welcome_message1'.tr,
                          textAlign: TextAlign.center,
                          style: context.titleLarge.copyWith(
                            fontSize: ResponsiveHelper.fontSize(16),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'welcome_message2'.tr,
                          textAlign: TextAlign.center,
                          style: context.titleLarge.copyWith(
                            fontSize: ResponsiveHelper.fontSize(16),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'welcome_message3'.tr,
                          textAlign: TextAlign.center,
                          style: context.titleLarge.copyWith(
                            fontSize: ResponsiveHelper.fontSize(16),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
          
                  // FLOATING CHAT ICON
                  Positioned(
                    top: -ResponsiveHelper.spacing(2),
                    left:0,
                    child: Container(
                      width: ResponsiveHelper.width(40),
                      height: ResponsiveHelper.height(40),
                      /*decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),*/
                      padding: const EdgeInsets.all(0),
                      child: const CustomImage(
                        imageSrc: AssetsPath.chat,
                      ),
                    ),
                  ),
                ],
              ),
          
              SizedBox(height: ResponsiveHelper.spacing(24)),
              //
              // /// LANGUAGE TOGGLE
              // Padding(
              //   padding: EdgeInsets.symmetric(
              //     horizontal: ResponsiveHelper.padding(24),
              //   ),
              //   child: const LanguageToggleWidget(),
              // ),
              //
              SizedBox(height: ResponsiveHelper.spacing(12)),
          
              // SIGN IN BUTTON
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.padding(24),
                ),
                child: OutlineButton(
                  title: 'sign_in'.tr,
                  onTap: () {
                    context.pushNamed(RouteName.signIn);
                  },
                  borderColor: AppColors.blue,
                  textColor: AppColors.blue,
                ),
              ),
          
              SizedBox(height: ResponsiveHelper.spacing(8)),
          
              // SIGN UP BUTTON
              /*Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.padding(24),
                ),
                child: PrimaryButton(
                  title: 'sign_up'.tr,
                  onTap: () {
                    context.pushNamed(RouteName.signUp);
                  },
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                ),
              ),*/
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.padding(24),
                ),
                child: PrimaryButton(
                  title: 'sign_up'.tr,
                  onTap: () {
                    _showAgeConfirmationDialog(context);
                  },
                  backgroundColor: AppColors.blue,
                  textColor: Colors.white,
                ),
              ),
          
              SizedBox(height: ResponsiveHelper.spacing(24)),
            ],
          ),
        ),
      ),
    );
  }

  // Avatar Widget with percentage-based positioning
  Widget _avatar(
      String image, {
        double? topPercent,
        double? leftPercent,
        double? rightPercent,
        required double radius,
        required Size size,
      }) {
    return Positioned(
      top: topPercent != null ? size.height * topPercent : null,
      left: leftPercent != null ? size.width * leftPercent : null,
      right: rightPercent != null ? size.width * rightPercent : null,
      child: CircleAvatar(radius: radius, backgroundImage: AssetImage(image)),
    );
  }

}

void _showAgeConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'age_confirmation'.tr,
          textAlign: TextAlign.center,
        ),
        content: Text(
          '16_or_not'.tr,
          style: context.titleSmall,
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // NO BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Get.snackbar(
                      'access_denied'.tr,
                      'age_restriction_message'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  child: Text(
                    'no'.tr,
                    style: context.titleMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.errorColor,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // YES BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:AppColors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    context.pushNamed(RouteName.signUp);
                  },
                  child: Text(
                    'yes'.tr,
                    style: context.titleMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
