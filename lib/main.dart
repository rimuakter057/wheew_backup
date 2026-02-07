import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/feature/auth/repository/auth_controller.dart';
import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
import 'package:platchatapp/utils/string/AppTranslations.dart';
import 'core/router/routes.dart';
import 'core/theme/light_theme.dart';
import 'helper/responsive_helper/responsive_helper.dart';
import 'language/language_controller.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(AuthController());
  Get.put(ProfileController());
  Get.put(LanguageController());

  // ✅ Register translations once
  Get.addTranslations(AppTranslations().keys);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();

    return Obx(() => MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: lightTheme,

      // ✅ GoRouter
      routerConfig: AppRouter.router,

      // ✅ GetX locale (reactive)
      locale: languageController.currentLocale.value,

      supportedLocales: [
        Locale('en', 'US'),
        Locale('it', 'IT'),
      ],

      // ✅ CORRECT localization delegates
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      builder: (context, widget) {
        ResponsiveHelper.init(context);
        return widget!;
      },
    ));
  }
}
