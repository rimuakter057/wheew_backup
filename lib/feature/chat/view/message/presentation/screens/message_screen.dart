import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import 'package:get/get.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';

import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/widgets/message_appbar.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/widgets/message_double.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/widgets/message_input.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/widgets/rating_dialog.dart';
import 'package:platchatapp/feature/chat/view/widgets/block_by_me_widget.dart';
import 'package:platchatapp/feature/chat/view/widgets/block_me_widget.dart';
import 'package:platchatapp/feature/chat/view/widgets/message_screen_shimmer.dart';
import 'package:platchatapp/feature/scan/presentation/widget/profile_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import '../../../group/controller/group_controller.dart';
import '../widgets/message_preset_chips.dart';

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
  final ScrollController _scrollController = ScrollController();

  final GroupController _groupController = Get.find<GroupController>();
  final ChatController chatController = Get.find<ChatController>();
  late String _currentRoomId;
  bool _isAccepted = true;

  @override
  void initState() {
    super.initState();
    _currentRoomId = widget.roomId ?? '';
    _isAccepted = _currentRoomId
        .isEmpty; // Sender is accepted by default. Recipient has to accept message request.

    chatController.isBlockedByMe.value = widget.isBlockedByMe ?? false;
    chatController.isBlockedMe.value = widget.isBlockedMe ?? false;
    chatController.fetchPresetMessages();

    _initChat();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initChat() async {
    await Future.delayed(Duration.zero);
    chatController.userMessageList.clear();
    chatController.page.value = 1;
    chatController.roomID.value = widget.roomId ?? '';

    AppSocket.ensureConnected();
    chatController.initSocketListeners();

    if (_currentRoomId.isNotEmpty) {
      // fetchInboxMessage এর ভেতরেই message-read socket emit হয়
      // messages load হওয়ার পরে — তাই এখানে আলাদা markMessagesAsRead() দরকার নেই
      chatController.fetchInboxMessage(roomId: _currentRoomId, refresh: true);
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

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryBackgroundGradient,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,

        appBar: MessageAppBar(
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
                final profile = _groupController.viewedProfile.value;
                final isLoading = _groupController.isLoadingProfile.value;
                return Dialog(
                  backgroundColor: Colors.transparent,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : profile == null
                      ? Center(child: Text(AppStrings.profileNotFound.tr))
                      : ProfileCard(
                    profile: profile,
                    name: profile.nickName ?? "",
                    rating: profile.rating,
                    image: widget.otherUserAvatar ?? '',
                    showRating: true,
                    onRatingTap: () async {
                      Navigator.pop(dialogContext);
                      await chatController.fetchMyRating(widget.receiverId);
                      if (!context.mounted) return;
                      showRatingDialog(
                        context: context,
                        status:
                        chatController.myRatingForRatee.value?.status ??
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

        // ── Body: Column with message list and bottom input ──────
        body: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            children: [
              // ── Message list ────────────────────────────────
              Expanded(
                child: Obx(() {
                  final messages = chatController.userMessageList;
                  final bool showTyping = chatController.isTyping.value;

                  if (chatController.isLoadingMessage.value && messages.isEmpty) {
                    return MessageScreenShimmer();
                  }

                  if (messages.isEmpty && !showTyping) {
                    return RefreshIndicator(
                      onRefresh: () =>
                          chatController.fetchInboxMessage(roomId: widget.roomId),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: Center(
                              child: Text(
                                AppStrings.noMessagesYet.tr,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        chatController.fetchInboxMessage(roomId: widget.roomId),
                    child: ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: ResponsiveHelper.symmetric(
                        horizontal: ResponsiveHelper.width(16),
                        vertical: ResponsiveHelper.height(8),
                      ),
                      itemCount: messages.length +
                          (chatController.hasMoreMessage ? 1 : 0) +
                          (showTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (showTyping && index == 0) {
                          return _buildTypingIndicatorBubble();
                        }
                        final msgIndex = showTyping ? index - 1 : index;

                        if (msgIndex == messages.length) {
                          return Obx(
                                () => chatController.isLoadingMoreMessage.value
                                ? Padding(
                              padding: ResponsiveHelper.all(12),
                              child: const Center(child: CircularProgressIndicator()),
                            )
                                : const SizedBox.shrink(),
                          );
                        }

                        final msg = messages[msgIndex];
                        final bool isMine = msg.isMine == true;

                        return GestureDetector(
                          onLongPress: () {
                            if (isMine && msg.id != null) {
                              _showDeleteMessageDialog(context, msg.id!);
                            }
                          },
                          child: MessageBubble(
                            message: msg.message ?? '',
                            isMine: isMine,
                            type: msg.type,
                            fileUrl: msg.fileUrl,
                            isRead: msg.isRead,
                            fileName: msg.fileName,
                            fileSize: msg.fileSize,
                            fileMimeType: msg.fileMimeType,
                            durationSeconds: msg.durationSeconds,
                            isDelivered: msg.isDelivered,
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),

              Obx(() {
                if (chatController.isBlockedByMe.value ||
                    chatController.isBlockedMe.value) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(bottom: ResponsiveHelper.padding(8)),
                  child: MessagePresetChips(chatController: chatController),
                );
              }),

              // ── Bottom: Input / Block Widgets ──────────────────────
              Container(
                color: const Color(0xFFF1F5F9),
                child: SafeArea(
                  top: false,
                  bottom: true,
                  child: Obx(() {
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
                ),
              ),
            ],
          ),
        ),
      ),
    );


  }

  Widget _buildTypingIndicatorBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: ResponsiveHelper.symmetric(vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: ResponsiveHelper.borderRadius(16),
              backgroundImage: NetworkImage(
                ImageHandler.imagesHandle(
                  widget.otherUserAvatar,
                  isProfile: true,
                ),
              ),
            ),
            SizedBox(width: ResponsiveHelper.spacing(8)),
            Container(
              padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ResponsiveHelper.borderRadius(15)),
                  topRight: Radius.circular(ResponsiveHelper.borderRadius(15)),
                  bottomRight: Radius.circular(ResponsiveHelper.borderRadius(15)),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDot(0),
                  SizedBox(width: ResponsiveHelper.spacing(3)),
                  _buildDot(1),
                  SizedBox(width: ResponsiveHelper.spacing(3)),
                  _buildDot(2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return _AnimatedDot(delayMs: index * 150);
  }

  void _showDeleteMessageDialog(BuildContext context, String messageId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
        ),
        title: Text(
          'Delete Message',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(16),
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this message?',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(14),
            color: Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveHelper.fontSize(14),
                color: Colors.grey,
              ),
            ),
          ),
          Obx(() => TextButton(
            onPressed: chatController.isDeletingMessage.value
                ? null
                : () async {
                    final success = await chatController.deleteMessageApi(
                      messageId: messageId,
                      context: context,
                    );
                    if (success) {
                      Navigator.pop(ctx);
                    }
                  },
            child: chatController.isDeletingMessage.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                  )
                : Text(
                    'Delete',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveHelper.fontSize(14),
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          )),
        ],
      ),
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  final int delayMs;
  const _AnimatedDot({required this.delayMs});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFF6A6969),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

