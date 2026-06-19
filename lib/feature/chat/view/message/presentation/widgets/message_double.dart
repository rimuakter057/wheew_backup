import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMine;
  final String? type;
  final String? fileUrl;
  // ✅ read receipt
  final bool? isRead;
  final bool? isDelivered;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.type,
    this.fileUrl,
    this.isRead,
    this.isDelivered,
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
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints:
                BoxConstraints(maxWidth: ResponsiveHelper.width(272)),
            margin: EdgeInsets.only(
              top: ResponsiveHelper.height(5),
              bottom: isMine ? ResponsiveHelper.height(2) : ResponsiveHelper.height(5),
            ),
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
              border: Border.all(
                color: isImage
                    ? Colors.transparent
                    : isMine
                    ? AppColors.blue
                    : AppColors.greyBorder,
              ),
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
                    style: GoogleFonts.inter(
                      color: isMine ? AppColors.white : AppColors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
          ),

          // ✅ Read receipt ticks — শুধু নিজের message-এ দেখাবে
          if (isMine)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, right: 2),
              child: _buildReadReceipt(),
            ),
        ],
      ),
    );
  }

  /// ✅ WhatsApp-style read receipt
  Widget _buildReadReceipt() {
    if (isRead == true) {
      // ✓✓ নীল — পড়া হয়েছে
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.done_all, size: 15, color: AppColors.blue),
        ],
      );
    } else if (isDelivered == true) {
      // ✓✓ ধূসর — ডেলিভার হয়েছে কিন্তু পড়া হয়নি
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.done_all, size: 15, color: Colors.grey.shade400),
        ],
      );
    } else {
      // ✓ একটি টিক — শুধু পাঠানো হয়েছে
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.done, size: 15, color: Colors.grey.shade400),
        ],
      );
    }
  }

  Widget _buildFileContent(bool isImage) {
    final String fullUrl = ApiUrl.baseUrl + (fileUrl ?? '');

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