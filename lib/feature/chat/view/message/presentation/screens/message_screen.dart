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

import 'package:platchatapp/feature/chat/view/message/controller/message_controller.dart';
import 'package:platchatapp/share/widgets/avatar/user_avatar.dart';
import 'package:platchatapp/share/widgets/dialog/action_confirm_dialog.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';

class MessageScreen extends StatefulWidget {
  final String? roomId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String receiverId;
  final bool? isBlockedByMe;
  final bool? isBlockedMe;
  final bool? isVehicleVerified;
  final bool voiceAutoSend;
  final String? voiceMessage;

  final bool isReceivedRequest;
  final bool isSendRequest;
  final String? requestId;
  final String? firstMessage;
  final String? licenceId;

  const MessageScreen({
    super.key,
    this.roomId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.receiverId,
    this.isBlockedByMe,
    this.isBlockedMe,
    this.isVehicleVerified,
    required this.voiceAutoSend,
    this.voiceMessage,
    this.isReceivedRequest = false,
    this.isSendRequest = false,
    this.requestId,
    this.firstMessage,
    this.licenceId,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final ScrollController _scrollController = ScrollController();

  final GroupController _groupController = Get.find<GroupController>();
  final ChatController chatController = Get.find<ChatController>();
  final MessageController messageController = Get.find<MessageController>();
  late String _currentRoomId;
  bool _isAccepted = true;

  final RxInt _selectedPresetIndex = (-1).obs;
  final RxString _selectedPresetId = ''.obs;
  final RxBool _isSendingRequest = false.obs;
  final RxBool _isRequestSent = false.obs;

  // Canonical request state from GET /chat/message-requests/{id}/thread —
  // used to decide sender-vs-receiver view from the real `actions` array
  // instead of trusting the isReceivedRequest/isSendRequest route extras.
  final Rxn<Map<String, dynamic>> _threadData = Rxn<Map<String, dynamic>>();
  final RxBool _isLoadingThread = false.obs;

  @override
  void initState() {
    super.initState();
    _currentRoomId = widget.roomId ?? '';
    _isAccepted = _currentRoomId
        .isEmpty; // Sender is accepted by default. Recipient has to accept message request.

    chatController.isBlockedByMe.value = widget.isBlockedByMe ?? false;
    chatController.isBlockedMe.value = widget.isBlockedMe ?? false;
    chatController.fetchPresetMessages();

    if (widget.requestId != null &&
        (widget.isReceivedRequest || widget.isSendRequest)) {
      _loadThread();
    }

    _initChat();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadThread() async {
    _isLoadingThread.value = true;
    final data = await messageController.fetchMessageRequestThread(widget.requestId!);
    if (!mounted) return;
    if (data != null) {
      _threadData.value = data;
    }
    _isLoadingThread.value = false;
  }

  /// Actions the backend says are valid for this request (e.g. ["ACCEPT",
  /// "REJECT","BLOCK"] for the receiver, ["WITHDRAW"] for the sender).
  /// Falls back to the route-extra flags while the thread is still loading
  /// or if the fetch failed, so the screen never gets stuck blank.
  List<String>? get _threadActions =>
      (_threadData.value?['actions'] as List?)?.cast<String>();

  bool get _isReceiverView =>
      _threadActions?.contains('ACCEPT') ?? widget.isReceivedRequest;

  String get _effectiveRequestId =>
      _threadData.value?['request']?['id']?.toString() ?? widget.requestId ?? '';

  String get _effectiveOtherUserName =>
      _threadData.value?['otherUser']?['nick_name']?.toString() ?? widget.otherUserName;

  String? get _effectiveOtherUserAvatar =>
      _threadData.value?['otherUser']?['avatar']?.toString() ?? widget.otherUserAvatar;

  String? get _effectiveLicenceId =>
      _threadData.value?['otherUser']?['licence_id']?.toString() ?? widget.licenceId;

  bool get _effectiveIsVehicleVerified =>
      _threadData.value?['otherUser']?['is_vehicle_verified'] as bool? ??
      widget.isVehicleVerified ??
      false;

  String get _effectiveFirstMessage {
    final messages = _threadData.value?['messages'] as List?;
    if (messages != null && messages.isNotEmpty) {
      final firstText = messages.first?['message']?.toString();
      if (firstText != null && firstText.isNotEmpty) return firstText;
    }
    return widget.firstMessage ?? '';
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
    if (widget.isReceivedRequest || widget.isSendRequest) {
      return Obx(() {
        // While the canonical /thread fetch is in flight, keep rendering
        // using the route-extra flags so the screen never sits blank.
        return _isReceiverView ? _buildReceiveRequestView() : _buildSendRequestView();
      });
    }

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
          AppStrings.deleteMessage.tr,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(16),
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        content: Text(
          AppStrings.areYouSureDeleteMessage.tr,
          style: GoogleFonts.poppins(
            fontSize: ResponsiveHelper.fontSize(14),
            color: Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppStrings.cancel.tr,
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
                    AppStrings.delete.tr,
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

  Widget _buildSendRequestView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                child: const Icon(Icons.chevron_left, color: Colors.black87, size: 22),
              ),
            ),
          ),
          title: Row(
            children: [
              UserAvatar(imagePath: _effectiveOtherUserAvatar ?? AppConst.unknown, radius: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _effectiveOtherUserName,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Image.asset(
                          _effectiveIsVehicleVerified
                              ? AssetsPath.verified
                              : AssetsPath.unverified,
                          width: ResponsiveHelper.iconSize(16),
                          height: ResponsiveHelper.iconSize(16),
                        ),
                      ],
                    ),
                    if (_effectiveLicenceId != null && _effectiveLicenceId!.isNotEmpty)
                      Text(
                        _effectiveLicenceId!,
                        style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 11),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    UserAvatar(imagePath: _effectiveOtherUserAvatar ?? AppConst.unknown, radius: 54),
                    const SizedBox(height: 16),
                    Text(
                      "You're not following this person",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Send a request to start a conversation.\nThey'll review your request before you can message each other.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 36),
                    Obx(() {
                      final presets = chatController.presetMessages
                          .where((p) => p.type.toUpperCase() == 'ALERT')
                          .toList();
                      if (presets.isEmpty) return const SizedBox.shrink();

                      return Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        children: List.generate(presets.length, (index) {
                          final preset = presets[index];
                          final text = Get.locale?.languageCode == 'it' ? preset.messageIt : preset.message;
                          final isSelected = _selectedPresetIndex.value == index;

                          return GestureDetector(
                            onTap: () {
                              if (_selectedPresetIndex.value == index) {
                                _selectedPresetIndex.value = -1;
                                _selectedPresetId.value = '';
                              } else {
                                _selectedPresetIndex.value = index;
                                _selectedPresetId.value = preset.id;
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.blue.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected ? AppColors.blue : Colors.white.withValues(alpha: 0.8),
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                text,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? AppColors.blue : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom action card matching Image 1
            Obx(() {
              // A requestId means we opened an existing (already-sent) request
              // from the Sent Requests list — not a fresh compose from search,
              // which starts with no requestId at all.
              final bool isAlreadySent =
                  _isRequestSent.value || _effectiveRequestId.isNotEmpty;

              if (isAlreadySent) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Request Sent",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Your request has been sent to $_effectiveOtherUserName. They will review it before you can start messaging.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.access_time_rounded, color: Color(0xFFD97706), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "Pending Review",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFB45309),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_effectiveRequestId.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: () {
                            ActionConfirmDialog.show(
                              context,
                              title: 'Withdraw request?',
                              message:
                                  "Withdraw your message request to $_effectiveOtherUserName?",
                              confirmLabel: AppStrings.withdraw.tr,
                              icon: Icons.undo_rounded,
                              iconColor: const Color(0xFFB02517),
                              confirmGradient: const LinearGradient(
                                colors: [Color(0xFFB02517), Color(0xFF7A1C15)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              onConfirm: () async {
                                final success = await messageController.withdrawMessageRequest(
                                  requestId: _effectiveRequestId,
                                  context: context,
                                );
                                if (success && context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                            );
                          },
                          child: Text(
                            "Withdraw Request",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFB02517),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Send a request to $_effectiveOtherUserName?",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "$_effectiveOtherUserName will review your request. If accepted, you'll be able to message each other and see activity status and read receipts.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F5F9),
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0062E0), Color(0xFF014495)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: ElevatedButton(
                              onPressed: _isSendingRequest.value
                                  ? null
                                  : () async {
                                      _isSendingRequest.value = true;

                                      final success = await chatController.createMessageRequest(
                                        receiverId: widget.receiverId,
                                        presetMessageId: _selectedPresetId.value.isNotEmpty
                                            ? _selectedPresetId.value
                                            : null,
                                        context: context,
                                      );

                                      _isSendingRequest.value = false;
                                      if (success) {
                                        _isRequestSent.value = true;
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: _isSendingRequest.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      "Send Request",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiveRequestView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                child: const Icon(Icons.chevron_left, color: Colors.black87, size: 22),
              ),
            ),
          ),
          title: Row(
            children: [
              UserAvatar(imagePath: _effectiveOtherUserAvatar ?? AppConst.unknown, radius: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _effectiveOtherUserName,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Image.asset(
                          _effectiveIsVehicleVerified
                              ? AssetsPath.verified
                              : AssetsPath.unverified,
                          width: ResponsiveHelper.iconSize(16),
                          height: ResponsiveHelper.iconSize(16),
                        ),
                      ],
                    ),
                    if (_effectiveLicenceId != null && _effectiveLicenceId!.isNotEmpty)
                      Text(
                        _effectiveLicenceId!,
                        style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 11),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "Today",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Message Bubble
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      UserAvatar(imagePath: _effectiveOtherUserAvatar ?? AppConst.unknown, radius: 16),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(18),
                              topRight: Radius.circular(18),
                              bottomRight: Radius.circular(18),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _effectiveFirstMessage.isNotEmpty
                                    ? _effectiveFirstMessage
                                    : 'Your vehicle is blocking my spot.',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  '7:30 PM',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom action card matching Image 2
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Accept request from $_effectiveOtherUserName?",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "If you accept, they will also be able to message you and see info, such as your activity status and when you've read messages.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Block button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ActionConfirmDialog.show(
                              context,
                              title: 'Block $_effectiveOtherUserName?',
                              message:
                                  "They won't be able to message you or find your profile again.",
                              confirmLabel: AppStrings.block.tr,
                              icon: Icons.block_rounded,
                              iconColor: const Color(0xFF7A1C15),
                              confirmGradient: const LinearGradient(
                                colors: [Color(0xFF7A1C15), Color(0xFF4A0F0A)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              onConfirm: () async {
                                if (_effectiveRequestId.isNotEmpty) {
                                  await messageController.blockMessageRequest(
                                    requestId: _effectiveRequestId,
                                    context: context,
                                  );
                                } else {
                                  await chatController.block(widget.receiverId, context);
                                }
                                if (context.mounted) Navigator.pop(context);
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7A1C15),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "Block",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Reject button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ActionConfirmDialog.show(
                              context,
                              title: 'Reject request?',
                              message:
                                  "Reject the message request from $_effectiveOtherUserName?",
                              confirmLabel: AppStrings.reject.tr,
                              icon: Icons.cancel_outlined,
                              iconColor: const Color(0xFFB02517),
                              confirmGradient: const LinearGradient(
                                colors: [Color(0xFFB02517), Color(0xFF7A1C15)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              onConfirm: () async {
                                if (_effectiveRequestId.isNotEmpty) {
                                  await messageController.rejectMessageRequest(
                                    requestId: _effectiveRequestId,
                                    context: context,
                                  );
                                }
                                if (context.mounted) Navigator.pop(context);
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB02517),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "Reject",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Accept button
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0062E0), Color(0xFF014495)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              ActionConfirmDialog.show(
                                context,
                                title: 'Accept request?',
                                message:
                                    "Accept the message request from $_effectiveOtherUserName? You'll be able to message each other.",
                                confirmLabel: AppStrings.accept.tr,
                                icon: Icons.check_circle_outline_rounded,
                                iconColor: AppColors.blue,
                                onConfirm: () async {
                                  if (_effectiveRequestId.isNotEmpty) {
                                    await messageController.acceptMessageRequest(
                                      requestId: _effectiveRequestId,
                                      context: context,
                                    );
                                  }
                                  if (context.mounted) Navigator.pop(context);
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              "Accept",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

