// // widgets/message_bubble.dart
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
// import 'package:platchatapp/utils/color/app_colors.dart';
//
// class MessageBubble extends StatelessWidget {
//   final String message;
//   final bool isMine;
//
//   const MessageBubble({
//     super.key,
//     required this.message,
//     required this.isMine,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment:
//       isMine ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         constraints: BoxConstraints(
//           maxWidth: ResponsiveHelper.width(272),
//         ),
//         margin: EdgeInsets.symmetric(
//           vertical: ResponsiveHelper.height(5),
//         ),
//         padding: EdgeInsets.symmetric(
//           vertical: ResponsiveHelper.height(10),
//           horizontal: ResponsiveHelper.width(14),
//         ),
//         decoration: BoxDecoration(
//           color: isMine ? AppColors.blue : AppColors.greenClient,
//           borderRadius: BorderRadius.only(
//             topLeft:
//             Radius.circular(ResponsiveHelper.borderRadius(15)),
//             topRight:
//             Radius.circular(ResponsiveHelper.borderRadius(15)),
//             bottomLeft: isMine
//                 ? Radius.circular(ResponsiveHelper.borderRadius(15))
//                 : Radius.zero,
//             bottomRight: isMine
//                 ? Radius.zero
//                 : Radius.circular(ResponsiveHelper.borderRadius(15)),
//           ),
//         ),
//         child: Text(
//           message,
//           style: GoogleFonts.poppins(color: AppColors.white),
//         ),
//       ),
//     );
//   }
// }










// widgets/message_bubble.dart

// widgets/message_bubble.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/main.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMine;
  final String? type;
  final String? fileUrl;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.type,
    this.fileUrl,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFile = type == 'FILE';
    final bool isImage = isFile &&
        (fileUrl?.toLowerCase().endsWith('.png') == true ||
            fileUrl?.toLowerCase().endsWith('.jpg') == true ||
            fileUrl?.toLowerCase().endsWith('.jpeg') == true ||
            fileUrl?.toLowerCase().endsWith('.webp') == true ||
            fileUrl?.toLowerCase().endsWith('.gif') == true);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: ResponsiveHelper.width(272)),
        margin: EdgeInsets.symmetric(vertical: ResponsiveHelper.height(5)),
        padding: isImage
            ? EdgeInsets.zero // ✅ image হলে padding নেই
            : EdgeInsets.symmetric(
          vertical: ResponsiveHelper.height(10),
          horizontal: ResponsiveHelper.width(14),
        ),
        decoration: BoxDecoration(
          color: isImage
              ? Colors.transparent // ✅ image হলে background নেই
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
        child: isFile
            ? _buildFileContent(isImage)
            : Text(
          message,
          style: GoogleFonts.inter(color:isMine? AppColors.white:AppColors.black,fontSize: 15,fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget _buildFileContent(bool isImage) {
    final String fullUrl = ApiUrl.baseUrl + (fileUrl ?? '');

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🖼️ Building file bubble');
    debugPrint('📌 type: $type');
    debugPrint('🔗 fileUrl: $fileUrl');
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
            debugPrint('❌ Image load error: $error');
            return _buildFileChip();
          },
        ),
      );
    }

    return _buildFileChip();
  }

  Widget _buildFileChip() {
    final String fileName = fileUrl?.split('/').last ?? message;

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