import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/routes_name.dart';
import '../../core/service/storage_service.dart';
import '../../utils/app_const/app_const.dart';
import '../../utils/assets_path/assets_path.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  //static const String name = '/';

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
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final bool isLoggedIn =
        await SharePrefsHelper.getBool(AppConst.isLoggedIn) ?? false;

    if (isLoggedIn) {
      context.goNamed(RouteName.chatList);
    } else {
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
            const CircularProgressIndicator(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}