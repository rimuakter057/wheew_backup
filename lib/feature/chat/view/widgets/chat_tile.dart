import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import 'package:platchatapp/utils/language/app_string.dart';

import '../../../../helper/responsive_helper/responsive_helper.dart';
import '../../../../share/widgets/avatar/user_avatar.dart';

class ChatTile extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final String? imagePath;
  final VoidCallback onTap;
  final FontWeight fontWeight;
  final bool? isBlock;
  final bool? isBlockedByMe;
  final bool? isBlockedMe;
  final bool isGroup;
  final double? rating;
  final int? unreadCount;           // ✅ নতুন
  final bool? isRead;
  final bool? isDelivered;
  final void Function()? onUnblock;
  final bool? isVehicleVerified;
  final Color?ratingColor;
  final int?totalRating;
  final String?plateNumber;

  const ChatTile({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    this.imagePath,
    required this.onTap,
    required this.fontWeight,
    this.isBlock,
    this.isBlockedByMe,
    this.isBlockedMe,
    this.isGroup = false,
    this.rating,
    this.unreadCount,               // ✅ নতুন
    this.isRead,
    this.isDelivered,
    this.onUnblock,
    this.isVehicleVerified,
    this.ratingColor,
    this.totalRating,
    this.plateNumber,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasUnread = (unreadCount ?? 0) > 0;
    final bool showUnblockButton = isBlockedByMe == true || (isBlock == true && isBlockedMe != true);
    final bool showBlockedStatus = isBlockedMe == true && isBlockedByMe != true;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.padding(14),
          vertical: ResponsiveHelper.padding(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserAvatar(imagePath: imagePath, isGroup: isGroup, radius: 24),

            SizedBox(width: ResponsiveHelper.padding(12)),

            /// Middle content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Name + Time / Block Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: ResponsiveHelper.fontSize(15),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1D2939),
                                ),
                              ),
                            ),

                            if (!isGroup) ...[
                              SizedBox(width: ResponsiveHelper.width(4)),
                              Image.asset(
                                isVehicleVerified == true
                                    ? AssetsPath.verified
                                    : AssetsPath.unverified,
                                width: ResponsiveHelper.iconSize(15),
                                height: ResponsiveHelper.iconSize(15),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      if (showUnblockButton)
                        GestureDetector(
                          onTap: onUnblock,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.padding(8),
                              vertical: ResponsiveHelper.padding(4),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              AppStrings.unblock.tr,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveHelper.fontSize(11),
                                fontWeight: FontWeight.w500,
                                color: AppColors.blue,
                              ),
                            ),
                          ),
                        )
                      else if (showBlockedStatus)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.padding(8),
                            vertical: ResponsiveHelper.padding(4),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Blocked',
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveHelper.fontSize(11),
                              fontWeight: FontWeight.w500,
                              color: Colors.red.shade700,
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            if (isGroup) ...[
                              Container(
                                padding: ResponsiveHelper.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.greyShade.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      AssetsPath.group,
                                      width: ResponsiveHelper.iconSize(12),
                                      height: ResponsiveHelper.iconSize(12),
                                    ),
                                    SizedBox(width: ResponsiveHelper.width(3)),
                                    Text(
                                      AppStrings.group.tr,
                                      style: context.bodyMedium.copyWith(
                                        color: AppColors.black,
                                        fontSize: ResponsiveHelper.fontSize(10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: ResponsiveHelper.width(4)),
                            ],

                            Text(
                              time,
                              style: GoogleFonts.poppins(
                                color: hasUnread ? AppColors.blue : const Color(0xFF98A2B3),
                                fontSize: ResponsiveHelper.fontSize(11),
                                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // ✅ Rating — শুধু ONE_TO_ONE এ
                  if (isBlock != true && !isGroup && (plateNumber != null || (rating != null && rating! > 0)))
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          if (plateNumber != null && plateNumber!.isNotEmpty)
                            Text(
                              plateNumber.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveHelper.fontSize(12),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6A6969),
                              ),
                            ),

                          if (plateNumber != null && plateNumber!.isNotEmpty)
                            SizedBox(width: ResponsiveHelper.width(6)),

                          Icon(
                            Icons.star,
                            color: ratingColor ?? AppColors.rating,
                            size: ResponsiveHelper.iconSize(12),
                          ),
                          //  SizedBox(width: ResponsiveHelper.width(4)),
                          Text(
                            (rating ?? 0.0).toStringAsFixed(1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveHelper.fontSize(11),
                              fontWeight: fontWeight,
                              color: AppColors.textBlack,
                            ),
                          ),

                          SizedBox(width: ResponsiveHelper.width(3)),
                          Text(
                            "(${totalRating?.toString() ?? '0'})",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveHelper.fontSize(10),
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: ResponsiveHelper.height(3)),

                  /// Message + Unread badge row
                  if (isBlock != true)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveHelper.fontSize(13),
                              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                              fontStyle: (message == AppStrings.typing.tr || message == 'Typing...')
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              color: (message == AppStrings.typing.tr || message == 'Typing...')
                                  ? AppColors.blue
                                  : (hasUnread
                                      ? const Color(0xFF1D2939)
                                      : const Color(0xFF667085)),
                            ),
                          ),
                        ),

                        // ✅ Unread count badge
                        if (hasUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0062E0),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                unreadCount! > 99 ? '99+' : '$unreadCount',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ] else if (!showUnblockButton && !showBlockedStatus && message.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          if (isRead == true)
                            const Icon(
                              Icons.done_all,
                              size: 16,
                              color: Color(0xFF0062E0),
                            )
                          else if (isDelivered == true)
                            const Icon(
                              Icons.done_all,
                              size: 16,
                              color: Colors.grey,
                            )
                          else
                            const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.grey,
                            ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}