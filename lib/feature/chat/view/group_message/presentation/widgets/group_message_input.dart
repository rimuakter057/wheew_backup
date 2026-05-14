// widgets/group_message_input.dart

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/chat/view/group_message/presentation/widgets/group_preset.dart';

import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';


class GroupMessageInput extends StatefulWidget {
  final String roomId;
  final ChatController controller;

  const GroupMessageInput({
    super.key,
    required this.roomId,
    required this.controller,
  });

  @override
  State<GroupMessageInput> createState() => _GroupMessageInputState();
}

class _GroupMessageInputState extends State<GroupMessageInput> {
  bool _isEmojiVisible = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Preset Messages ───────────────────────────────
        GroupPresetMessages(controller: widget.controller),

        SizedBox(height: ResponsiveHelper.height(6)),

        // ── Text Field ────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(
            ResponsiveHelper.padding(16),
            ResponsiveHelper.padding(8),
            ResponsiveHelper.padding(16),
            ResponsiveHelper.padding(8),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.padding(8),
              vertical: ResponsiveHelper.padding(4),
            ),
            decoration: BoxDecoration(
              color: AppColors.greyShade,
              borderRadius:
              BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Emoji toggle button
                IconButton(
                  icon: const Icon(Icons.emoji_emotions,
                      color: AppColors.black),
                  onPressed: () {
                    _focusNode.unfocus();
                    setState(() => _isEmojiVisible = !_isEmojiVisible);
                  },
                ),

                // Text field
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    controller: widget.controller.messageController,
                    minLines: 1,
                    maxLines: 3,
                    onTap: () {
                      if (_isEmojiVisible) {
                        setState(() => _isEmojiVisible = false);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Type here...",
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
                  onTap: () {
                    final text =
                    widget.controller.messageController.text.trim();
                    if (text.isEmpty) return;
                    widget.controller.sendGroupMessage(
                      roomId: widget.roomId,
                      message: text,
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveHelper.padding(8)),
                    child: Icon(
                      Icons.send_rounded,
                      size: ResponsiveHelper.iconSize(24),
                      color: AppColors.blueClient,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Emoji Picker ──────────────────────────────────
        Offstage(
          offstage: !_isEmojiVisible,
          child: SizedBox(
            height: ResponsiveHelper.height(250),
            child: EmojiPicker(
              textEditingController: widget.controller.messageController,
              config: Config(
                height: ResponsiveHelper.height(250),
                emojiViewConfig: EmojiViewConfig(
                  columns: 7,
                  emojiSizeMax: 28,
                  verticalSpacing: 0,
                  horizontalSpacing: 0,
                  backgroundColor: Colors.white,
                  noRecents: Text(
                    'No recents yet',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.black26,
                    ),
                  ),
                ),
                categoryViewConfig: CategoryViewConfig(
                  initCategory: Category.SMILEYS,
                  indicatorColor: AppColors.blueClient,
                  iconColor: Colors.grey,
                  iconColorSelected: AppColors.blueClient,
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