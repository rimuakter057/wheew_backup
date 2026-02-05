import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/routes_name.dart';
import '../../core/service/storage_service.dart';
import '../../utils/assets_path/assets_path.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String name = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    // Wait for splash screen duration
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user is logged in
    final bool isLoggedIn = StorageService.isLoggedIn();

    if (isLoggedIn) {
      // User is logged in, go to chat list
      context.goNamed(RouteName.chatList);
    } else {
      // User is not logged in, go to welcome screen
      context.goNamed(RouteName.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Spacer(),
            SvgPicture.asset(
              AssetsPath.logoSvg,
              width: 240,
            ),
            const SizedBox(height: 12),
            const Text('CONNECTING DRIVERS ONE PLATE AT A TIME'),
            const Spacer(),
            const CircularProgressIndicator(), // Added loading indicator
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}