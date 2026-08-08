
import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class ScannedUserSheet extends StatelessWidget {
  final Map<String, dynamic> data;

  const ScannedUserSheet({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final user = data['user'] as Map<String, dynamic>;
    final bool isExistingChat =
        data['isExistingChat'] == true ||
            data['hasChat'] == true ||
            (data['roomId']?.toString().isNotEmpty ?? false) ||
            (data['existingRoomId']?.toString().isNotEmpty ?? false);
    final String roomId =
        data['roomId']?.toString() ??
            data['existingRoomId']?.toString() ??
            '';

    final String userId = user['id'] ?? '';
    final String nickName = user['nick_name'] ?? '';
    final String avatar = user['avatar'] ?? '';
    final num rating = user['rating'] ?? 0;

    final double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      // â”€â”€ à¦ à¦¿à¦• à¦¸à§à¦•à§à¦°à¦¿à¦¨à§‡à¦° à¦…à¦°à§à¦§à§‡à¦• à¦¹à¦¾à¦‡à¦Ÿ (fixed, full screen à¦¨à¦¾ à¦¹à¦¯à¦¼à§‡)
      height: screenHeight * 0.5,
      child: Container(
        width: double.infinity,
        // â”€â”€ à¦¬à§‡à¦¶à¦¿ à¦ªà§à¦¯à¦¾à¦¡à¦¿à¦‚ à¦¸à¦¬à¦¦à¦¿à¦•à§‡, à¦¨à¦¿à¦šà§‡ à¦¸à§‡à¦‡à¦« à¦à¦°à¦¿à¦¯à¦¼à¦¾ à¦¯à§‹à¦— à¦•à¦°à§‡ à¦¯à¦¾à¦¤à§‡ à¦¬à¦¾à¦Ÿà¦¨ à¦à¦œà§‡ à¦¨à¦¾ à¦²à¦¾à¦—à§‡
        padding: EdgeInsets.fromLTRB(
          ResponsiveHelper.padding(24),
          ResponsiveHelper.padding(12),
          ResponsiveHelper.padding(24),
          ResponsiveHelper.padding(36) + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ResponsiveHelper.borderRadius(28)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // â”€â”€ Handle bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(12)),

            // â”€â”€ Close button (top-right, à¦ªà§à¦°à§‹à¦ªà§à¦°à¦¿ à¦­à¦¿à¦œà¦¿à¦¬à¦²) â”€â”€
            Row(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(ResponsiveHelper.padding(8)),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F2F2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: ResponsiveHelper.iconSize(20),
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),

            // â”€â”€ à¦¬à¦¾à¦•à¦¿ à¦•à¦¨à¦Ÿà§‡à¦¨à§à¦Ÿ à¦®à¦¾à¦à¦–à¦¾à¦¨à§‡ â”€â”€
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // â”€â”€ Avatar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  CircleAvatar(
                    radius: ResponsiveHelper.borderRadius(44),
                    backgroundImage: NetworkImage(
                      ImageHandler.imagesHandle(avatar, isProfile: true),
                    ),
                    backgroundColor: AppColors.greyShade,
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(18)),

                  // â”€â”€ Name â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  Text(
                    nickName,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(20),
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(8)),

                  // â”€â”€ Rating â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_rounded, color: AppColors.amber, size: ResponsiveHelper.iconSize(20)),
                      SizedBox(width: ResponsiveHelper.width(4)),
                      Text(
                        rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveHelper.fontSize(15),
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: ResponsiveHelper.spacing(20)),

            // â”€â”€ Buttons â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if (isExistingChat)
              _SheetButton(
                label: AppStrings.openChat.tr,
                icon: Icons.chat_bubble_outline_rounded,
                color: AppColors.blue,
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed(
                    RouteName.message,
                    extra: {
                      'roomId': roomId,
                      'otherUserName': nickName,
                      'otherUserAvatar':
                      avatar.isNotEmpty ? avatar : AppConst.unknown,
                      'receiverId': userId,
                      'isBlockedByMe': false,
                      'isBlockedMe': false,
                    },
                  );
                },
              )
            else
              _SheetButton(
                label: AppStrings.startChat.tr,
                icon: Icons.chat_bubble_outline_rounded,
                color: AppColors.blue,
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed(
                    RouteName.message,
                    extra: {
                      'roomId': '',
                      'otherUserName': nickName,
                      'otherUserAvatar':
                      avatar.isNotEmpty ? avatar : AppConst.unknown,
                      'receiverId': userId,
                      'licenceId': user['licence_id']?.toString() ?? '',
                      'isBlockedByMe': false,
                      'isBlockedMe': false,
                      'isSendRequest': true,
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// â”€â”€â”€ Sheet Button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SheetButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color? textColor;
  final VoidCallback onTap;

  const _SheetButton({
    required this.label,
    required this.icon,
    required this.color,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.padding(16),
          horizontal: ResponsiveHelper.padding(20),
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor ?? AppColors.white, size: 20),
            SizedBox(width: ResponsiveHelper.spacing(8)),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(16),
                fontWeight: FontWeight.w600,
                color: textColor ?? AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}









