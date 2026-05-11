// ignore_for_file: prefer_final_fields

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/custom_container/custom_container.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class GroupMessageScreen extends StatefulWidget {
  const GroupMessageScreen({super.key});

  @override
  State<GroupMessageScreen> createState() => _GroupMessageScreenState();
}

class _GroupMessageScreenState extends State<GroupMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isEmojiVisible = false;
  final FocusNode _focusNode = FocusNode();

  // Static dummy messages
  final List<Map<String, dynamic>> _messages = [
    {"text": "Hey everyone! 👋", "isMine": false, "sender": "Mike"},
    {"text": "Hello! How's it going?", "isMine": true, "sender": "Me"},
    {"text": "Ready for the trip?", "isMine": false, "sender": "Sara"},
    {"text": "Yes, absolutely! 🚗", "isMine": true, "sender": "Me"},
    {"text": "Great! See you all soon.", "isMine": false, "sender": "Mike"},
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          SizedBox(height: ResponsiveHelper.height(20)),

          // ── Header ────────────────────────────────────────
          CustomContainer(
            margin: EdgeInsets.all(ResponsiveHelper.padding(16)),
            vertical: ResponsiveHelper.padding(16),
            horizontal: ResponsiveHelper.padding(0),
            backgroundColor: AppColors.greyShade,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: AppColors.black),
                    ),
                    CircleAvatar(
                      radius: ResponsiveHelper.borderRadius(22),
                      backgroundColor: AppColors.blueClient.withOpacity(0.2),
                      child: Icon(
                        Icons.group,
                        color: AppColors.blueClient,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.spacing(12)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Our Group",
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveHelper.fontSize(16),
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          "5 members",
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveHelper.fontSize(12),
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ── Popup Menu ────────────────────────────
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppColors.black),
                  onSelected: (value) {
                    if (value == "InviteDrivers") {
                      context.pushNamed(RouteName.addMemberScreen);
                    } else if (value == "LeaveGroup") {
                      // TODO: Leave group
                    }
                  },
                  itemBuilder: (context) => [
                    // ── Invite Drivers ────────────────
                    PopupMenuItem<String>(
                      value: "InviteDrivers",
                      child: Row(
                        children: [
                          Icon(Icons.person_add_outlined, color: AppColors.black),
                          SizedBox(width: 8),
                          Text(
                            'Invite Drivers',
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveHelper.fontSize(14),
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Divider ───────────────────────
                    PopupMenuItem<String>(
                      enabled: false,
                      height: 1,
                      child: Divider(height: 1, color: Colors.grey.shade200),
                    ),

                    // ── Leave Group ───────────────────
                    PopupMenuItem<String>(
                      value: "LeaveGroup",
                      child: Row(
                        children: [
                          Icon(Icons.exit_to_app_outlined, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Leave Group',
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveHelper.fontSize(14),
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Messages List ─────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: ResponsiveHelper.symmetric(
                horizontal: ResponsiveHelper.width(16),
                vertical: ResponsiveHelper.height(8),
              ),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // reverse:true তে list উল্টো, তাই index উল্টাই
                final msg = _messages[_messages.length - 1 - index];
                final bool isMine = msg['isMine'] == true;
                final String sender = msg['sender'] ?? '';
                final String text = msg['text'] ?? '';

                return Align(
                  alignment:
                  isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isMine
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      // Sender name (only for others)
                      if (!isMine)
                        Padding(
                          padding: EdgeInsets.only(
                            left: ResponsiveHelper.width(4),
                            bottom: ResponsiveHelper.height(2),
                          ),
                          child: Text(
                            sender,
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveHelper.fontSize(11),
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      Container(
                        constraints: BoxConstraints(
                          maxWidth: ResponsiveHelper.width(272),
                        ),
                        margin: EdgeInsets.symmetric(
                          vertical: ResponsiveHelper.height(5),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveHelper.height(10),
                          horizontal: ResponsiveHelper.width(14),
                        ),
                        decoration: BoxDecoration(
                          color: isMine
                              ? AppColors.blueClient
                              : AppColors.greenClient,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                                ResponsiveHelper.borderRadius(15)),
                            topRight: Radius.circular(
                                ResponsiveHelper.borderRadius(15)),
                            bottomLeft: isMine
                                ? Radius.circular(
                                ResponsiveHelper.borderRadius(15))
                                : Radius.zero,
                            bottomRight: isMine
                                ? Radius.zero
                                : Radius.circular(
                                ResponsiveHelper.borderRadius(15)),
                          ),
                        ),
                        child: Text(
                          text,
                          style: GoogleFonts.poppins(color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── Message Input ─────────────────────────────────
          _messageInput(),
        ],
      ),
    );
  }

  Widget _messageInput() {
    final List<String> presetMessages = [
      "👋 Hello!",
      "How are you?",
      "Thank you 😊",
      "I'll be right back",
      "Okay, got it!",
      "Please wait...",
      "See you later!",
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Preset Messages ───────────────────────────────
        SizedBox(
          height: ResponsiveHelper.height(40),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.padding(16)),
            itemCount: presetMessages.length,
            separatorBuilder: (_, __) =>
                SizedBox(width: ResponsiveHelper.spacing(8)),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _messageController.text = presetMessages[index];
                  _messageController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _messageController.text.length),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.padding(14),
                    vertical: ResponsiveHelper.padding(8),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blueClient.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(20)),
                    border: Border.all(color: AppColors.blueClient, width: 1),
                  ),
                  child: Text(
                    presetMessages[index],
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(12),
                      color: AppColors.blueClient,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

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
              horizontal: ResponsiveHelper.padding(16),
              vertical: ResponsiveHelper.padding(8),
            ),
            decoration: BoxDecoration(
              color: AppColors.greyShade,
              borderRadius:
              BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions, color: AppColors.black),
                  onPressed: () {
                    _focusNode.unfocus();
                    setState(() => _isEmojiVisible = !_isEmojiVisible);
                  },
                ),
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _messageController,
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
                    ),
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: ResponsiveHelper.fontSize(16),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Static: just clear field
                    if (_messageController.text.trim().isEmpty) return;
                    setState(() {
                      _messages.add({
                        "text": _messageController.text.trim(),
                        "isMine": true,
                        "sender": "Me",
                      });
                      _messageController.clear();
                    });
                  },
                  child: Icon(
                    Icons.send_outlined,
                    size: 20,
                    color: AppColors.black,
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
              textEditingController: _messageController,
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
                        fontSize: 20, color: Colors.black26),
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