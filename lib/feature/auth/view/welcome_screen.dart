import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../core/router/routes_name.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../share/widgets/button/outline_button.dart';
import '../../../share/widgets/button/primary_button.dart';
import '../../../share/widgets/button/toggle_button.dart';
import '../../../utils/assets_path/assets_path.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          // TOP SECTION (Avatars) - Using percentage-based positioning
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
                  Color(0xFFF5F7FA),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
            child: Stack(
              children: [
                _avatar(
                  AssetsPath.person1,
                  topPercent: 0.20,
                  leftPercent: 0.45,
                  radius: ResponsiveHelper.width(40),
                  size: size,
                ),
                _avatar(
                  AssetsPath.person2,
                  topPercent: 0.09,
                  leftPercent: 0.10,
                  radius: ResponsiveHelper.width(35),
                  size: size,
                ),
                _avatar(
                  AssetsPath.person2,
                  topPercent: 0.30,
                  rightPercent: 0.15,
                  radius: ResponsiveHelper.width(35),
                  size: size,
                ),
                _avatar(
                  AssetsPath.person3,
                  topPercent: 0.11,
                  rightPercent: 0.45,
                  radius: ResponsiveHelper.width(28),
                  size: size,
                ),
                _avatar(
                  AssetsPath.person4,
                  topPercent: 0.30,
                  leftPercent: 0.16,
                  radius: ResponsiveHelper.width(45),
                  size: size,
                ),
                _avatar(
                  AssetsPath.person5,
                  topPercent: 0.20,
                  leftPercent: 0.16,
                  radius: ResponsiveHelper.width(30),
                  size: size,
                ),
                _avatar(
                  AssetsPath.person6,
                  topPercent: 0.10,
                  rightPercent: 0.08,
                  radius: ResponsiveHelper.width(30),
                  size: size,
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveHelper.spacing(24)),

          // LOTTIE ANIMATION
          SizedBox(
            width: ResponsiveHelper.width(80),
            height: ResponsiveHelper.height(80),
            child: Lottie.asset(AssetsPath.chatJson, fit: BoxFit.contain),
          ),

          // TITLE
          Text(
            "Easy Chat With\nyour friends",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveHelper.titleFontSize(28),
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: ResponsiveHelper.spacing(12)),

          /// LANGUAGE BUTTON
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.padding(24),
            ),
            child: const LanguageToggleWidget(),
          ),

          SizedBox(height: ResponsiveHelper.spacing(8)),

          // LOGIN BUTTON
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.padding(24),
            ),
            child: OutlineButton(
              title: "Log In",
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
              title: "Sign Up",
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
