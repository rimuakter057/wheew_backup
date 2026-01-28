import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/feature/auth/view/welcome_screen.dart';
import '../../core/router/routes.dart';
import '../../core/router/routes_name.dart';
import '../../utils/assets_path.dart';


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
    _moveToNextScreen();
  }

  Future<void> _moveToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    //context.pushNamed(RouteName.welcome);
    //AppRouter.router.go('/home');
    AppRouter.router.pushNamed(RouteName.welcome);

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Spacer(),
            SvgPicture.asset(AssetsPath.logoSvg,width: 240,),
            SizedBox(height: 12,),
            Text('CONNECTING DRIVERS ONE PLATE AT A TIME'),
            Spacer(),
          ],
        ),
      ),
    );
  }
}