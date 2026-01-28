import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/route_path.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/auth/view/sign_in_screen.dart';
import 'package:platchatapp/feature/auth/view/welcome_screen.dart';
import '../../feature/splash/splash_screen.dart';

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: RoutePath.splash,
    debugLogDiagnostics: true,

    //redirect: AuthGuard.redirect,
    routes: [
      GoRoute(
        path: RoutePath.splash,
        name: RouteName.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePath.welcome,
        name: RouteName.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RoutePath.signIn,
        name: RouteName.signIn,
        builder: (context, state) => const SignInScreen(),
      ),




    ],
  );
}
