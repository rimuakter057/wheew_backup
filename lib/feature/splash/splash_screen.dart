import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import 'package:platchatapp/feature/helper/custom_image/custom_image.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import '../../core/router/routes_name.dart';
import '../../core/service/storage_service.dart';
import '../../helper/responsive_helper/responsive_helper.dart';
import '../../utils/app_const/app_const.dart';
import '../../utils/assets_path/assets_path.dart';

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
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final bool isLoggedIn =
        await SharePrefsHelper.getBool(AppConst.isLoggedIn) ?? false;

    if (isLoggedIn) {
      /// timeout fallback (10 sec)
      Future.delayed(const Duration(seconds: 30), () {
        if (!_isNavigated && mounted) {
          _showTimeoutMessage();
        }
      });

      await AppSocket.init(
        onSocketConnect: () {
          if (!_isNavigated && mounted) {
            _isNavigated = true;

            context.goNamed(RouteName.chatList);
          }
        },
      );
    } else {
      context.goNamed(RouteName.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomImage(
          imageSrc: AssetsPath.logoPng,
          width: ResponsiveHelper.width(280),
        ),
      ),
    );

    /*Scaffold(
      body: Center(
        child: Column(
          children: [
            const Spacer(),
            SvgPicture.asset(
              AssetsPath.logoSvg,
              width: ResponsiveHelper.width(240),
            ),
            SizedBox(height: ResponsiveHelper.spacing(12)),
            Text(
              'CONNECTING DRIVERS ONE PLATE AT A TIME',
              style: GoogleFonts.poppins(fontSize: ResponsiveHelper.fontSize(15),

              fontWeight: FontWeight.w400,
                color: AppColors.textBlack
              ),
            ),
            const Spacer(),
            const CircularProgressIndicator(),
            SizedBox(height: ResponsiveHelper.spacing(40)),
          ],
        ),
      ),
    )*/
    ;
  }

  void _showTimeoutMessage() {
    Get.snackbar(
      "Connection Timeout",

      "Server is not responding. Please try again.",

      snackPosition: SnackPosition.BOTTOM,

      backgroundColor: Colors.red,

      colorText: Colors.white,

      duration: const Duration(seconds: 4),
    );
  }
}
