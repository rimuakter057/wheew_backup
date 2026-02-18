import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final FontWeight fontWeight;
   final bool? isBlock;
   final void Function()?onUnblock;
  const ChatTile({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    this.imagePath,
    required this.onTap,
    required this.fontWeight,
    this.isBlock,
    this.onUnblock
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.questrial(
          fontSize: ResponsiveHelper.fontSize(14),
          fontWeight: fontWeight,
          color: AppColors.messageSubtitle,
        ),
      ),
      trailing:

      isBlock==true?
      GestureDetector(
        onTap: onUnblock,
        child: Container(
padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.padding(8),



vertical: ResponsiveHelper.padding(8)
),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            
            borderRadius: BorderRadius.circular(5)

          ),

          child:  Text("unblock".tr,style:GoogleFonts.poppins(
              fontSize: ResponsiveHelper.fontSize(16),
              fontWeight: FontWeight.w500,
            color: AppColors.blue
          ),),

        ),
      )

      :Text(
        time,
        style: GoogleFonts.questrial(
          color: AppColors.messageSubtitle,
          fontSize: ResponsiveHelper.fontSize(12),

        ),
      ),
    );
  }
}
