import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/route_path.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/auth/view/delete_account_screen.dart';
import 'package:platchatapp/feature/auth/view/reset_password_screen.dart';
import 'package:platchatapp/feature/auth/view/forgot_password_screen.dart';
import 'package:platchatapp/feature/auth/view/sign_in_screen.dart';
import 'package:platchatapp/feature/auth/view/sign_up_screen.dart';
import 'package:platchatapp/feature/auth/view/vehicle_info_screen.dart';
import 'package:platchatapp/feature/chat/view/member/presentation/screens/add_member_screen.dart';
import 'package:platchatapp/feature/main/presentation/main_nav-screen.dart';
import 'package:platchatapp/feature/map/presentation/screens/map_screen.dart';
import 'package:platchatapp/feature/ocr/presentation/screens/ocr_screen.dart';
import 'package:platchatapp/feature/profile/view/screens/profile_nav_screen.dart';
import 'package:platchatapp/feature/profile/view/screens/show_profile_screen.dart';
import 'package:platchatapp/feature/useful_number/presentation/screens/useful_member_screen.dart';
import 'package:platchatapp/feature/scan/presentation/screens/scan_screen.dart';
import 'package:platchatapp/feature/auth/view/otp_screen.dart';
import 'package:platchatapp/feature/chat/view/block/block_list_screen.dart';
import 'package:platchatapp/feature/chat/view/chat_list/presentation/screens/chat_list_screen.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/screens/message_screen.dart';
import 'package:platchatapp/feature/search/presentation/screens/serach_screen.dart';
import 'package:platchatapp/feature/profile/view/screens/profile_screen.dart';
import '../../feature/chat/view/group/presentation/screens/group_member_screen.dart';
import '../../feature/chat/view/group/presentation/screens/group_message_screen.dart';
import '../../feature/splash/splash_screen.dart';
import '../../feature/auth/view/welcome_screen.dart';
import '../../feature/auth/repository/auth_controller.dart';
import '../../main.dart';

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
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePath.welcome,
        name: RouteName.welcome,
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RoutePath.signIn,
        name: RouteName.signIn,
        builder: (_, _) {
          Get.lazyPut<AuthController>(() => AuthController());
          return SignInScreen();
        },
      ),

      GoRoute(
        path: RoutePath.signUp,
        name: RouteName.signUp,
        builder: (_, _) {
          Get.lazyPut<AuthController>(() => AuthController());

          return const SignUpScreen();
        },
      ),

      // GoRoute(
      //   path: RoutePath.terms,
      //   name: RouteName.terms,
      //   builder: (_, _) => const TermsAndConditionsScreen(),
      // ),
      GoRoute(
        path: RoutePath.block,
        name: RouteName.block,
        builder: (_, _) => const BlockListScreen(),
      ),

      GoRoute(
        path: RoutePath.forgotPassword,
        name: RouteName.forgotPassword,
        builder: (context, state) {
          return ForgotPasswordScreen();
        },
      ),

      GoRoute(
        path: RoutePath.otp,
        name: RouteName.otp,
        builder: (context, state) {
          final email = state.extra as String? ?? '';

          debugPrint("Router email: $email");

          return OtpScreen(email: email);
        },
      ),
      GoRoute(
        path: RoutePath.resetPassword,
        name: RouteName.resetPassword,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final otpToken = extra["otpToken"] as String? ?? '';
          final email = extra["email"] as String? ?? '';

          return ResetPasswordScreen(otpToken: otpToken, email: email);
        },
      ),

      ///----------All chat list-----------
      GoRoute(
        path: RoutePath.chatList,
        name: RouteName.chatList,
        builder: (_, _) => const ChatListScreen(),
      ),
      GoRoute(
        path: RoutePath.searchList,
        name: RouteName.searchList,
        builder: (_, _) => const SearchListScreen(),
      ),

      GoRoute(
        path: RoutePath.delete,
        name: RouteName.delete,
        builder: (_, _) => const DeleteAccountScreen(),
      ),
      GoRoute(
        path: RoutePath.message,
        name: RouteName.message,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return MessageScreen(
            roomId: args['roomId'] ?? '',
            otherUserName: args['otherUserName'] ?? "",
            otherUserAvatar: args['otherUserAvatar'] ?? '',
            receiverId: args['receiverId'] ?? '',
            isBlockedByMe: args['isBlockedByMe'],
            isBlockedMe: args['isBlockedMe'],
            // ── নতুন দুটো ──
            voiceAutoSend: args['voiceAutoSend'] ?? false,
            voiceMessage: args['voiceMessage'],
          );
        },
      ),

      GoRoute(
        path: RoutePath.groupMessageScreen,
        name: RouteName.groupMessageScreen,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;

          return GroupMessageScreen(
            roomId: args['roomId'] ?? '',
            groupName: args['groupName'] ?? '',
            groupImage: args['groupImage'] ?? '',
            groupMembers: args['groupMembers'] ?? [],
          );
        },
      ),

      // GoRoute(
      //   path: RoutePath.message,
      //   name: RouteName.message,
      //   builder: (context, state) {
      //     final args = state.extra as Map<String, dynamic>;

      //     return MessageScreen(
      //       roomId: args['roomId'] ?? '',
      //       otherUserName: args['otherUserName'] ?? "",
      //       otherUserAvatar: args['otherUserAvatar'] ?? '',
      //       receiverId: args['receiverId'] ?? '',
      //       isBlockedByMe: args['isBlockedByMe'],
      //       isBlockedMe: args['isBlockedMe'],
      //     );
      //   },
      GoRoute(
        path: RoutePath.profile,
        name: RouteName.profile,
        builder: (_, _) => ProfileScreen(),
      ),
      GoRoute(
        path: RoutePath.help,
        name: RouteName.help,
        builder: (context, state) => ProfileScreen(),
      ),
      GoRoute(
        path: RoutePath.showProfile,
        name: RouteName.showProfile,
        builder: (context, state) {
          final image = state.extra as String;
          return ShowProfileImageScreen(image: image);
        },
      ),
      GoRoute(
        path: RoutePath.mapScreen,
        name: RouteName.mapScreen,
        builder: (context, state) {
          return MapScreen();
        },
      ),
      GoRoute(
        path: RoutePath.addMemberScreen,
        name: RouteName.addMemberScreen,
        builder: (context, state) {
          final groupId = state.extra as String; // ✅ String রাখুন
          return AddMemberScreen(groupRoomId: groupId);
        },
      ),
      GoRoute(
        path: RoutePath.groupMemberScreen,
        name: RouteName.groupMemberScreen,
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return GroupMemberScreen(
            roomId: extra['roomId'] ?? '',
            groupName: extra['groupName'] ?? '',
          );
        },
      ),

      GoRoute(
        path: RoutePath.mainNavScreen,
        name: RouteName.mainNavScreen,
        builder: (context, state) {
          return MainNavScreen();
        },
      ),

      GoRoute(
        path: RoutePath.scanScreen,
        name: RouteName.scanScreen,
        builder: (context, state) {
          return ScanScreen();
        },
      ),

      GoRoute(
        path: RoutePath.profileNavScreen,
        name: RouteName.profileNavScreen,
        builder: (context, state) {
          return ProfileNavScreen();
        },
      ),

      GoRoute(
        path: RoutePath.usefulMemberScreen,
        name: RouteName.usefulMemberScreen,
        builder: (context, state) {
          return UsefulMemberScreen();
        },
      ),


      GoRoute(
        path: RoutePath.ocrScanner,
        name: RouteName.ocrScanner,
        builder: (context, state) {
          return OcrScannerScreen(cameras: cameras,);
        },
      ),

      GoRoute(
        path: RoutePath.vehicle,
        name: RouteName.vehicle,
        builder: (context, state) {
          return VehicleInfoScreen();
        },
      ),
      
    ],
  );
}
