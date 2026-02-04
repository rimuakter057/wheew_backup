import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get_storage/get_storage.dart';
import 'package:platchatapp/share/controller/profile_controller.dart';
import 'core/router/routes.dart';
import 'core/theme/light_theme.dart';
import 'helper/responsive_helper/responsive_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(ProfileController());

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // your design size
      minTextAdapt: true,               // important to fix _minTextAdapt
      splitScreenMode: true,            // optional
      builder: (context, child) {
        // Initialize ResponsiveHelper here AFTER ScreenUtil
        ResponsiveHelper.init(context);

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'My App',
          theme: lightTheme,
          routerConfig: AppRouter.router,
          builder: (context, widget) {
            // Ensure ResponsiveHelper is applied globally
            return widget!;
          },
        );
      },
    );
  }
}