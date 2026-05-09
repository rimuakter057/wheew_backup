import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

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
  final void Function()? onUnblock;

  const ChatTile({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    this.imagePath,
    required this.onTap,
    required this.fontWeight,
    this.isBlock,
    this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.padding(12),
          vertical: ResponsiveHelper.padding(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserAvatar(imagePath: imagePath),

            SizedBox(width: ResponsiveHelper.padding(12)),

            /// Middle content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Name + Time Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
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

                      SizedBox(width: 8),

                      isBlock == true
                          ? GestureDetector(
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
                            "blocked_user1".tr,
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveHelper.fontSize(12),
                              fontWeight: FontWeight.w500,
                              color: AppColors.blueClient,
                            ),
                          ),
                        ),
                      )
                          : Text(
                        time,
                        style: GoogleFonts.questrial(
                          color: AppColors.textBlack,
                          fontSize: ResponsiveHelper.fontSize(12),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: ResponsiveHelper.height(4)),




                if (isBlock != true)
      //   Text(
      //   "star",
      //   maxLines: 1,
      //   overflow: TextOverflow.ellipsis,
      //   style: GoogleFonts.questrial(
      //     fontSize: ResponsiveHelper.fontSize(14),
      //     fontWeight: fontWeight,
      //     color: AppColors.textBlack,
      //   ),
      // ),
                  Row(
                    children: [
                      Icon(Icons.star,color:Colors.orange,size: ResponsiveHelper.iconSize(14),),
                      SizedBox(height: ResponsiveHelper.width(4)),

                      Text(
                        "4.8",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.questrial(
                          fontSize: ResponsiveHelper.fontSize(14),
                          fontWeight: fontWeight,
                          color: AppColors.textBlack,
                        ),
                      ),

                    ],

                  ),


                  SizedBox(height: ResponsiveHelper.height(4)),
                  /// Message
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.questrial(
                      fontSize: ResponsiveHelper.fontSize(14),
                      fontWeight: fontWeight,
                      color: AppColors.textBlack,
                    ),
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