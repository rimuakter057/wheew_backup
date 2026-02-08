import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../share/widgets/avatar/user_avatar.dart';

class ChatTile extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final String? imagePath;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: UserAvatar(
          imagePath: imagePath
      ),
      title: Text(
        name,
        style: GoogleFonts.questrial(
          fontSize: ResponsiveHelper.fontSize(16),
          fontWeight: FontWeight.w600,
          color: AppColors.messageSubtitle,
        ),
      ),
      subtitle: Text(
        message,
        style: GoogleFonts.questrial(
          fontSize: ResponsiveHelper.fontSize(14),
          fontWeight: FontWeight.w400,
          color: AppColors.messageSubtitle,
        ),
      ),
      trailing: Text(
        time,
        style: GoogleFonts.questrial(
          color: AppColors.messageSubtitle,
          fontSize: ResponsiveHelper.fontSize(12),
        ),
      ),
    );
  }
}
