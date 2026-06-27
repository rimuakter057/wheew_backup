import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/widgets/message_appbar.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/widgets/message_double.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/widgets/message_input.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/widgets/rating_dialog.dart';
import 'package:platchatapp/feature/chat/view/widgets/block_by_me_widget.dart';
import 'package:platchatapp/feature/chat/view/widgets/block_me_widget.dart';
import 'package:platchatapp/feature/chat/view/widgets/message_screen_shimmer.dart';
import 'package:platchatapp/feature/scan/presentation/widget/profile_card.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import '../../../group/controller/group_controller.dart';

class MessageScreen extends StatefulWidget {
  final String? roomId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String receiverId;
  final bool? isBlockedByMe;
  final bool? isBlockedMe;
  final bool voiceAutoSend;
  final String? voiceMessage;

  const MessageScreen({
    super.key,
    this.roomId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.receiverId,
    this.isBlockedByMe,
    this.isBlockedMe,
    required this.voiceAutoSend,
    this.voiceMessage,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
 // final ChatController chatController = Get.put(ChatController());
  final ScrollController _scrollController = ScrollController();

  final GroupController _groupController = Get.find<GroupController>();
  final ChatController chatController = Get.find<ChatController>();
  late String _currentRoomId;



  @override
  void initState() {
    super.initState();
    _currentRoomId = widget.roomId ?? '';

    chatController.isBlockedByMe.value = widget.isBlockedByMe ?? false;
    chatController.isBlockedMe.value = widget.isBlockedMe ?? false;
    chatController.fetchPresetMessages();

    // ❌ এটা থাকলে সরাও — controller এ already আছে
    // chatController.newMessage();

    _initChat();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initChat() async {
    await Future.delayed(Duration.zero);
    chatController.userMessageList.clear();
    chatController.page.value = 1;
    chatController.roomID.value = widget.roomId ?? '';

    chatController.initSocketListeners();

    if (_currentRoomId.isNotEmpty) {
      chatController.fetchInboxMessage(roomId: _currentRoomId, refresh: true);
      // ✅ screen খুললেই সব message পড়া হিসেবে mark করো
      chatController.markMessagesAsRead(roomId: _currentRoomId);
    }

    // ── Voice auto-send ──
    if (widget.voiceAutoSend &&
        widget.voiceMessage != null &&
        widget.voiceMessage!.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 800));
      chatController.sendNewEmitMessage(
        receiverId: widget.receiverId,
        message: widget.voiceMessage!,
        roomId: _currentRoomId,
      );
      // roomId update after first message
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_currentRoomId.isEmpty && chatController.roomID.value.isNotEmpty) {
          if (mounted) {
            setState(() => _currentRoomId = chatController.roomID.value);
          }
        }
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200 &&
        chatController.hasMoreMessage &&
        !chatController.isLoadingMoreMessage.value) {
      final roomId = _currentRoomId.isNotEmpty
          ? _currentRoomId
          : chatController.roomID.value;
      if (roomId.isNotEmpty) {
        chatController.fetchInboxMessage(roomId: roomId);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    chatController.roomID.value = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        top: true,
        bottom: true,
        child: RefreshIndicator(
          onRefresh: () =>
              chatController.fetchInboxMessage(roomId: widget.roomId),
          child: Column(
            children: [
              SizedBox(height: ResponsiveHelper.height(20)),

              // ── App Bar ──────────────────────────────────────
              MessageAppBar(
                otherUserName: widget.otherUserName,
                otherUserAvatar: widget.otherUserAvatar,
                receiverId: widget.receiverId,
                chatController: chatController,
                onRateTap: () async {
                  await chatController.fetchMyRating(widget.receiverId);
                  if (!context.mounted) return;
                  showRatingDialog(
                    context: context,
                    status: chatController.myRatingForRatee.value?.status ?? '',
                    image: widget.otherUserAvatar ?? '',
                    name: widget.otherUserName,
                    receiverId: widget.receiverId,
                  );
                },

                onProfileTap: () async {
                  await _groupController.fetchUserProfile(widget.receiverId);
                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    builder: (dialogContext) => Obx(() {
                      // ← context আলাদা করো
                      final profile = _groupController.viewedProfile.value;
                      final isLoading = _groupController.isLoadingProfile.value;
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : profile == null
                            ? Center(child: Text('profile_not_found'.tr))
                            : ProfileCard(
                                name: profile.nickName,
                                rating: profile.rating,
                          image:widget.otherUserAvatar ?? '',
                          showRating: true,
                                onRatingTap: () async {
                                  Navigator.pop(
                                    dialogContext,
                                  ); // ← dialogContext দিয়ে বন্ধ করো
                                  await chatController.fetchMyRating(
                                    widget.receiverId,
                                  );
                                  if (!context.mounted) return;
                                  showRatingDialog(
                                    context: context,
                                    status:
                                        chatController
                                            .myRatingForRatee
                                            .value
                                            ?.status ??
                                        '',
                                    image: widget.otherUserAvatar ?? '',
                                    name: widget.otherUserName,
                                    receiverId: widget.receiverId,
                                  );
                                },
                              ),
                      );
                    }),
                  );
                },
              ),

              // ── Messages List ────────────────────────────────
              Expanded(
                child: Obx(() {
                  final messages = chatController.userMessageList;

                  if (chatController.isLoadingMessage.value && messages.isEmpty) {
                    return MessageScreenShimmer();
                  }

                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'no_messages_yet'.tr,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: ResponsiveHelper.symmetric(
                      horizontal: ResponsiveHelper.width(16),
                      vertical: ResponsiveHelper.height(8),
                    ),
                    itemCount:
                        messages.length + (chatController.hasMoreMessage ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Pagination loader
                      if (index == messages.length) {
                        return Obx(
                          () => chatController.isLoadingMoreMessage.value
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        );
                      }

                      final msg = messages[index];
                      final bool isMine = msg.isMine == true;

                      return MessageBubble(
                        message: msg.message ?? '',
                        isMine: isMine,
                        type: msg.type,
                        fileUrl: msg.fileUrl,
                        // ✅ read receipt ticks
                        isRead: msg.isRead,
                        fileName: msg.fileName,         // file_name

                        fileSize: msg.fileSize,         // file_size
                        isDelivered: msg.isDelivered,
                      );
                    },
                  );
                }),
              ),

              // ── Input / Block Widgets ─────────────────────────
              Obx(() {
                if (chatController.isBlockedByMe.value) {
                  return BlockByMeWidget(
                    name: widget.otherUserName,
                    onUnblock: () {
                      chatController.unBlock(widget.receiverId, context);
                      chatController.isBlockedByMe.value = false;
                    },
                  );
                } else if (chatController.isBlockedMe.value) {
                  return const BlockMeWidget();
                } else {
                  return MessageInput(
                    chatController: chatController,
                    currentRoomId: _currentRoomId,
                    receiverId: widget.receiverId,
                    onRoomIdUpdate: (newId) {
                      setState(() => _currentRoomId = newId);
                    },

                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
