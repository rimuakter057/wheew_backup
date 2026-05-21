// widgets/group_message_bubble.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:platchatapp/feature/chat/model/group_message_response_model.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class GroupMessageBubble extends StatelessWidget {
  final GroupMessageResponseModel msg;
  final bool isMine;
  final String senderName;
  final String senderAvatar;
  final String text;
  final String time;

  const GroupMessageBubble({
    super.key,
    required this.msg,
    required this.isMine,
    required this.senderName,
    required this.senderAvatar,
    required this.text,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
        isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // ── Other user: avatar + name + bubble ──────────
          if (!isMine)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: ResponsiveHelper.iconSize(16),
                  backgroundImage: senderAvatar.isNotEmpty
                      ? NetworkImage(
                    ImageHandler.imagesHandle(
                      senderAvatar,
                      isProfile: true,
                    ),
                  )
                      : null,
                  backgroundColor: AppColors.blue.withOpacity(0.2),
                  child: senderAvatar.isEmpty
                      ? Icon(
                    Icons.person,
                    size: ResponsiveHelper.iconSize(16),
                    color: AppColors.blue,
                  )
                      : null,
                ),
                SizedBox(width: ResponsiveHelper.width(6)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: ResponsiveHelper.width(4),
                        bottom: ResponsiveHelper.height(2),
                      ),
                      child: Text(
                        senderName,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveHelper.fontSize(11),
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _Bubble(text: text, isMine: isMine, time: time),
                  ],
                ),
              ],
            ),

          // ── My message ───────────────────────────────────
          if (isMine) _Bubble(text: text, isMine: isMine, time: time),
        ],
      ),
    );
  }
}

// ── Internal bubble shape ─────────────────────────────────────
class _Bubble extends StatelessWidget {
  final String text;
  final bool isMine;
  final String time;

  const _Bubble({
    required this.text,
    required this.isMine,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: ResponsiveHelper.width(272)),
      margin: EdgeInsets.symmetric(vertical: ResponsiveHelper.height(2)),
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.height(10),
        horizontal: ResponsiveHelper.width(14),
      ),
      decoration: BoxDecoration(
        color: isMine ? AppColors.blue : AppColors.greenClient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ResponsiveHelper.borderRadius(15)),
          topRight: Radius.circular(ResponsiveHelper.borderRadius(15)),
          bottomLeft: isMine
              ? Radius.circular(ResponsiveHelper.borderRadius(15))
              : Radius.zero,
          bottomRight: isMine
              ? Radius.zero
              : Radius.circular(ResponsiveHelper.borderRadius(15)),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: GoogleFonts.poppins(color: AppColors.white),
          ),
          SizedBox(height: ResponsiveHelper.height(4)),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveHelper.fontSize(10),
              color: AppColors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}