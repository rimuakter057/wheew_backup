import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import '../../core/router/routes_name.dart';
import '../../core/service/storage_service.dart';
import '../../helper/responsive_helper/responsive_helper.dart';
import '../../share/widgets/custom_image/custom_image.dart';
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
      // Location permission is requested when the user enters the Home
      // screen; notification permission when entering the Chat List
      // screen — not eagerly here on a returning session.

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment:  CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  AssetsPath.wheewAnimationTwo,
                  width: ResponsiveHelper.iconSize(250),
                  height: ResponsiveHelper.iconSize(300),
                  fit: BoxFit.cover,
                  repeat: true,
                ),


                // Transform.translate(
                //   offset: const Offset(0, 10), // নিচে নামাতে positive value বাড়ান
                //   child: Image.asset(
                //     AssetsPath.chatList,
                //     height: ResponsiveHelper.iconSize(38),
                //     fit: BoxFit.contain,
                //   ),
                // ),
              ],
            ),

           // CustomImage(imageSrc:AssetsPath.appLogoUpdate)


          ],
        ),
      ),
    );
  }

}
