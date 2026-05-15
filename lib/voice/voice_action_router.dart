// lib/voice/voice_action_router.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'intent_parser.dart';

class VoiceActionRouter {
  final GlobalKey<NavigatorState> navigatorKey;

  VoiceActionRouter({required this.navigatorKey});

  BuildContext? get _context => navigatorKey.currentContext;

  Future<void> route(ParsedIntent intent) async {
    if (!intent.isValid) {
      debugPrint('[Voice] Unknown intent: ${intent.rawInput}');
      return;
    }

    debugPrint(
      '[Voice] action:${intent.action} user:${intent.targetUser} msg:${intent.message}',
    );

    switch (intent.action) {
      case VoiceAction.openApp:
        _openApp();

      case VoiceAction.openChat:
        if (intent.targetUser != null) {
          await _openOrSendChat(
            userName: intent.targetUser!,
            autoSend: false,
            message: null,
          );
        }

      case VoiceAction.sendMessage:
        if (intent.targetUser != null) {
          await _openOrSendChat(
            userName: intent.targetUser!,
            autoSend: true,
            message: intent.message ?? 'Hello',
          );
        }

      case VoiceAction.findUser:
        if (intent.targetUser != null) {
          _goToSearch();
        }

      case VoiceAction.unknown:
        break;
    }
  }

  void _openApp() {
    _context?.goNamed(RouteName.chatList);
  }

  Future<void> _openOrSendChat({
    required String userName,
    required bool autoSend,
    String? message,
  }) async {
    final ctx = _context;
    if (ctx == null) return;

    final chatController = Get.find<ChatController>();

    // ── Direct search — debounce নেই, result সাথে সাথে আসবে ──
    final results = await chatController.searchUsersForVoice(userName);

    debugPrint('[Voice] Search "$userName" → ${results.length} results');

    if (results.isEmpty) {
      debugPrint('[Voice] User not found → going to search screen');
      _goToSearch();
      return;
    }

    // Case-insensitive exact match আগে, না পেলে first result
    final matched = results.firstWhere(
      (u) => (u.nickName ?? '').toLowerCase() == userName.toLowerCase(),
      orElse: () => results.firstWhere(
        (u) =>
            (u.nickName ?? '').toLowerCase().contains(userName.toLowerCase()),
        orElse: () => results.first,
      ),
    );

    debugPrint('[Voice] Matched user: ${matched.nickName} (id: ${matched.id})');

    final ctx2 = _context;
    if (ctx2 == null || !ctx2.mounted) return;

    ctx2.pushNamed(
      RouteName.message,
      extra: {
        'roomId': matched.existingRoom?.id ?? '',
        'otherUserName': matched.nickName ?? userName,
        'otherUserAvatar': matched.avatar ?? AppConst.unknown,
        'receiverId': matched.id ?? '',
        'isBlockedByMe': false,
        'isBlockedMe': false,
        'voiceAutoSend': autoSend,
        'voiceMessage': message,
      },
    );
  }

  void _goToSearch() {
    _context?.pushNamed(RouteName.searchList);
  }
}

// // lib/voice/voice_action_router.dart

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'package:platchatapp/core/router/routes_name.dart';
// import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
// import 'package:platchatapp/utils/app_const/app_const.dart';
// import 'intent_parser.dart';

// class VoiceActionRouter {
//   final GlobalKey<NavigatorState> navigatorKey;

//   VoiceActionRouter({required this.navigatorKey});

//   BuildContext? get _context => navigatorKey.currentContext;

//   Future<void> route(ParsedIntent intent) async {
//     if (!intent.isValid) {
//       debugPrint('[Voice] Unknown intent: ${intent.rawInput}');
//       return;
//     }

//     debugPrint(
//       '[Voice] Routing → action:${intent.action} user:${intent.targetUser} msg:${intent.message}',
//     );

//     switch (intent.action) {
//       case VoiceAction.openApp:
//         _openApp();

//       case VoiceAction.openChat:
//         if (intent.targetUser != null) {
//           await _openOrSendChat(
//             userName: intent.targetUser!,
//             autoSend: false,
//             message: null,
//           );
//         }

//       case VoiceAction.sendMessage:
//         if (intent.targetUser != null) {
//           await _openOrSendChat(
//             userName: intent.targetUser!,
//             autoSend: true,
//             message: intent.message ?? 'Hello',
//           );
//         }

//       case VoiceAction.findUser:
//         if (intent.targetUser != null) {
//           _goToSearch(intent.targetUser!);
//         }

//       case VoiceAction.unknown:
//         break;
//     }
//   }

//   // ── App open → chatList এ নিয়ে যাও ──
//   void _openApp() {
//     final ctx = _context;
//     if (ctx == null) return;
//     ctx.goNamed(RouteName.chatList);
//   }

//   // ── User খুঁজে chat open করো, দরকার হলে message auto send করো ──
//   Future<void> _openOrSendChat({
//     required String userName,
//     required bool autoSend,
//     String? message,
//   }) async {
//     final ctx = _context;
//     if (ctx == null) return;

//     // ChatController already GetX এ আছে
//     final chatController = Get.find<ChatController>();

//     // তোমার existing searchUsers API use করছি
//     chatController.searchUsers(userName);

//     // Debounce শেষ হওয়ার জন্য একটু অপেক্ষা করো
//     await Future.delayed(const Duration(milliseconds: 700));

//     // Search results থেকে প্রথম match নাও
//     final results = chatController.searchResults;

//     if (results.isEmpty) {
//       // User না পেলে search screen এ নিয়ে যাও
//       debugPrint('[Voice] User "$userName" not found, going to search');
//       _goToSearch(userName);
//       return;
//     }

//     // Case-insensitive name match
//     final matched = results.firstWhere(
//       (u) => (u.nickName ?? '').toLowerCase().contains(userName.toLowerCase()),
//       orElse: () => results.first,
//     );

//     final ctx2 = _context; // context আবার check করো (async gap এর পরে)
//     if (ctx2 == null || !ctx2.mounted) return;

//     ctx2.pushNamed(
//       RouteName.message,
//       extra: {
//         'roomId': matched.existingRoom?.id ?? '',
//         'otherUserName': matched.nickName ?? userName,
//         'otherUserAvatar': matched.avatar ?? AppConst.unknown,
//         'receiverId': matched.id ?? '',
//         'isBlockedByMe': false,
//         'isBlockedMe': false,
//         // Voice auto-send এর জন্য নতুন দুটো field
//         'voiceAutoSend': autoSend,
//         'voiceMessage': message,
//       },
//     );
//   }

//   // ── Search screen এ যাও ──
//   void _goToSearch(String query) {
//     final ctx = _context;
//     if (ctx == null) return;
//     // SearchListScreen এ auto-focus আছে, query pre-fill করা যাবে না
//     // কারণ SearchListScreen এ external query parameter নেই
//     // তাই শুধু screen এ নিয়ে যাচ্ছি
//     ctx.pushNamed(RouteName.searchList);
//   }
// }
