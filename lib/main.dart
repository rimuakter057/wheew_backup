import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

import 'package:platchatapp/core/router/routes.dart';
import 'package:platchatapp/core/service/notification_service.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import 'package:platchatapp/core/theme/light_theme.dart';
import 'package:platchatapp/firebase_options.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/language/language_controller.dart';
import 'package:platchatapp/utils/language/AppTranslations.dart';

import 'core/binding/app_binding.dart';

// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';

// ── Voice (নতুন 3 লাইন) ──
import 'voice/voice_handler.dart';
import 'voice/voice_action_router.dart';
import 'voice/intent_parser.dart';

late VoiceActionRouter _voiceRouter; // নতুন
List<CameraDescription> cameras = []; // ── OCR Camera ──

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // Hold the native splash on screen past the first frame, so the heavy
  // startup below (Firebase, cameras, socket, translations) happens behind it
  // instead of behind a second, in-app splash. SplashScreen calls
  // FlutterNativeSplash.remove() once it knows where to navigate.
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  cameras = await availableCameras(); // OCR Camera init

  final languageController = Get.put(LanguageController());
  await languageController.loadSavedLanguage();

  Get.addTranslations(AppTranslations().keys);

  await AppSocket.init(
    onSocketConnect: () {
      debugPrint('======= main Socket connected =======');
    },
  );

  AppBindings().dependencies();

  // Voice setup
  _voiceRouter = VoiceActionRouter(
    navigatorKey: AppRouter.navigatorKey,
  );

  VoiceHandler.initialize(
    onIntent: (ParsedIntent intent) =>
        _voiceRouter.route(intent),
  );

  runApp(const Wheew());
}

class Wheew extends StatelessWidget {
  const Wheew({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();


    ResponsiveHelper.init(context);
    return Obx(
      () => MaterialApp.router(


        debugShowCheckedModeBanner: false,
        title: 'Wheew',
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


