// widgets/group_message_input.dart

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/chat/view/group/presentation/widgets/group_preset.dart';

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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // + icon — container এর বাইরে, বামে
              GestureDetector(
                onTap: () {},
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

              // Input container — মাঝখানে expand হবে
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
                          controller: widget.controller.messageController,
                          minLines: 1,
                          maxLines: 3,
                          onTap: () {
                            if (_isEmojiVisible) {
                              setState(() => _isEmojiVisible = false);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: "type_here".tr,
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