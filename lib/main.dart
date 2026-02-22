
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import 'package:platchatapp/feature/auth/repository/auth_controller.dart';
import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
import 'package:platchatapp/utils/string/AppTranslations.dart';
import 'core/router/routes.dart';
import 'core/theme/light_theme.dart';
import 'feature/chat/repository/chat_controller.dart';
import 'helper/responsive_helper/responsive_helper.dart';
import 'language/language_controller.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // 🔥 Language controller MUST be awaited
  final languageController = Get.put(LanguageController());
  await languageController.loadSavedLanguage();


  // Controllers
  Get.put(AuthController());
  Get.put(ChatController());
  Get.put(ProfileController());


  // Translations
  Get.addTranslations(AppTranslations().keys);

  // Socket init
  await AppSocket.init(
    onSocketConnect: () {
      debugPrint(
        '=============================== main Socket successfully connected =================',
      );
    },
  );

  runApp(const App());
}
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    ResponsiveHelper.init(context);
    return Obx(() => MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'My App',

      // ✅ LIGHT THEME IS STILL HERE
      theme: lightTheme,

      routerConfig: AppRouter.router,

      locale: languageController.currentLocale.value,

      supportedLocales: const [
        Locale('it', 'IT'),
        Locale('en', 'US'),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    ));
  }
}
