// // widgets/message_input.dart
//
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
//     final String message =
//     widget.chatController.messageController.text.trim();
//     if (message.isEmpty) return;
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
//       showTopSnackBar(context, "bad_word_error".tr);
//       return;
//     }
//
//     widget.chatController.sendNewEmitMessage(
//       receiverId: widget.receiverId,
//       message: message,
//       roomId: widget.currentRoomId,
//     );
//
//     // Update roomId if it was empty
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
//
//
//
//
//
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
//               // + icon — container এর বাইরে, বামে
//               GestureDetector(
//                 onTap: () {
//                   AttachmentBottomSheet.show(
//                     context: context,
//                     onFileSelected: (filePath, type) {
//                       widget.chatController.sendMediaMessage(
//                         receiverId: widget.receiverId,
//                         filePath: filePath,
//                         roomId: widget.currentRoomId,
//                       );
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
//               // Input container — মাঝখানে expand হবে
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
//                             hintText: "type_here".tr,
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
//             ],
//           ),
//         ),
//
//         Offstage(
//           offstage: !_isEmojiVisible,
//           child: SizedBox(
//             height: ResponsiveHelper.height(250),
//             child: EmojiPicker(
//               textEditingController:
//               widget.chatController.messageController,
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
//   Future.delayed(const Duration(seconds: 3))
//       .then((_) => overlayEntry.remove());
// }




// widgets/message_input.dart

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/bad_words.dart';

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

        // ── Input Row ─────────────────────────────────────
        Padding(
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
            ],
          ),
        ),

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