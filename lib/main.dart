import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:platchatapp/feature/auth/repository/auth_controller.dart';
import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
import 'core/router/routes.dart';
import 'core/service/storage_service.dart';
import 'core/theme/light_theme.dart';
import 'helper/responsive_helper/responsive_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await GetStorage.init();

  // Initialize controllers
  Get.put(AuthController());
  Get.put(ProfileController());

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        ResponsiveHelper.init(context);

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'My App',
          theme: lightTheme,
          routerConfig: AppRouter.router,
          builder: (context, widget) {
            return widget!;
          },
        );
      },
    );
  }
}