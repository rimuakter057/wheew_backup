
import 'dart:async';
import 'package:platchatapp/utils/language/app_string.dart';
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

  // ── Typing state ──
  Timer? _typingTimer;
  bool _isTypingEmit = false;

  void _onTextChanged(String text) {
    if (widget.currentRoomId.isEmpty) return;

    if (!_isTypingEmit && text.isNotEmpty) {
      _isTypingEmit = true;
      widget.chatController.sendTyping(
        receiverId: widget.receiverId,
        roomId: widget.currentRoomId,
        isGroup: false,
      );
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 1500), () {
      if (_isTypingEmit) {
        _isTypingEmit = false;
        widget.chatController.sendStopTyping(
          receiverId: widget.receiverId,
          roomId: widget.currentRoomId,
          isGroup: false,
        );
      }
    });
  }

  void _resetTypingEmit() {
    _typingTimer?.cancel();
    if (_isTypingEmit) {
      _isTypingEmit = false;
      widget.chatController.sendStopTyping(
        receiverId: widget.receiverId,
        roomId: widget.currentRoomId,
        isGroup: false,
      );
    }
  }

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
    _typingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _onSend() {
    _resetTypingEmit();
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
      showTopSnackBar(context, AppStrings.badWordError.tr);
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
        showTopSnackBar(context, AppStrings.micPermissionError.tr);
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

  Future<void> _sendRecording() async {
    if (!_isRecording) {
      debugPrint('⚠️ Already processing recording send, skipping extra tap');
      return;
    }

    _resetTypingEmit();
    _recordTimer?.cancel();

    String? finalPath;
    try {
      finalPath = await _audioRecorder.stop();
    } catch (e) {
      debugPrint('❌ Error stopping recorder on send: $e');
    }

    finalPath ??= _recordedFilePath;
    final int durationSecs = _recordDuration.inSeconds;

    setState(() {
      _isRecording = false;
      _recordedFilePath = null;
      _recordDuration = Duration.zero;
    });

    if (finalPath != null) {
      final file = File(finalPath);
      if (await file.exists()) {
        await widget.chatController.sendVoiceMessage(
          receiverId: widget.receiverId,
          filePath: finalPath,
          durationSeconds: durationSecs,
          roomId: widget.currentRoomId,
        );
      }
    }
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
                    AppStrings.noRecentsYet.tr,
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
          // Input pill
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.padding(12),
                vertical: ResponsiveHelper.padding(4),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.borderRadius(24),
                ),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Emoji button
                  GestureDetector(
                    onTap: () {
                      _focusNode.unfocus();
                      setState(() => _isEmojiVisible = !_isEmojiVisible);
                    },
                    child: Icon(
                      Icons.sentiment_satisfied_alt_rounded,
                      color: Colors.grey.shade600,
                      size: ResponsiveHelper.iconSize(24),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.width(10)),
                  // Text field
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      controller: widget.chatController.messageController,
                      minLines: 1,
                      maxLines: 3,
                      onChanged: _onTextChanged,
                      onTap: () {
                        if (_isEmojiVisible) {
                          setState(() => _isEmojiVisible = false);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: _selectedFilePath != null
                            ? AppStrings.addCaption.tr
                            : "Write here...",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: ResponsiveHelper.fontSize(15),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: ResponsiveHelper.padding(10),
                        ),
                      ),
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: ResponsiveHelper.fontSize(15),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.width(10)),
                  // Attachment button
                  GestureDetector(
                    onTap: () {
                      AttachmentBottomSheet.show(
                        context: context,
                        onFileSelected: (filePath, type) {
                          setState(() {
                            _selectedFilePath = filePath;
                            _selectedFileType = type;
                          });
                        },
                      );
                    },
                    child: Transform.rotate(
                      angle: 0.7,
                      child: Icon(
                        Icons.attachment_rounded,
                        color: Colors.grey.shade600,
                        size: ResponsiveHelper.iconSize(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),


          SizedBox(width: ResponsiveHelper.width(10)),
          // Mic button
          GestureDetector(
            onTap: _startRecording,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mic,
                color: Colors.grey.shade700,
                size: ResponsiveHelper.iconSize(22),
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.width(10)),
          // Circular Blue Send button
          GestureDetector(
            onTap: _onSend,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.blue,
                    AppColors.darBlue,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
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
                      AppStrings.recording.tr,
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