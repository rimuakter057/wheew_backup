import 'package:flutter/material.dart';
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
      leading: UserAvatar(imagePath: imagePath),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: ResponsiveHelper.fontSize(16),
        ),
      ),
      subtitle: Text(
        message,
        style: TextStyle(
          fontSize: ResponsiveHelper.fontSize(14),
        ),
      ),
      trailing: Text(
        time,
        style: TextStyle(
          color: Colors.grey,
          fontSize: ResponsiveHelper.fontSize(12),
        ),
      ),
    );
  }
}