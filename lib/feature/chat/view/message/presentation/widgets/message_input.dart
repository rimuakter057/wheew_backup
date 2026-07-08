

// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart' hide Config;
// import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
// import 'package:platchatapp/utils/color/app_colors.dart';
// import 'package:platchatapp/utils/language/bad_words.dart';
//
// import 'attachment_bottom_sheet.dart';
// import 'message_preset_chips.dart';
//
// class MessageInput extends StatefulWidget {
//   final ChatController chatController;
//   final String currentRoomId;
//   final String receiverId;
//   final ValueChanged<String> onRoomIdUpdate;
//
//   const MessageInput({
//     super.key,
//     required this.chatController,
//     required this.currentRoomId,
//     required this.receiverId,
//     required this.onRoomIdUpdate,
//   });
//
//   @override
//   State<MessageInput> createState() => _MessageInputState();
// }
//
// class _MessageInputState extends State<MessageInput> {
//   bool _isEmojiVisible = false;
//   final FocusNode _focusNode = FocusNode();
//
//   // ── Selected file state ──
//   String? _selectedFilePath;
//   String? _selectedFileType;
//
//   @override
//   void initState() {
//     super.initState();
//     _focusNode.addListener(() {
//       if (_focusNode.hasFocus && _isEmojiVisible) {
//         setState(() => _isEmojiVisible = false);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _focusNode.dispose();
//     super.dispose();
//   }
//
//   void _onSend() {
//     debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
//     debugPrint('📤 Send Button Tapped');
//     debugPrint('📁 selectedFilePath: $_selectedFilePath');
//     debugPrint('📌 selectedFileType: $_selectedFileType');
//     debugPrint('💬 message: ${widget.chatController.messageController.text.trim()}');
//     debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
//
//     // ── File send ──
//     if (_selectedFilePath != null) {
//       debugPrint('📎 Sending file...');
//       widget.chatController.sendMediaMessage(
//         receiverId: widget.receiverId,
//         filePath: _selectedFilePath!,
//         caption: widget.chatController.messageController.text.trim(),
//       );
//       setState(() {
//         _selectedFilePath = null;
//         _selectedFileType = null;
//       });
//       widget.chatController.messageController.clear();
//       return;
//     }
//
//     // ── Text send ──
//     final String message = widget.chatController.messageController.text.trim();
//     if (message.isEmpty) {
//       debugPrint('⚠️ Message is empty, skipping');
//       return;
//     }
//
//     final bool containsBadWord =
//         BadWords.english.any(
//               (word) => message.toLowerCase().contains(word.toLowerCase()),
//         ) ||
//             BadWords.italian.any(
//                   (word) => message.toLowerCase().contains(word.toLowerCase()),
//             );
//
//     if (containsBadWord) {
//       debugPrint('⚠️ Bad word detected, blocking send');
//       showTopSnackBar(context, "bad_word_error".tr);
//       return;
//     }
//
//     debugPrint('💬 Sending text message...');
//     widget.chatController.sendNewEmitMessage(
//       receiverId: widget.receiverId,
//       message: message,
//       roomId: widget.currentRoomId,
//     );
//
//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (widget.currentRoomId.isEmpty &&
//           widget.chatController.roomID.value.isNotEmpty) {
//         widget.onRoomIdUpdate(widget.chatController.roomID.value);
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // ── Preset Messages ───────────────────────────────
//         MessagePresetChips(chatController: widget.chatController),
//
//         SizedBox(height: ResponsiveHelper.height(6)),
//
//         // ── File Preview ──────────────────────────────────
//         if (_selectedFilePath != null)
//           Container(
//             margin: EdgeInsets.symmetric(
//               horizontal: ResponsiveHelper.padding(16),
//               vertical: ResponsiveHelper.padding(4),
//             ),
//             padding: EdgeInsets.all(ResponsiveHelper.padding(10)),
//             decoration: BoxDecoration(
//               color: AppColors.greyShade,
//               borderRadius: BorderRadius.circular(
//                 ResponsiveHelper.borderRadius(12),
//               ),
//               border: Border.all(color: AppColors.blue.withOpacity(0.4)),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   _selectedFileType == 'IMAGE'
//                       ? Icons.image
//                       : _selectedFileType == 'VIDEO'
//                       ? Icons.videocam
//                       : Icons.insert_drive_file,
//                   color: AppColors.blue,
//                   size: ResponsiveHelper.iconSize(28),
//                 ),
//                 SizedBox(width: ResponsiveHelper.width(10)),
//                 Expanded(
//                   child: Text(
//                     _selectedFilePath!.split('/').last,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: ResponsiveHelper.fontSize(13),
//                       color: AppColors.black,
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     debugPrint('❌ File preview removed');
//                     setState(() {
//                       _selectedFilePath = null;
//                       _selectedFileType = null;
//                     });
//                   },
//                   child: Icon(
//                     Icons.close,
//                     size: ResponsiveHelper.iconSize(20),
//                     color: Colors.red,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//         // ── Input Row ─────────────────────────────────────
//         Padding(
//           padding: EdgeInsets.fromLTRB(
//             ResponsiveHelper.padding(16),
//             ResponsiveHelper.padding(8),
//             ResponsiveHelper.padding(16),
//             ResponsiveHelper.padding(8),
//           ),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // + icon
//               GestureDetector(
//                 onTap: () {
//                   debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
//                   debugPrint('📎 Attachment Button Tapped');
//                   debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
//                   AttachmentBottomSheet.show(
//                     context: context,
//                     onFileSelected: (filePath, type) {
//                       debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
//                       debugPrint('✅ File Selected');
//                       debugPrint('📁 filePath: $filePath');
//                       debugPrint('📌 type: $type');
//                       debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
//                       setState(() {
//                         _selectedFilePath = filePath;
//                         _selectedFileType = type;
//                       });
//                     },
//                   );
//                 },
//                 child: Padding(
//                   padding: EdgeInsets.only(
//                     bottom: ResponsiveHelper.padding(4),
//                     right: ResponsiveHelper.padding(8),
//                   ),
//                   child: Icon(
//                     Icons.add,
//                     size: ResponsiveHelper.iconSize(24),
//                     color: AppColors.black,
//                   ),
//                 ),
//               ),
//
//               // Input container
//               Expanded(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: ResponsiveHelper.padding(8),
//                     vertical: ResponsiveHelper.padding(4),
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColors.greyShade,
//                     borderRadius: BorderRadius.circular(
//                       ResponsiveHelper.borderRadius(16),
//                     ),
//                   ),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       // Emoji toggle
//                       IconButton(
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                         icon: Icon(
//                           Icons.emoji_emotions,
//                           color: AppColors.black,
//                           size: ResponsiveHelper.iconSize(22),
//                         ),
//                         onPressed: () {
//                           _focusNode.unfocus();
//                           setState(() => _isEmojiVisible = !_isEmojiVisible);
//                         },
//                       ),
//
//                       SizedBox(width: ResponsiveHelper.width(4)),
//
//                       // Text field
//                       Expanded(
//                         child: TextField(
//                           focusNode: _focusNode,
//                           controller: widget.chatController.messageController,
//                           minLines: 1,
//                           maxLines: 3,
//                           onTap: () {
//                             if (_isEmojiVisible) {
//                               setState(() => _isEmojiVisible = false);
//                             }
//                           },
//                           decoration: InputDecoration(
//                             hintText: _selectedFilePath != null
//                                 ? "add_caption".tr
//                                 : "type_here".tr,
//                             fillColor: AppColors.greyShade,
//                             hintStyle: TextStyle(
//                               color: AppColors.black,
//                               fontSize: ResponsiveHelper.fontSize(16),
//                             ),
//                             border: InputBorder.none,
//                             isDense: true,
//                             contentPadding: EdgeInsets.symmetric(
//                               vertical: ResponsiveHelper.padding(8),
//                             ),
//                           ),
//                           style: TextStyle(
//                             color: AppColors.black,
//                             fontSize: ResponsiveHelper.fontSize(16),
//                           ),
//                         ),
//                       ),
//
//                       // Send button
//                       GestureDetector(
//                         onTap: _onSend,
//                         child: Padding(
//                           padding: EdgeInsets.all(ResponsiveHelper.padding(8)),
//                           child: Icon(
//                             Icons.send_rounded,
//                             size: ResponsiveHelper.iconSize(24),
//                             color: AppColors.blue,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//
//               // + icon
//               GestureDetector(
//                 onTap: () {
//
//                   debugPrint('on tap mic');
//
//                 },
//                 child: Padding(
//                   padding: EdgeInsets.only(
//                     bottom: ResponsiveHelper.padding(4),
//                     right: ResponsiveHelper.padding(8),
//                   ),
//                   child: Icon(
//                     Icons.mic,
//                     size: ResponsiveHelper.iconSize(24),
//                     color: AppColors.black,
//                   ),
//                 ),
//               ),
//
//             ],
//           ),
//         ),
//
//         // ── Emoji Picker ──────────────────────────────────
//         Offstage(
//           offstage: !_isEmojiVisible,
//           child: SizedBox(
//             height: ResponsiveHelper.height(250),
//             child: EmojiPicker(
//               textEditingController: widget.chatController.messageController,
//               config: Config(
//                 height: ResponsiveHelper.height(250),
//                 emojiViewConfig: EmojiViewConfig(
//                   columns: 7,
//                   emojiSizeMax: 28,
//                   verticalSpacing: 0,
//                   horizontalSpacing: 0,
//                   backgroundColor: Colors.white,
//                   noRecents: Text(
//                     'no_recents_yet'.tr,
//                     style: GoogleFonts.poppins(
//                       fontSize: 20,
//                       color: Colors.black26,
//                     ),
//                   ),
//                 ),
//                 categoryViewConfig: CategoryViewConfig(
//                   initCategory: Category.SMILEYS,
//                   indicatorColor: AppColors.blue,
//                   iconColor: Colors.grey,
//                   iconColorSelected: AppColors.blue,
//                   backspaceColor: Colors.red,
//                 ),
//                 bottomActionBarConfig: BottomActionBarConfig(
//                   showSearchViewButton: false,
//                 ),
//               ),
//             ),
//           ),
//         ),
//
//         SizedBox(height: ResponsiveHelper.height(16)),
//       ],
//     );
//   }
// }
//
// // ── Top Snack Bar ──────────────────────────────────────────────
// void showTopSnackBar(BuildContext context, String message) {
//   final OverlayEntry overlayEntry = OverlayEntry(
//     builder: (context) => Positioned(
//       top: 50,
//       left: 16,
//       right: 16,
//       child: Material(
//         color: Colors.transparent,
//         child: Container(
//           padding: ResponsiveHelper.all(16),
//           decoration: BoxDecoration(
//             color: Colors.red.shade700,
//             borderRadius: BorderRadius.circular(
//               ResponsiveHelper.borderRadius(12),
//             ),
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 6,
//                 offset: Offset(0, 3),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               const Icon(Icons.error_outline, color: Colors.white),
//               SizedBox(width: ResponsiveHelper.padding(12)),
//               Expanded(
//                 child: Text(
//                   message,
//                   style: GoogleFonts.poppins(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: ResponsiveHelper.fontSize(16),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
//
//   Overlay.of(context).insert(overlayEntry);
//   Future.delayed(const Duration(seconds: 3)).then((_) => overlayEntry.remove());
// }






import 'dart:async';
import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:path_provider/path_provider.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/bad_words.dart';
import 'package:record/record.dart';

import 'attachment_bottom_sheet.dart';
import 'message_preset_chips.dart';

class MessageInput extends StatefulWidget {
  final ChatController chatController;
  final String currentRoomId;
  final String receiverId;
  final ValueChanged<String> onRoomIdUpdate;

  const MessageInput({
    super.key,
    required this.chatController,
    required this.currentRoomId,
    required this.receiverId,
    required this.onRoomIdUpdate,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool _isEmojiVisible = false;
  final FocusNode _focusNode = FocusNode();

  // ── Selected file state ──
  String? _selectedFilePath;
  String? _selectedFileType;

  // ── Voice recording state ──
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordedFilePath;
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _isEmojiVisible) {
        setState(() => _isEmojiVisible = false);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _recordTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _onSend() {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📤 Send Button Tapped');
    debugPrint('📁 selectedFilePath: $_selectedFilePath');
    debugPrint('📌 selectedFileType: $_selectedFileType');
    debugPrint('💬 message: ${widget.chatController.messageController.text.trim()}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // ── File send ──
    if (_selectedFilePath != null) {
      debugPrint('📎 Sending file...');
      widget.chatController.sendMediaMessage(
        receiverId: widget.receiverId,
        filePath: _selectedFilePath!,
        caption: widget.chatController.messageController.text.trim(),
      );
      setState(() {
        _selectedFilePath = null;
        _selectedFileType = null;
      });
      widget.chatController.messageController.clear();
      return;
    }

    // ── Text send ──
    final String message = widget.chatController.messageController.text.trim();
    if (message.isEmpty) {
      debugPrint('⚠️ Message is empty, skipping');
      return;
    }

    final bool containsBadWord =
        BadWords.english.any(
              (word) => message.toLowerCase().contains(word.toLowerCase()),
        ) ||
            BadWords.italian.any(
                  (word) => message.toLowerCase().contains(word.toLowerCase()),
            );

    if (containsBadWord) {
      debugPrint('⚠️ Bad word detected, blocking send');
      showTopSnackBar(context, "bad_word_error".tr);
      return;
    }

    debugPrint('💬 Sending text message...');
    widget.chatController.sendNewEmitMessage(
      receiverId: widget.receiverId,
      message: message,
      roomId: widget.currentRoomId,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (widget.currentRoomId.isEmpty &&
          widget.chatController.roomID.value.isNotEmpty) {
        widget.onRoomIdUpdate(widget.chatController.roomID.value);
      }
    });
  }

  // ── Voice recording: start ──
  Future<void> _startRecording() async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🎙️ Mic Button Tapped — starting recording');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    try {
      final bool hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        debugPrint('⚠️ Mic permission denied');
        showTopSnackBar(context, "mic_permission_error".tr);
        return;
      }

      final Directory dir = await getTemporaryDirectory();
      final String path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

      _focusNode.unfocus();
      setState(() {
        _isRecording = true;
        _recordedFilePath = path;
        _recordDuration = Duration.zero;
        _isEmojiVisible = false;
      });

      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _recordDuration += const Duration(seconds: 1));
      });

      debugPrint('✅ Recording started at: $path');
    } catch (e) {
      debugPrint('❌ Error starting recording: $e');
    }
  }

  // ── Voice recording: delete/cancel ──
  Future<void> _deleteRecording() async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🗑️ Delete Voice Button Tapped');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _recordTimer?.cancel();
    try {
      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
      }
    } catch (e) {
      debugPrint('⚠️ Error stopping recorder before delete: $e');
    }

    final String? path = _recordedFilePath;
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        debugPrint('✅ Voice file deleted: $path');
      }
    }

    setState(() {
      _isRecording = false;
      _recordedFilePath = null;
      _recordDuration = Duration.zero;
    });
  }

  // ── Voice recording: send (DEBUG ONLY for now) ──
  Future<void> _sendRecording() async {
    _recordTimer?.cancel();
    String? finalPath;
    try {
      finalPath = await _audioRecorder.stop();
    } catch (e) {
      debugPrint('❌ Error stopping recorder on send: $e');
    }

    finalPath ??= _recordedFilePath;

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🎤 Send Voice Button Tapped (DEBUG ONLY — not sent yet)');
    debugPrint('📁 recordedFilePath: $finalPath');
    debugPrint('⏱️ duration: ${_formatDuration(_recordDuration)}');

    if (finalPath != null) {
      final file = File(finalPath);
      if (await file.exists()) {
        final int size = await file.length();
        debugPrint('✅ File exists, size: $size bytes — recording looks good');
      } else {
        debugPrint('❌ File does NOT exist — recording failed');
      }
    } else {
      debugPrint('❌ No recorded file path found — recording failed');
    }
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // NOTE: actual sending to chat is intentionally NOT wired up yet.
    // This just resets the recording UI after the debug check.
    setState(() {
      _isRecording = false;
      _recordedFilePath = null;
      _recordDuration = Duration.zero;
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Preset Messages ───────────────────────────────
        MessagePresetChips(chatController: widget.chatController),

        SizedBox(height: ResponsiveHelper.height(6)),

        // ── File Preview ──────────────────────────────────
        if (_selectedFilePath != null)
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.padding(16),
              vertical: ResponsiveHelper.padding(4),
            ),
            padding: EdgeInsets.all(ResponsiveHelper.padding(10)),
            decoration: BoxDecoration(
              color: AppColors.greyShade,
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.borderRadius(12),
              ),
              border: Border.all(color: AppColors.blue.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Icon(
                  _selectedFileType == 'IMAGE'
                      ? Icons.image
                      : _selectedFileType == 'VIDEO'
                      ? Icons.videocam
                      : Icons.insert_drive_file,
                  color: AppColors.blue,
                  size: ResponsiveHelper.iconSize(28),
                ),
                SizedBox(width: ResponsiveHelper.width(10)),
                Expanded(
                  child: Text(
                    _selectedFilePath!.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(13),
                      color: AppColors.black,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    debugPrint('❌ File preview removed');
                    setState(() {
                      _selectedFilePath = null;
                      _selectedFileType = null;
                    });
                  },
                  child: Icon(
                    Icons.close,
                    size: ResponsiveHelper.iconSize(20),
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),

        // ── Input Row / Recording Bar ─────────────────────
        _isRecording ? _buildRecordingBar() : _buildInputRow(),

        // ── Emoji Picker ──────────────────────────────────
        Offstage(
          offstage: !_isEmojiVisible,
          child: SizedBox(
            height: ResponsiveHelper.height(250),
            child: EmojiPicker(
              textEditingController: widget.chatController.messageController,
              config: Config(
                height: ResponsiveHelper.height(250),
                emojiViewConfig: EmojiViewConfig(
                  columns: 7,
                  emojiSizeMax: 28,
                  verticalSpacing: 0,
                  horizontalSpacing: 0,
                  backgroundColor: Colors.white,
                  noRecents: Text(
                    'no_recents_yet'.tr,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.black26,
                    ),
                  ),
                ),
                categoryViewConfig: CategoryViewConfig(
                  initCategory: Category.SMILEYS,
                  indicatorColor: AppColors.blue,
                  iconColor: Colors.grey,
                  iconColorSelected: AppColors.blue,
                  backspaceColor: Colors.red,
                ),
                bottomActionBarConfig: BottomActionBarConfig(
                  showSearchViewButton: false,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: ResponsiveHelper.height(16)),
      ],
    );
  }

  // ── Normal text/attachment input row ──
  Widget _buildInputRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveHelper.padding(16),
        ResponsiveHelper.padding(8),
        ResponsiveHelper.padding(16),
        ResponsiveHelper.padding(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // + icon
          GestureDetector(
            onTap: () {
              debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
              debugPrint('📎 Attachment Button Tapped');
              debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
              AttachmentBottomSheet.show(
                context: context,
                onFileSelected: (filePath, type) {
                  debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
                  debugPrint('✅ File Selected');
                  debugPrint('📁 filePath: $filePath');
                  debugPrint('📌 type: $type');
                  debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
                  setState(() {
                    _selectedFilePath = filePath;
                    _selectedFileType = type;
                  });
                },
              );
            },
            child: Padding(
              padding: EdgeInsets.only(
                bottom: ResponsiveHelper.padding(4),
                right: ResponsiveHelper.padding(8),
              ),
              child: Icon(
                Icons.add,
                size: ResponsiveHelper.iconSize(24),
                color: AppColors.black,
              ),
            ),
          ),

          // Input container
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.padding(8),
                vertical: ResponsiveHelper.padding(4),
              ),
              decoration: BoxDecoration(
                color: AppColors.greyShade,
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(16),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Emoji toggle
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.emoji_emotions,
                      color: AppColors.black,
                      size: ResponsiveHelper.iconSize(22),
                    ),
                    onPressed: () {
                      _focusNode.unfocus();
                      setState(() => _isEmojiVisible = !_isEmojiVisible);
                    },
                  ),

                  SizedBox(width: ResponsiveHelper.width(4)),

                  // Text field
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      controller: widget.chatController.messageController,
                      minLines: 1,
                      maxLines: 3,
                      onTap: () {
                        if (_isEmojiVisible) {
                          setState(() => _isEmojiVisible = false);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: _selectedFilePath != null
                            ? "add_caption".tr
                            : "type_here".tr,
                        fillColor: AppColors.greyShade,
                        hintStyle: TextStyle(
                          color: AppColors.black,
                          fontSize: ResponsiveHelper.fontSize(16),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: ResponsiveHelper.padding(8),
                        ),
                      ),
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: ResponsiveHelper.fontSize(16),
                      ),
                    ),
                  ),

                  // Send button
                  GestureDetector(
                    onTap: _onSend,
                    child: Padding(
                      padding: EdgeInsets.all(ResponsiveHelper.padding(8)),
                      child: Icon(
                        Icons.send_rounded,
                        size: ResponsiveHelper.iconSize(24),
                        color: AppColors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // mic icon
          GestureDetector(
            onTap: _startRecording,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: ResponsiveHelper.padding(4),
                right: ResponsiveHelper.padding(8),
              ),
              child: Icon(
                Icons.mic,
                size: ResponsiveHelper.iconSize(24),
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Voice recording bar (shown while recording) ──
  Widget _buildRecordingBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveHelper.padding(16),
        ResponsiveHelper.padding(8),
        ResponsiveHelper.padding(16),
        ResponsiveHelper.padding(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Delete recording
          GestureDetector(
            onTap: _deleteRecording,
            child: Padding(
              padding: EdgeInsets.all(ResponsiveHelper.padding(8)),
              child: Icon(
                Icons.delete_outline,
                size: ResponsiveHelper.iconSize(26),
                color: Colors.red,
              ),
            ),
          ),

          // Recording indicator + timer
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.padding(12),
                vertical: ResponsiveHelper.padding(10),
              ),
              decoration: BoxDecoration(
                color: AppColors.greyShade,
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.fiber_manual_record,
                    color: Colors.red,
                    size: ResponsiveHelper.iconSize(14),
                  ),
                  SizedBox(width: ResponsiveHelper.width(8)),
                  Text(
                    _formatDuration(_recordDuration),
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: ResponsiveHelper.fontSize(15),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.width(8)),
                  Expanded(
                    child: Text(
                      "recording".tr,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.black.withOpacity(0.6),
                        fontSize: ResponsiveHelper.fontSize(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: ResponsiveHelper.width(8)),

          // Send recording
          GestureDetector(
            onTap: _sendRecording,
            child: Padding(
              padding: EdgeInsets.all(ResponsiveHelper.padding(8)),
              child: Icon(
                Icons.send_rounded,
                size: ResponsiveHelper.iconSize(24),
                color: AppColors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top Snack Bar ──────────────────────────────────────────────
void showTopSnackBar(BuildContext context, String message) {
  final OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: ResponsiveHelper.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade700,
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.borderRadius(12),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: ResponsiveHelper.padding(12)),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.fontSize(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);
  Future.delayed(const Duration(seconds: 3)).then((_) => overlayEntry.remove());
}