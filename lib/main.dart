import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:platchatapp/core/router/routes.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import 'package:platchatapp/core/theme/light_theme.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/language/language_controller.dart';
import 'package:platchatapp/utils/string/AppTranslations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/binding/app_binding.dart';
import 'firebase_options.dart';

///android key one signal



//2b118f3e-5d8f-436d-b63d-92273ec51793

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final languageController = Get.put(LanguageController());
  await languageController.loadSavedLanguage();

  if (defaultTargetPlatform == TargetPlatform.android) {
    final GoogleMapsFlutterAndroid mapsAndroid = GoogleMapsFlutterAndroid();
    mapsAndroid.useAndroidViewSurface = false;
  }

  // ✅ Controllers এখন AppBindings এ — এখানে আর লাগবে না
  AppBindings().dependencies();

  Get.addTranslations(AppTranslations().keys);

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
    return Obx(
          () => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'My App',
        theme: lightTheme,
        routerConfig: AppRouter.router,
        locale: languageController.currentLocale.value,
        supportedLocales: const [Locale('it', 'IT'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}