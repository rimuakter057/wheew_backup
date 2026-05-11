import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import '../../core/router/routes_name.dart';
import '../../core/service/storage_service.dart';
import '../../helper/responsive_helper/responsive_helper.dart';
import '../../utils/app_const/app_const.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {




  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();
    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    final bool isLoggedIn =
        await SharePrefsHelper.getBool(AppConst.isLoggedIn) ?? false;

    if (isLoggedIn) {
      // Timeout fallback — socket 10s এর মধ্যে connect না হলে signin এ যাবে
      Future.delayed(const Duration(seconds: 10), () {
        if (!_isNavigated && mounted) {
          _isNavigated = true;
          context.goNamed(RouteName.welcome); // বা error screen
        }
      });

      await AppSocket.init(
        onSocketConnect: () {
          if (!_isNavigated && mounted) {
            _isNavigated = true;
           // context.goNamed(RouteName.chatList);
            context.goNamed(RouteName.mainNavScreen);
          }
        },
      );
    } else {
      if (!mounted) return;
      context.goNamed(RouteName.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: Lottie.asset(
            'assets/animations/logo2_animated.json',
            width: ResponsiveHelper.iconSize(320),
            height: ResponsiveHelper.iconSize(340),
            fit: BoxFit.contain,
            repeat: true,
          ),
        ),
      ),
    );
  }

  // void _showTimeoutMessage() {
  //   Get.snackbar(
  //     "Connection Timeout",
  //
  //     "Server is not responding. Please try again.",
  //
  //     snackPosition: SnackPosition.BOTTOM,
  //
  //     backgroundColor: Colors.red,
  //
  //     colorText: Colors.white,
  //
  //     duration: const Duration(seconds: 4),
  //   );
  // }
}
