import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/route_path.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/auth/view/sign_in_screen.dart';
import 'package:platchatapp/feature/auth/view/sign_up_screen.dart';
import 'package:platchatapp/feature/chat/view/chat_list_screen.dart';
import 'package:platchatapp/feature/chat/view/inbox_screen.dart';
import '../../feature/splash/splash_screen.dart';
import '../../feature/auth/view/welcome_screen.dart';

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: RoutePath.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RoutePath.splash,
        name: RouteName.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePath.welcome,
        name: RouteName.welcome,
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RoutePath.signIn,
        name: RouteName.signIn,
        builder: (_, __) => SignInScreen(),
      ),
      GoRoute(
        path: RoutePath.signUp,
        name: RouteName.signUp,
        builder: (_, __) => const SignUpScreen(),
      ),
      GoRoute(
        path: RoutePath.chatList,
        name: RouteName.chatList,
        builder: (_, __) => const ChatListScreen(),
      ),
      GoRoute(
        path: RoutePath.inbox,
        name: RouteName.inbox,
        builder: (_, __) => const InboxScreen(),
      ),
    ],
  );
}
