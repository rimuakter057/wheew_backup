import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:platchatapp/helper/custom_gradient_button/custom_gradient_button.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:platchatapp/utils/language/app_string.dart';

import '../../../../core/router/routes_name.dart';
import '../../../../helper/custom_image/custom_image.dart';
import '../../../../helper/responsive_helper/responsive_helper.dart';
import '../../../../share/widgets/button/toggle_button.dart';

/// The brand tagline shown as the welcome headline.
///
/// Deliberately a literal instead of AppStrings.welcomeTitle1.tr — it's part
/// of the brand (it's set in the logo artwork itself), so it stays English in
/// every language. The translated key is left in place for reference.
const String _kWelcomeHeadline = 'Drive.\nChat.\nPark.\nBreathe.';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetsPath.onboardingScreen),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // --- TOP ROW: Logo + Language Toggle -----------------------
              Positioned(
                top: ResponsiveHelper.height(20),
                left: ResponsiveHelper.padding(20),
                right: ResponsiveHelper.padding(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomImage(
                      imageSrc: AssetsPath.appLogoUpdate,
                      height: ResponsiveHelper.height(58),
                      fit: BoxFit.contain,
                    ),
                    const LanguageToggleWidget(),
                  ],
                ),
              ),

              // --- HEADLINE + DIVIDER + SUBTITLE --------------------------
              Positioned(
                top: size.height * 0.15,
                left: ResponsiveHelper.padding(24),
                right: ResponsiveHelper.padding(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand tagline — always English, never translated, so it
                    // matches the wordmark on the logo/splash regardless of
                    // the app language.
                    ..._kWelcomeHeadline
                        .split('\n')
                        .map((word) => _headlineLine(word)),

                    SizedBox(height: ResponsiveHelper.spacing(12)),



                    SizedBox(height: ResponsiveHelper.spacing(12)),

                    Text(
                      AppStrings.welcomeSubtitle1.tr,
                      style: context.titleSmall.copyWith(
                        color: AppColors.greyShade700,
                        fontSize: ResponsiveHelper.fontSize(14),
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              // --- GET STARTED + SIGN IN (pinned to bottom) ---------------
              Positioned(
                left: ResponsiveHelper.padding(24),
                right: ResponsiveHelper.padding(24),
                bottom: ResponsiveHelper.height(24),
                child: Column(
                  children: [
                    CustomGradientButton(
                      label: AppStrings.getStarted.tr,
                      onPressed: () {
                        context.pushNamed(RouteName.signUp);
                      },
                    ),
                    SizedBox(height: ResponsiveHelper.spacing(16)),
                    GestureDetector(
                      onTap: () => context.pushNamed(RouteName.signIn),
                      child: RichText(
                        text: TextSpan(
                          style: context.bodySmall.copyWith(
                            color: AppColors.grey.withOpacity(0.9),
                            fontSize: ResponsiveHelper.fontSize(13),
                          ),
                          children: [
                            TextSpan(text: '${AppStrings.alreadyHaveAccount.tr} '),
                            TextSpan(
                              text: AppStrings.signIn.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: ResponsiveHelper.fontSize(14),
                                color: AppColors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Each headline word on its own line; auto-shrinks so it never gets
  // clipped on narrow screens (e.g. "BREATHE.")
  Widget _headlineLine(String text) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.w400,
          fontSize: ResponsiveHelper.fontSize(48),
          height: 1.0,
          letterSpacing: 0,
          color: const Color(0xFF252729),
        ),
      ),
    );
  }
}

