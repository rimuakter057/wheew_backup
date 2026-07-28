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
          horizontal: ResponsiveHelper.padding(12),
          vertical: ResponsiveHelper.padding(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            UserAvatar(imagePath: imagePath, isGroup: isGroup),

            SizedBox(width: ResponsiveHelper.padding(12)),

            /// Middle content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Name + Time / Block Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.questrial(
                                  fontSize: ResponsiveHelper.fontSize(16),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textBlack,
                                ),
                              ),
                            ),



                            if (!isGroup) ...[
                              SizedBox(width: ResponsiveHelper.width(4)),
                              Image.asset(
                                isVehicleVerified == true
                                    ? AssetsPath.verified
                                    : AssetsPath.unverified,
                                width: ResponsiveHelper.iconSize(16),
                                height: ResponsiveHelper.iconSize(16),
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
                              vertical: ResponsiveHelper.padding(6),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              AppStrings.unblock.tr,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveHelper.fontSize(12),
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
                            vertical: ResponsiveHelper.padding(6),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'Blocked',
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveHelper.fontSize(12),
                              fontWeight: FontWeight.w500,
                              color: Colors.red.shade700,
                            ),
                          ),
                        )
                      else Row(
                            children: [



                              if (isGroup) ...[
                                Container(
                                  padding: ResponsiveHelper.symmetric(horizontal: 8,vertical: 4),
                                  decoration: BoxDecoration(color: AppColors.greyShade,

                                      borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(18))
                                  ),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        AssetsPath.group,
                                        width: ResponsiveHelper.iconSize(16),
                                        height: ResponsiveHelper.iconSize(16),
                                      ),
                                   SizedBox(width: ResponsiveHelper.width(4),),
                                      Text(AppStrings.group.tr,style: context.bodyMedium.copyWith(color: AppColors.black),),

                                    ],
                                  ),
                                ),
                                SizedBox(width: ResponsiveHelper.width(4)),
                              ],

                              Text(
                                                      time,
                                                      style: GoogleFonts.questrial(
                              color: hasUnread ? AppColors.blue : AppColors.textBlack,
                              fontSize: ResponsiveHelper.fontSize(12),
                              fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w400,
                                                      ),
                                                    ),
                            ],
                          ),
                    ],
                  ),

                  SizedBox(height: ResponsiveHelper.height(4)),


                  // ✅ Rating — শুধু ONE_TO_ONE এ
                  if (isBlock != true && !isGroup)
                    Row(
                      children: [
                        Text(
                          plateNumber.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.questrial(
                            fontSize: ResponsiveHelper.fontSize(15),
                            fontWeight: FontWeight.w600,
                            color:Color(0xFF6A6969),
                          ),
                        ),

                        SizedBox(width: ResponsiveHelper.width(8)),
                        Icon(
                          Icons.star,
                          color:ratingColor?? AppColors.rating,
                          size: ResponsiveHelper.iconSize(14),
                        ),
                      //  SizedBox(width: ResponsiveHelper.width(4)),
                        Text(
                          rating!.toStringAsFixed(1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.questrial(
                            fontSize: ResponsiveHelper.fontSize(14),
                            fontWeight: fontWeight,
                            color: AppColors.textBlack,
                          ),
                        ),

                        SizedBox(width: ResponsiveHelper.width(4)),
                        Text(
                          "(${totalRating.toString()})",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.questrial(
                            fontSize: ResponsiveHelper.fontSize(12),
                            fontWeight: FontWeight.w200,
                            color: AppColors.black,
                          ),
                        ),

                      ],
                    ),

                  SizedBox(height: ResponsiveHelper.height(4)),

                  /// Message + Unread badge row
                  if (isBlock != true)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.questrial(
                              fontSize: ResponsiveHelper.fontSize(14),
                              fontWeight: fontWeight,
                              fontStyle: (message == AppStrings.typing.tr || message == 'Typing...')
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              color: (message == AppStrings.typing.tr || message == 'Typing...')
                                  ? AppColors.blue
                                  : (hasUnread
                                      ? AppColors.textBlack
                                      : AppColors.textBlack.withValues(alpha: 0.65)),
                            ),
                          ),
                        ),

                        // ✅ Unread count badge
                        if (hasUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            constraints: const BoxConstraints(minWidth: 20),
                            height: 20,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: const BoxDecoration(
                              color: AppColors.blue,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Center(
                              child: Text(
                                unreadCount! > 99 ? '99+' : '$unreadCount',
                                style: GoogleFonts.questrial(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
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