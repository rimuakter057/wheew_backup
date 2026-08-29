import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
// Kept for the commented-out in-app splash UI below.
// import 'package:lottie/lottie.dart';
import 'package:platchatapp/core/service/socket_service.dart';
// import 'package:platchatapp/utils/assets_path/assets_path.dart';
import '../../core/router/routes_name.dart';
import '../../core/service/storage_service.dart';
// import '../../helper/responsive_helper/responsive_helper.dart';
// import '../../share/widgets/custom_image/custom_image.dart';
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

  /// Drops the native splash and navigates in one step.
  ///
  /// Every exit from this screen goes through here so the splash is torn down
  /// exactly once, at the last possible moment — removing it any earlier would
  /// flash this deliberately-blank screen before the destination is ready.
  void _leaveSplash(String routeName) {
    if (_isNavigated || !mounted) return;
    _isNavigated = true;
    FlutterNativeSplash.remove();
    context.goNamed(routeName);
  }

  Future<void> _checkLoginAndNavigate() async {
    // Held the old in-app Lottie splash on screen long enough to be seen.
    // That UI is gone now, so this was pure dead wait before the login check.
    // await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    final bool isLoggedIn =
        await SharePrefsHelper.getBool(AppConst.isLoggedIn) ?? false;

    if (isLoggedIn) {
      // Location permission is requested when the user enters the Home
      // screen; notification permission when entering the Chat List
      // screen — not eagerly here on a returning session.

      // Timeout fallback — socket 10s এর মধ্যে connect না হলে signin এ যাবে
      Future.delayed(const Duration(seconds: 10), () {
        _leaveSplash(RouteName.welcome); // বা error screen
      });

      await AppSocket.init(
        onSocketConnect: () {
          // context.goNamed(RouteName.chatList);
          _leaveSplash(RouteName.mainNavScreen);
        },
      );
    } else {
      _leaveSplash(RouteName.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    // The native splash (flutter_native_splash) is still painted over this
    // route until _checkLoginAndNavigate calls FlutterNativeSplash.remove(),
    // so this screen deliberately draws nothing — rendering the old in-app
    // splash here is what produced the second, duplicate splash.
    return const SizedBox.shrink();

    // ── Previous in-app splash UI (kept for reference) ───────────────────
    // return Scaffold(
    //   body: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         Row(
    //           crossAxisAlignment:  CrossAxisAlignment.center,
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Lottie.asset(
    //               AssetsPath.wheewAnimationTwo,
    //               width: ResponsiveHelper.iconSize(250),
    //               height: ResponsiveHelper.iconSize(300),
    //               fit: BoxFit.cover,
    //               repeat: true,
    //             ),
    //
    //
    //             // Transform.translate(
    //             //   offset: const Offset(0, 10), // নিচে নামাতে positive value বাড়ান
    //             //   child: Image.asset(
    //             //     AssetsPath.chatList,
    //             //     height: ResponsiveHelper.iconSize(38),
    //             //     fit: BoxFit.contain,
    //             //   ),
    //             // ),
    //           ],
    //         ),
    //
    //        // CustomImage(imageSrc:AssetsPath.appLogoUpdate)
    //
    //
    //       ],
    //     ),
    //   ),
    // );
  }

}
