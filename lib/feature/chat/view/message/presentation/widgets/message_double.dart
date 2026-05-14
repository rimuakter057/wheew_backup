// widgets/message_bubble.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMine;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
      isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveHelper.width(272),
        ),
        margin: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.height(5),
        ),
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.height(10),
          horizontal: ResponsiveHelper.width(14),
        ),
        decoration: BoxDecoration(
          color: isMine ? AppColors.blueClient : AppColors.greenClient,
          borderRadius: BorderRadius.only(
            topLeft:
            Radius.circular(ResponsiveHelper.borderRadius(15)),
            topRight:
            Radius.circular(ResponsiveHelper.borderRadius(15)),
            bottomLeft: isMine
                ? Radius.circular(ResponsiveHelper.borderRadius(15))
                : Radius.zero,
            bottomRight: isMine
                ? Radius.zero
                : Radius.circular(ResponsiveHelper.borderRadius(15)),
          ),
        ),
        child: Text(
          message,
          style: GoogleFonts.poppins(color: AppColors.white),
        ),
      ),
    );
  }
}