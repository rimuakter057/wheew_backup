import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/router/routes.dart';
import '../../../core/router/routes_name.dart';
import '../../../utils/assets_path.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        // Full screen gradient background
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFC9FFBF), Colors.white],
          ),
        ),
        child: Column(
          children: [
            // TOP SECTION (Avatars) - Using percentage-based positioning
            SizedBox(
              height: size.height * 0.45,
              width: double.infinity,
              child: Stack(
                children: [
                  _avatar(
                    AssetsPath.person1,
                    topPercent: 0.22,
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
                    topPercent: 0.34,
                    rightPercent: 0.15,
                    radius: 35,
                    size: size,
                  ),
                  _avatar(
                    AssetsPath.person3,
                    topPercent: 0.11,
                    rightPercent: 0.45,
                    radius: 28,
                    size: size,
                  ),
                  _avatar(
                    AssetsPath.person4,
                    topPercent: 0.35,
                    leftPercent: 0.16,
                    radius: 45,
                    size: size,
                  ),
                  _avatar(
                    AssetsPath.person5,
                    topPercent: 0.25,
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

            const SizedBox(height: 24),

            // LOTTIE ANIMATION
            SizedBox(
              width: 80,
              height: 80,
              child: Lottie.asset(AssetsPath.chatJson, fit: BoxFit.contain),
            ),

            //const SizedBox(height: 8),

            // TITLE
            const Text(
              "Easy Chat With\nyour friends",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // SUBTITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "Keep up with your friends and makes your chat more enjoyable by signing quickly and easily",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: const BorderSide(color: Colors.blue),
                ),
                child: const Text(
                  "Language",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 8),

            // LOGIN BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OutlinedButton(
                onPressed: () {
                  AppRouter.router.pushNamed(RouteName.signIn);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: const BorderSide(color: Colors.blue),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // SIGN UP BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text("Sign Up"),
              ),
            ),

            const SizedBox(height: 24),
          ],
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
