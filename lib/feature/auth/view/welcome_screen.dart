import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize responsive helper
    ResponsiveHelper.init(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // TOP IMAGE
            ClipRRect(
              child: CustomImage(
                imageSrc: AssetsPath.person0,
                width: double.infinity,
                fit: BoxFit.cover,
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

            /// LANGUAGE TOGGLE
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.padding(24),
              ),
              child: const LanguageToggleWidget(),
            ),

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
                borderColor: Colors.blue,
                textColor: Colors.blue,
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(8)),

            // SIGN UP BUTTON
            Padding(
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
            ),

            SizedBox(height: ResponsiveHelper.spacing(24)),
          ],
        ),
      ),
    );
  }
}
