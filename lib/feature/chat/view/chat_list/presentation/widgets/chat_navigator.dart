// widgets/chat_navigate_helper.dart
// ── দায়িত্ব: Room type (group/single) দেখে সঠিক screen এ navigate করে ──
//              Group হলে GroupMessageScreen, না হলে MessageScreen এ push করে

import 'package:flutter/material.dart';
import 'package:platchatapp/feature/chat/model/user_chat_model.dart';
import 'package:platchatapp/feature/chat/view/group_message/presentation/screens/group_message_screen.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/screens/message_screen.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';

/// Room এর type দেখে সঠিক chat screen এ navigate করে
void navigateToChat({
  required BuildContext context,
  required Rooms room,
}) {
  debugPrint('Navigating to room id: ${room.id}');

  if (room.isGroup) {
    // Group chat screen এ push
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupMessageScreen(
          roomId: room.id ?? '',
          groupName: room.displayName,
          groupImage: room.displayAvatar,
          groupMembers: room.groupMembers ?? [],
        ),
      ),
    );
  } else {
    // Single (1-to-1) chat screen এ push
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MessageScreen(
          roomId: room.id ?? '',
          otherUserName: room.displayName,
          // avatar না থাকলে unknown placeholder
          otherUserAvatar: room.displayAvatar.isNotEmpty
              ? room.displayAvatar
              : AppConst.unknown,
          receiverId: room.otherUser?.id ?? '',
          isBlockedByMe: room.isBlockedByMe,
          isBlockedMe: room.isBlockedMe,
        ),
      ),
    );
  }
}