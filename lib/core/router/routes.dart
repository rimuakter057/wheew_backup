import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/route_path.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/auth/view/reset_password_screen.dart';
import 'package:platchatapp/feature/auth/view/forgot_password_screen.dart';
import 'package:platchatapp/feature/auth/view/sign_in_screen.dart';
import 'package:platchatapp/feature/auth/view/sign_up_screen.dart';
import 'package:platchatapp/feature/terms_condition/terms_and_condition_screen.dart';
import 'package:platchatapp/feature/auth/view/otp_screen.dart';
import 'package:platchatapp/feature/chat/view/block_list_screen.dart';
import 'package:platchatapp/feature/chat/view/chat_list_screen.dart';
import 'package:platchatapp/feature/chat/view/inbox_screen.dart';
import 'package:platchatapp/feature/chat/view/message_screen.dart';
import 'package:platchatapp/feature/chat/view/serach_screen.dart';
import 'package:platchatapp/feature/profile/view/profile_screen.dart';
import '../../feature/splash/splash_screen.dart';
import '../../feature/auth/view/welcome_screen.dart';
import '../../feature/auth/repository/auth_controller.dart';

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: RoutePath.splash,
    debugLogDiagnostics: true,
    routes: [

     ///----------Auth-------

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
      /*GoRoute(
        path: RoutePath.signIn,
        name: RouteName.signIn,
        builder: (_, __) => SignInScreen(),
      ),*/
      GoRoute(
        path: RoutePath.signIn,
        name: RouteName.signIn,
        builder: (_, __) {
          Get.lazyPut<AuthController>(() => AuthController());
          return SignInScreen();
        },
      ),
     /* GoRoute(
        path: RoutePath.signUp,
        name: RouteName.signUp,
        builder: (_, __) => const SignUpScreen(),
      ),*/
      GoRoute(
        path: RoutePath.signUp,
        name: RouteName.signUp,
        builder: (_, __) {
          // 🔹 Inject controller when route is opened
          Get.lazyPut<AuthController>(() => AuthController());

          return const SignUpScreen();
        },
      ),
      GoRoute(
        path: RoutePath.terms,
        name: RouteName.terms,
        builder: (_, __) => const TermsAndConditionsScreen(),
      ),

      GoRoute(
        path: RoutePath.block,
        name: RouteName.block,
        builder: (_, __) => const BlockListScreen(),
      ),

      GoRoute(
        path: RoutePath.forgot_password,
        name: RouteName.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePath.otp,
        name: RouteName.otp,
        builder: (_, __) => const OtpScreen(),
      ),
      GoRoute(
        path: RoutePath.reset_password,
        name: RouteName.resetPassword,
        builder: (_, __) => ResetPasswordScreen(),
      ),

      ///----------All chat list-----------

      GoRoute(
        path: RoutePath.chatList,
        name: RouteName.chatList,
        builder: (_, __) => const ChatListScreen(),
      ),
      GoRoute(
        path: RoutePath.searchList,
        name: RouteName.searchList,
        builder: (_, __) => const SearchListScreen(),
      ),

      GoRoute(
        path: RoutePath.inbox,
        name: RouteName.inbox,
        builder: (_, __) => const InboxScreen(),
      ),
      GoRoute(
        path: RoutePath.message,
        name: RouteName.message,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;

          return MessageScreen(
            roomId: args['roomId']??'',
            otherUserName: args['otherUserName']??"",
            otherUserAvatar: args['otherUserAvatar']??'',
            receiverId: args['receiverId']??'',
            isBlockedByMe:args['isBlockedByMe']??'',
            isBlockedMe:args['isBlockedMe']??'',


          );
        },
      ),



      GoRoute(
        path: RoutePath.profile,
        name: RouteName.profile,
        builder: (_, __) => const ProfileScreen(),
      ),



    ],
  );
}
