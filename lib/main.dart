import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import 'package:platchatapp/feature/auth/repository/auth_controller.dart';
import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
import 'core/router/routes.dart';
import 'core/theme/light_theme.dart';
import 'helper/responsive_helper/responsive_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize controllers
  Get.put(AuthController());
  Get.put(ProfileController());





  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: lightTheme,
      routerConfig: AppRouter.router,
      builder: (context, widget) {
        // Initialize ResponsiveHelper here, called once per route
        ResponsiveHelper.init(context);
        return widget!;
      },
    );
  }
}