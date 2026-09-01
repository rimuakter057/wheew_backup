import 'dart:ui';
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

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Stagger: fade first, then slide
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Hero background image with subtle living scale pulse ───────
          ScaleTransition(
            scale: _pulseAnim,
            child: Image.asset(
              AssetsPath.getStarted,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // ── 2. Cinematic gradient overlay (dark at bottom, clear at top) ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.30, 0.58, 1.0],
                colors: [
                  Color(0x00000000), // fully transparent at top
                  Color(0x22000000), // very subtle mid tint
                  Color(0xBB0A0E1A), // strong deep-navy shadow starts
                  Color(0xFF060A15), // near-black at bottom
                ],
              ),
            ),
          ),

          // ── 3. Subtle blue accent vignette on bottom-left ─────────────────
          Positioned(
            bottom: -size.height * 0.18,
            left: -size.width * 0.25,
            child: Container(
              width: size.width * 0.75,
              height: size.width * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0C7DC9).withOpacity(0.30),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── 4. All UI content ─────────────────────────────────────────────
          SafeArea(
            child: Stack(
              children: [
                // TOP ROW: Logo + Language Toggle
                Positioned(
                  top: ResponsiveHelper.height(16),
                  left: ResponsiveHelper.padding(20),
                  right: ResponsiveHelper.padding(20),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo with subtle frosted pill background
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.borderRadius(14),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveHelper.padding(8),
                                vertical: ResponsiveHelper.padding(4),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(
                                  ResponsiveHelper.borderRadius(14),
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.18),
                                  width: 1,
                                ),
                              ),
                              child: CustomImage(
                                imageSrc: AssetsPath.appLogoUpdate,
                                height: ResponsiveHelper.height(46),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const LanguageToggleWidget(),
                      ],
                    ),
                  ),
                ),

                // HEADLINE + SUBTITLE — lower-third of screen
                Positioned(
                  bottom: size.height * 0.22,
                  left: ResponsiveHelper.padding(26),
                  right: ResponsiveHelper.padding(26),
                  child: SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Thin blue accent bar above tagline
                          Container(
                            width: ResponsiveHelper.width(36),
                            height: 3,
                            margin: EdgeInsets.only(
                              bottom: ResponsiveHelper.spacing(14),
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF0C7DC9),
                                  Color(0xFF4AB3FF),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),

                          // Brand tagline — always English, never translated, so it
                          // matches the wordmark on the logo/splash regardless of
                          // the app language.
                          ..._kWelcomeHeadline
                              .split('\n')
                              .map((word) => _headlineLine(word)),

                          SizedBox(height: ResponsiveHelper.spacing(16)),

                          Text(
                            AppStrings.welcomeSubtitle1.tr,
                            style: context.titleSmall.copyWith(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: ResponsiveHelper.fontSize(13),
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),

                         // Frosted-glass subtitle pill
                         //  ClipRRect(
                         //    borderRadius: BorderRadius.circular(
                         //      ResponsiveHelper.borderRadius(12),
                         //    ),
                         //    child: BackdropFilter(
                         //      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                         //      child: Container(
                         //        padding: EdgeInsets.symmetric(
                         //          horizontal: ResponsiveHelper.padding(14),
                         //          vertical: ResponsiveHelper.padding(10),
                         //        ),
                         //        decoration: BoxDecoration(
                         //          color: Colors.white.withOpacity(0.08),
                         //          borderRadius: BorderRadius.circular(
                         //            ResponsiveHelper.borderRadius(12),
                         //          ),
                         //          border: Border.all(
                         //            color: Colors.white.withOpacity(0.14),
                         //            width: 1,
                         //          ),
                         //        ),
                         //        child: Row(
                         //          mainAxisSize: MainAxisSize.min,
                         //          children: [
                         //            Container(
                         //              width: 6,
                         //              height: 6,
                         //              decoration: const BoxDecoration(
                         //                shape: BoxShape.circle,
                         //                color: Color(0xFF4AB3FF),
                         //              ),
                         //            ),
                         //            SizedBox(width: ResponsiveHelper.width(8)),
                         //            Flexible(
                         //              child: Text(
                         //                AppStrings.welcomeSubtitle1.tr,
                         //                style: context.titleSmall.copyWith(
                         //                  color: Colors.white.withOpacity(0.85),
                         //                  fontSize: ResponsiveHelper.fontSize(13),
                         //                  fontWeight: FontWeight.w400,
                         //                  height: 1.4,
                         //                ),
                         //              ),
                         //            ),
                         //          ],
                         //        ),
                         //      ),
                         //    ),
                         //  ),
                        ],
                      ),
                    ),
                  ),
                ),

                // BOTTOM CTA: Get Started + Sign In
                Positioned(
                  left: ResponsiveHelper.padding(24),
                  right: ResponsiveHelper.padding(24),
                  bottom: ResponsiveHelper.height(28),
                  child: SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        children: [
                          CustomGradientButton(
                            label: AppStrings.getStarted.tr,
                            onPressed: () {
                              context.pushNamed(RouteName.signUp);
                            },
                          ),
                          SizedBox(height: ResponsiveHelper.spacing(18)),
                          GestureDetector(
                            onTap: () => context.pushNamed(RouteName.signIn),
                            child: RichText(
                              text: TextSpan(
                                style: context.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.60),
                                  fontSize: ResponsiveHelper.fontSize(13),
                                ),
                                children: [
                                  TextSpan(
                                    text: '${AppStrings.alreadyHaveAccount.tr} ',
                                  ),
                                  TextSpan(
                                    text: AppStrings.signIn.tr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: ResponsiveHelper.fontSize(14),
                                      color: const Color(0xFF4AB3FF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Each headline word on its own line; auto-shrinks so it never clips
  /// on narrow screens. Bold white with a subtle shadow for cinematic depth.
  Widget _headlineLine(String text) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.w400,
          fontSize: ResponsiveHelper.fontSize(42),
          height: 1.05,
          letterSpacing: -0.5,
          color: Colors.white,
          shadows: const [
            Shadow(
              color: Color(0x66000000),
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }
}

