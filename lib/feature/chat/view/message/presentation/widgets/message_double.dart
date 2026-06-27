// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:platchatapp/core/service/api_url.dart';
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
// import 'package:platchatapp/utils/color/app_colors.dart';
//
// class MessageBubble extends StatelessWidget {
//   final String message;
//   final bool isMine;
//   final String? type;
//   final String? fileUrl;
//   // ✅ read receipt
//   final bool? isRead;
//   final bool? isDelivered;
//
//   const MessageBubble({
//     super.key,
//     required this.message,
//     required this.isMine,
//     this.type,
//     this.fileUrl,
//     this.isRead,
//     this.isDelivered,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isFile = type == 'FILE';
//     final bool isImage = isFile &&
//         (fileUrl?.toLowerCase().endsWith('.png') == true ||
//             fileUrl?.toLowerCase().endsWith('.jpg') == true ||
//             fileUrl?.toLowerCase().endsWith('.jpeg') == true ||
//             fileUrl?.toLowerCase().endsWith('.webp') == true ||
//             fileUrl?.toLowerCase().endsWith('.gif') == true);
//
//     return Align(
//       alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
//       child: Column(
//         crossAxisAlignment:
//             isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             constraints:
//                 BoxConstraints(maxWidth: ResponsiveHelper.width(272)),
//             margin: EdgeInsets.only(
//               top: ResponsiveHelper.height(5),
//               bottom: isMine ? ResponsiveHelper.height(2) : ResponsiveHelper.height(5),
//             ),
//             padding: isImage
//                 ? EdgeInsets.zero
//                 : EdgeInsets.symmetric(
//                     vertical: ResponsiveHelper.height(10),
//                     horizontal: ResponsiveHelper.width(14),
//                   ),
//             decoration: BoxDecoration(
//               color: isImage
//                   ? Colors.transparent
//                   : isMine
//                   ? AppColors.blue
//                   : AppColors.white,
//               border: Border.all(
//                 color: isImage
//                     ? Colors.transparent
//                     : isMine
//                     ? AppColors.blue
//                     : AppColors.greyBorder,
//               ),
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(ResponsiveHelper.borderRadius(15)),
//                 topRight: Radius.circular(ResponsiveHelper.borderRadius(15)),
//                 bottomLeft: isMine
//                     ? Radius.circular(ResponsiveHelper.borderRadius(15))
//                     : Radius.zero,
//                 bottomRight: isMine
//                     ? Radius.zero
//                     : Radius.circular(ResponsiveHelper.borderRadius(15)),
//               ),
//             ),
//             child: isFile
//                 ? _buildFileContent(isImage)
//                 : Text(
//                     message,
//                     style: GoogleFonts.inter(
//                       color: isMine ? AppColors.white : AppColors.black,
//                       fontSize: 15,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//           ),
//
//           // ✅ Read receipt ticks — শুধু নিজের message-এ দেখাবে
//           if (isMine)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 4, right: 2),
//               child: _buildReadReceipt(),
//             ),
//         ],
//       ),
//     );
//   }
//
//   /// ✅ WhatsApp-style read receipt
//   Widget _buildReadReceipt() {
//     if (isRead == true) {
//       // ✓✓ নীল — পড়া হয়েছে
//       return Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.done_all, size: 15, color: AppColors.blue),
//         ],
//       );
//     } else if (isDelivered == true) {
//       // ✓✓ ধূসর — ডেলিভার হয়েছে কিন্তু পড়া হয়নি
//       return Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.done_all, size: 15, color: Colors.grey.shade400),
//         ],
//       );
//     } else {
//       // ✓ একটি টিক — শুধু পাঠানো হয়েছে
//       return Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.done, size: 15, color: Colors.grey.shade400),
//         ],
//       );
//     }
//   }
//
//   Widget _buildFileContent(bool isImage) {
//     final String fullUrl = ApiUrl.baseUrl + (fileUrl ?? '');
//
//     if (isImage) {
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(
//           ResponsiveHelper.borderRadius(12),
//         ),
//         child: Image.network(
//           fullUrl,
//           width: ResponsiveHelper.width(220),
//           fit: BoxFit.cover,
//           loadingBuilder: (context, child, loadingProgress) {
//             if (loadingProgress == null) return child;
//             return SizedBox(
//               width: ResponsiveHelper.width(220),
//               height: ResponsiveHelper.height(150),
//               child: const Center(
//                 child: CircularProgressIndicator(color: Colors.white),
//               ),
//             );
//           },
//           errorBuilder: (context, error, stackTrace) {
//             return _buildFileChip();
//           },
//         ),
//       );
//     }
//
//     return _buildFileChip();
//   }
//
//   Widget _buildFileChip() {
//     final String fileName = fileUrl?.split('/').last ?? message;
//
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(
//           Icons.insert_drive_file,
//           color: AppColors.white,
//           size: ResponsiveHelper.iconSize(24),
//         ),
//         SizedBox(width: ResponsiveHelper.width(8)),
//         Flexible(
//           child: Text(
//             fileName,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//             style: GoogleFonts.poppins(
//               color: AppColors.white,
//               fontSize: ResponsiveHelper.fontSize(13),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }











import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/chat/view/widgets/media_viewer_screen.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';



class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMine;
  final String? type;
  final String? fileUrl;
  final String? fileName;      // ← API: file_name
  final String? fileMimeType;  // ← API: file_mime_type
  final int? fileSize;         // ← API: file_size
  final bool? isRead;
  final bool? isDelivered;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.type,
    this.fileUrl,
    this.fileName,
    this.fileMimeType,
    this.fileSize,
    this.isRead,
    this.isDelivered,
  });

  // ── type detection ──────────────────────────────────────────────────────────

  bool get _isFileMessage => type == 'FILE' || (fileUrl != null && fileUrl!.isNotEmpty);

  bool get _isImage {
    if (fileMimeType != null && fileMimeType!.startsWith('image/')) return true;
    final url = (fileUrl ?? '').toLowerCase();
    return url.endsWith('.png') || url.endsWith('.jpg') ||
        url.endsWith('.jpeg') || url.endsWith('.webp') || url.endsWith('.gif');
  }

  bool get _isVideo {
    if (fileMimeType != null && fileMimeType!.startsWith('video/')) return true;
    final url = (fileUrl ?? '').toLowerCase();
    return url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.avi');
  }

  bool get _isAudio {
    if (fileMimeType != null && fileMimeType!.startsWith('audio/')) return true;
    final url = (fileUrl ?? '').toLowerCase();
    return url.endsWith('.mp3') || url.endsWith('.aac') ||
        url.endsWith('.ogg') || url.endsWith('.m4a');
  }

  String get _fullUrl => ApiUrl.baseUrl + (fileUrl ?? '');

  String get _displayName =>
      fileName ?? fileUrl?.split('/').last.split('?').first ?? message;

  String _formatSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _openViewer({required BuildContext context}) {
    // Get.to(
    //       () => MediaViewerScreen(
    //     fileUrl: _fullUrl,
    //     messageType: fileMimeType ?? type,
    //     fileName: _displayName,
    //   ),
    //   transition: Transition.fadeIn,
    //   duration: const Duration(milliseconds: 220),
    // );





    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MediaViewerScreen(
          fileUrl: _fullUrl,
          messageType: fileMimeType ?? type,
          fileName: _displayName,
        ),
      ),
    );


        }

  // ── build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
        isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _isFileMessage
                ? () {
              _openViewer(context: context);
            }
                : null,
            child: Container(
              constraints:
              BoxConstraints(maxWidth: ResponsiveHelper.width(272)),
              margin: EdgeInsets.only(
                top: ResponsiveHelper.height(5),
                bottom: isMine
                    ? ResponsiveHelper.height(2)
                    : ResponsiveHelper.height(5),
              ),
              padding: _isImage
                  ? EdgeInsets.zero
                  : EdgeInsets.symmetric(
                vertical: ResponsiveHelper.height(10),
                horizontal: ResponsiveHelper.width(14),
              ),
              decoration: BoxDecoration(
                color: _isImage
                    ? Colors.transparent
                    : isMine
                    ? AppColors.blue
                    : AppColors.white,
                border: Border.all(
                  color: _isImage
                      ? Colors.transparent
                      : isMine
                      ? AppColors.blue
                      : AppColors.greyBorder,
                ),
                borderRadius: BorderRadius.only(
                  topLeft:
                  Radius.circular(ResponsiveHelper.borderRadius(15)),
                  topRight:
                  Radius.circular(ResponsiveHelper.borderRadius(15)),
                  bottomLeft: isMine
                      ? Radius.circular(ResponsiveHelper.borderRadius(15))
                      : Radius.zero,
                  bottomRight: isMine
                      ? Radius.zero
                      : Radius.circular(
                      ResponsiveHelper.borderRadius(15)),
                ),
              ),
              child: _isFileMessage
                  ? _buildFileContent()
                  : Text(
                message,
                style: GoogleFonts.inter(
                  color: isMine ? AppColors.white : AppColors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          if (isMine)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, right: 2),
              child: _buildReadReceipt(),
            ),
        ],
      ),
    );
  }

  // ── file content router ─────────────────────────────────────────────────────

  Widget _buildFileContent() {
    if (_isImage) return _buildImageBubble();
    if (_isVideo) return _buildVideoBubble();
    if (_isAudio) return _buildAudioBubble();
    return _buildFileBubble();
  }

  // ── image ───────────────────────────────────────────────────────────────────

  Widget _buildImageBubble() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius:
          BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
          child: Image.network(
            _fullUrl,
            width: ResponsiveHelper.width(220),
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return SizedBox(
                width: ResponsiveHelper.width(220),
                height: ResponsiveHelper.height(160),
                child: Center(
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    color: Colors.white70,
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => _buildFileBubble(),
          ),
        ),
        // tap indicator overlay
        Positioned(
          bottom: 6,
          right: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.zoom_out_map_rounded, color: Colors.white, size: 12),
                SizedBox(width: 3),
                Text('View',
                    style: TextStyle(color: Colors.white, fontSize: 10)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── video ───────────────────────────────────────────────────────────────────

  Widget _buildVideoBubble() {
    return Container(
      width: ResponsiveHelper.width(220),
      height: ResponsiveHelper.height(130),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius:
        BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius:
              BorderRadius.circular(ResponsiveHelper.borderRadius(12)),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow_rounded,
                color: Colors.white, size: 36),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.videocam_rounded,
                      color: Colors.white70, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    _formatSize(fileSize),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── audio ───────────────────────────────────────────────────────────────────

  Widget _buildAudioBubble() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isMine ? Colors.white24 : AppColors.blue.withOpacity(.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            color: isMine ? Colors.white : AppColors.blue,
            size: 22,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'voice_message'.tr,
              style: GoogleFonts.inter(
                color: isMine ? AppColors.white : AppColors.black,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (fileSize != null)
              Text(
                _formatSize(fileSize),
                style: TextStyle(
                  color: isMine ? Colors.white60 : Colors.black38,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.audiotrack_rounded,
          color: isMine ? Colors.white54 : Colors.black38,
          size: 16,
        ),
      ],
    );
  }

  // ── generic file ────────────────────────────────────────────────────────────

  Widget _buildFileBubble() {
    IconData icon = Icons.insert_drive_file_rounded;
    if (fileMimeType != null) {
      if (fileMimeType!.contains('pdf')) icon = Icons.picture_as_pdf_rounded;
      else if (fileMimeType!.contains('word') || fileMimeType!.contains('document'))
        icon = Icons.description_rounded;
      else if (fileMimeType!.contains('sheet') || fileMimeType!.contains('excel'))
        icon = Icons.table_chart_rounded;
      else if (fileMimeType!.contains('zip') || fileMimeType!.contains('rar'))
        icon = Icons.folder_zip_rounded;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            color: isMine ? AppColors.white : AppColors.blue,
            size: ResponsiveHelper.iconSize(26)),
        SizedBox(width: ResponsiveHelper.width(8)),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: isMine ? AppColors.white : AppColors.black,
                  fontSize: ResponsiveHelper.fontSize(13),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (fileSize != null)
                Text(
                  _formatSize(fileSize),
                  style: TextStyle(
                    color: isMine ? Colors.white60 : Colors.black38,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveHelper.width(6)),
        Icon(
          Icons.arrow_forward_ios_rounded,
          color: isMine ? Colors.white54 : Colors.black26,
          size: 13,
        ),
      ],
    );
  }

  // ── read receipt ────────────────────────────────────────────────────────────

  Widget _buildReadReceipt() {
    if (isRead == true) {
      return Icon(Icons.done_all, size: 15, color: AppColors.blue);
    } else if (isDelivered == true) {
      return Icon(Icons.done_all, size: 15, color: Colors.grey.shade400);
    } else {
      return Icon(Icons.done, size: 15, color: Colors.grey.shade400);
    }
  }
}