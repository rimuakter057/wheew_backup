// // widgets/group_message_bubble.dart
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart' hide Config;
// import 'package:platchatapp/feature/chat/model/group_message_response_model.dart';
// import 'package:platchatapp/helper/image_handler/image_handler.dart';
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
// import 'package:platchatapp/utils/color/app_colors.dart';
//
// class GroupMessageBubble extends StatelessWidget {
//   final GroupMessageResponseModel msg;
//   final bool isMine;
//   final String senderName;
//   final String senderAvatar;
//   final String text;
//   final String time;
//
//   const GroupMessageBubble({
//     super.key,
//     required this.msg,
//     required this.isMine,
//     required this.senderName,
//     required this.senderAvatar,
//     required this.text,
//     required this.time,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
//       child: Column(
//         crossAxisAlignment:
//         isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: [
//           // ── Other user: avatar + name + bubble ──────────
//           if (!isMine)
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 CircleAvatar(
//                   radius: ResponsiveHelper.iconSize(16),
//                   backgroundImage: senderAvatar.isNotEmpty
//                       ? NetworkImage(
//                     ImageHandler.imagesHandle(
//                       senderAvatar,
//                       isProfile: true,
//                     ),
//                   )
//                       : null,
//                   backgroundColor: AppColors.blue.withOpacity(0.2),
//                   child: senderAvatar.isEmpty
//                       ? Icon(
//                     Icons.person,
//                     size: ResponsiveHelper.iconSize(16),
//                     color: AppColors.blue,
//                   )
//                       : null,
//                 ),
//                 SizedBox(width: ResponsiveHelper.width(6)),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.only(
//                         left: ResponsiveHelper.width(4),
//                         bottom: ResponsiveHelper.height(2),
//                       ),
//                       child: Text(
//                         senderName,
//                         style: GoogleFonts.poppins(
//                           fontSize: ResponsiveHelper.fontSize(11),
//                           color: Colors.grey,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                     _Bubble(text: text, isMine: isMine, time: time),
//                   ],
//                 ),
//               ],
//             ),
//
//           // ── My message ───────────────────────────────────
//           if (isMine) _Bubble(text: text, isMine: isMine, time: time),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Internal bubble shape ─────────────────────────────────────
// class _Bubble extends StatelessWidget {
//   final String text;
//   final bool isMine;
//   final String time;
//
//   const _Bubble({
//     required this.text,
//     required this.isMine,
//     required this.time,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       constraints: BoxConstraints(maxWidth: ResponsiveHelper.width(272)),
//       margin: EdgeInsets.symmetric(vertical: ResponsiveHelper.height(2)),
//       padding: EdgeInsets.symmetric(
//         vertical: ResponsiveHelper.height(10),
//         horizontal: ResponsiveHelper.width(14),
//       ),
//       decoration: BoxDecoration(
//         color: isMine ? AppColors.blue : AppColors.greenClient,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(ResponsiveHelper.borderRadius(15)),
//           topRight: Radius.circular(ResponsiveHelper.borderRadius(15)),
//           bottomLeft: isMine
//               ? Radius.circular(ResponsiveHelper.borderRadius(15))
//               : Radius.zero,
//           bottomRight: isMine
//               ? Radius.zero
//               : Radius.circular(ResponsiveHelper.borderRadius(15)),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment:
//         isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: [
//           Text(
//             text,
//             style: GoogleFonts.poppins(color: AppColors.white),
//           ),
//           SizedBox(height: ResponsiveHelper.height(4)),
//           Text(
//             time,
//             style: GoogleFonts.poppins(
//               fontSize: ResponsiveHelper.fontSize(10),
//               color: AppColors.white.withOpacity(0.7),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




// widgets/group_message_bubble.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:platchatapp/core/service/api_url.dart';
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
                    _Bubble(msg: msg, isMine: isMine, time: time, text: text),
                  ],
                ),
              ],
            ),

          if (isMine) _Bubble(msg: msg, isMine: isMine, time: time, text: text),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final GroupMessageResponseModel msg;
  final bool isMine;
  final String time;
  final String text;

  const _Bubble({
    required this.msg,
    required this.isMine,
    required this.time,
    required this.text,
  });

  bool get isFile => msg.type == 'FILE';

  bool get isImage =>
      isFile &&
          (msg.fileUrl?.toLowerCase().endsWith('.png') == true ||
              msg.fileUrl?.toLowerCase().endsWith('.jpg') == true ||
              msg.fileUrl?.toLowerCase().endsWith('.jpeg') == true ||
              msg.fileUrl?.toLowerCase().endsWith('.webp') == true ||
              msg.fileUrl?.toLowerCase().endsWith('.gif') == true);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: ResponsiveHelper.width(272)),
      margin: EdgeInsets.symmetric(vertical: ResponsiveHelper.height(2)),
      padding: isImage
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(
        vertical: ResponsiveHelper.height(10),
        horizontal: ResponsiveHelper.width(14),
      ),
      decoration: BoxDecoration(
        color: isImage
            ? Colors.transparent
            : isMine
            ? AppColors.blue
            : AppColors.white,
        border: Border.all(color:isImage?Colors.transparent: isMine?AppColors.blue:AppColors.greyBorder),
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
      child: isFile ? _buildFileContent() : _buildTextContent(),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment:
      isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: GoogleFonts.inter(color:isMine? AppColors.white:AppColors.black,fontSize: 15,fontWeight: FontWeight.w400),
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
    );
  }

  Widget _buildFileContent() {
    final String fullUrl = ApiUrl.baseUrl + (msg.fileUrl ?? '');

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🖼️ Group file bubble');
    debugPrint('📌 type: ${msg.type}');
    debugPrint('🔗 fileUrl: ${msg.fileUrl}');
    debugPrint('🌐 fullUrl: $fullUrl');
    debugPrint('🖼️ isImage: $isImage');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.borderRadius(12),
        ),
        child: Image.network(
          fullUrl,
          width: ResponsiveHelper.width(220),
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: ResponsiveHelper.width(220),
              height: ResponsiveHelper.height(150),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('❌ Group image load error: $error');
            return _buildFileChip();
          },
        ),
      );
    }

    return _buildFileChip();
  }

  Widget _buildFileChip() {
    final String fileName =
        msg.fileUrl?.split('/').last ?? msg.fileName ?? text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.insert_drive_file,
          color: AppColors.white,
          size: ResponsiveHelper.iconSize(24),
        ),
        SizedBox(width: ResponsiveHelper.width(8)),
        Flexible(
          child: Text(
            fileName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontSize: ResponsiveHelper.fontSize(13),
            ),
          ),
        ),
      ],
    );
  }
}