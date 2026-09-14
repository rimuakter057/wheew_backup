import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/feature/chat/view/message/controller/message_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/avatar/user_avatar.dart';
import 'package:platchatapp/share/widgets/dialog/action_confirm_dialog.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';

/// Single pending-incoming-request row — Receive Requests screen and the
/// chat list (when a room's type is MESSAGE_REQUEST) both render the exact
/// same tile so a request looks identical everywhere it shows up.
class MessageRequestTile extends StatelessWidget {
  final String requestId;
  final String name;
  final String avatar;
  final String? licenceId;
  final String? firstMessage;
  final String roomId;
  final String receiverId;

  /// Called after the request is successfully accepted/rejected — lets a
  /// caller with its own list (e.g. the chat list) refresh accordingly.
  final VoidCallback? onHandled;

  const MessageRequestTile({
    super.key,
    required this.requestId,
    required this.name,
    required this.avatar,
    this.licenceId,
    this.firstMessage,
    this.roomId = '',
    this.receiverId = '',
    this.onHandled,
  });

  @override
  Widget build(BuildContext context) {
    final messageController = Get.find<MessageController>();
    final message = firstMessage ?? '';

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          RouteName.message,
          extra: {
            'roomId': roomId,
            'otherUserName': name,
            'otherUserAvatar': avatar,
            'receiverId': receiverId,
            'firstMessage': message,
            'requestId': requestId,
            'licenceId': licenceId ?? '',
            'isReceivedRequest': true,
          },
        );
      },
      child: Container(
        padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.parkingContainerGradient,
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(24)),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            UserAvatar(
              imagePath: avatar.isNotEmpty ? avatar : AppConst.unknown,
              radius: 24,
            ),
            SizedBox(width: ResponsiveHelper.spacing(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: ResponsiveHelper.fontSize(15),
                      color: const Color(0xFF1D2939),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(2)),
                  if (licenceId != null && licenceId!.isNotEmpty)
                    Text(
                      licenceId!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(12),
                        color: AppColors.greyShade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (message.isNotEmpty) ...[
                    SizedBox(height: ResponsiveHelper.spacing(4)),
                    Text(
                      message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(12),
                        color: AppColors.greyShade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: ResponsiveHelper.spacing(8)),
            // Reject (red X button)
            GestureDetector(
              onTap: () {
                ActionConfirmDialog.show(
                  context,
                  title: AppStrings.rejectRequestTitle.tr,
                  message: AppStrings.rejectRequestFrom.tr.replaceAll('@name', name),
                  confirmLabel: AppStrings.reject.tr,
                  icon: Icons.cancel_outlined,
                  iconColor: const Color(0xFFB02517),
                  confirmGradient: const LinearGradient(
                    colors: [Color(0xFFB02517), Color(0xFF7A1C15)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  onConfirm: () async {
                    await messageController.rejectMessageRequest(
                      requestId: requestId,
                      context: context,
                    );
                    onHandled?.call();
                  },
                );
              },
              child: Container(
                width: ResponsiveHelper.width(36),
                height: ResponsiveHelper.width(36),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFB02517),
                ),
                child: const Icon(Icons.close_rounded, color: AppColors.white, size: 18),
              ),
            ),
            SizedBox(width: ResponsiveHelper.spacing(8)),
            // Accept (blue pill button)
            GestureDetector(
              onTap: () {
                ActionConfirmDialog.show(
                  context,
                  title: AppStrings.acceptRequestTitle.tr,
                  message: AppStrings.acceptRequestFromDesc.tr.replaceAll('@name', name),
                  confirmLabel: AppStrings.accept.tr,
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: AppColors.blue,
                  onConfirm: () async {
                    await messageController.acceptMessageRequest(
                      requestId: requestId,
                      context: context,
                    );
                    onHandled?.call();
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.padding(16),
                  vertical: ResponsiveHelper.padding(8),
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0062E0), Color(0xFF014495)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(25)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF014495).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  AppStrings.accept.tr,
                  style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveHelper.fontSize(13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
