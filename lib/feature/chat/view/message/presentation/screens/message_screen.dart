import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import 'package:get/get.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
import 'package:platchatapp/helper/data_converter/data_converter.dart';

import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/widgets/message_appbar.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/widgets/message_double.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/widgets/message_input.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/widgets/rating_dialog.dart';
import 'package:platchatapp/feature/chat/view/widgets/block_by_me_widget.dart';
import 'package:platchatapp/feature/chat/view/widgets/block_me_widget.dart';
import 'package:platchatapp/feature/chat/view/widgets/chat_date_divider.dart';
import 'package:platchatapp/feature/chat/view/widgets/message_screen_shimmer.dart';
import 'package:platchatapp/feature/scan/presentation/widget/profile_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/helper/custom_gradient_button/custom_gradient_button.dart';
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

  final RxInt _selectedPresetIndex = (-1).obs;
  final RxString _selectedPresetId = ''.obs;
  final RxBool _isSendingRequest = false.obs;
  final RxBool _isRequestSent = false.obs;

  final RxBool _requestAccepted = false.obs;

  final Rxn<Map<String, dynamic>> _threadData =
  Rxn<Map<String, dynamic>>();

  final RxBool _isLoadingThread = false.obs;

  // ------------------------------------------------------------
  // Responsive helpers
  // ------------------------------------------------------------

  bool _isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  double _requestAvatarRadius(BuildContext context) {
    return _isLandscape(context) ? 38 : 54;
  }

  double _requestTopSpacing(BuildContext context) {
    return _isLandscape(context) ? 8 : 20;
  }

  double _requestSectionSpacing(BuildContext context) {
    return _isLandscape(context) ? 6 : 16;
  }

  double _actionCardTopPadding(BuildContext context) {
    return _isLandscape(context) ? 12 : 20;
  }

  double _actionCardBottomPadding(BuildContext context) {
    return _isLandscape(context) ? 14 : 28;
  }

  double _actionCardVerticalSpacing(BuildContext context) {
    return _isLandscape(context) ? 10 : 20;
  }

  @override
  void initState() {
    super.initState();

    _currentRoomId = widget.roomId ?? '';

    chatController.isBlockedByMe.value =
        widget.isBlockedByMe ?? false;

    chatController.isBlockedMe.value =
        widget.isBlockedMe ?? false;

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

    final data = await messageController
        .fetchMessageRequestThread(widget.requestId!);

    if (!mounted) return;

    if (data != null) {
      _threadData.value = data;
    }

    _isLoadingThread.value = false;
  }

  List<String>? get _threadActions =>
      (_threadData.value?['actions'] as List?)?.cast<String>();

  bool get _isReceiverView =>
      _threadActions?.contains('ACCEPT') ??
          widget.isReceivedRequest;

  String get _effectiveRequestId =>
      _threadData.value?['request']?['id']?.toString() ??
          widget.requestId ??
          '';

  String get _effectiveOtherUserName =>
      _threadData.value?['otherUser']?['nick_name']?.toString() ??
          widget.otherUserName;

  String? get _effectiveOtherUserAvatar =>
      _threadData.value?['otherUser']?['avatar']?.toString() ??
          widget.otherUserAvatar;

  String? get _effectiveLicenceId =>
      _threadData.value?['otherUser']?['licence_id']?.toString() ??
          widget.licenceId;

  bool get _effectiveIsVehicleVerified =>
      _threadData.value?['otherUser']?['is_vehicle_verified'] as bool? ??
          widget.isVehicleVerified ??
          false;

  String get _effectiveFirstMessage {
    final messages =
    _threadData.value?['messages'] as List?;

    if (messages != null && messages.isNotEmpty) {
      final firstText =
      messages.first?['message']?.toString();

      if (firstText != null && firstText.isNotEmpty) {
        return firstText;
      }
    }

    return widget.firstMessage ?? '';
  }

  bool get _effectiveIsMine {
    final messages =
    _threadData.value?['messages'] as List?;

    if (messages != null && messages.isNotEmpty) {
      final isMineRaw =
      messages.first?['is_mine'];

      if (isMineRaw is bool) {
        return isMineRaw;
      }
    }

    return !_isReceiverView;
  }

  Future<void> _initChat() async {
    await Future.delayed(Duration.zero);

    chatController.userMessageList.clear();
    chatController.page.value = 1;
    chatController.roomID.value =
        widget.roomId ?? '';

    AppSocket.ensureConnected();
    chatController.initSocketListeners();

    if (_currentRoomId.isNotEmpty) {
      chatController.fetchInboxMessage(
        roomId: _currentRoomId,
        refresh: true,
      );
    }

    if (widget.voiceAutoSend &&
        widget.voiceMessage != null &&
        widget.voiceMessage!.isNotEmpty) {
      await Future.delayed(
        const Duration(milliseconds: 800),
      );

      chatController.sendNewEmitMessage(
        receiverId: widget.receiverId,
        message: widget.voiceMessage!,
        roomId: _currentRoomId,
      );

      Future.delayed(
        const Duration(milliseconds: 500),
            () {
          if (_currentRoomId.isEmpty &&
              chatController.roomID.value.isNotEmpty) {
            if (mounted) {
              setState(
                    () => _currentRoomId =
                    chatController.roomID.value,
              );
            }
          }
        },
      );
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final pos = _scrollController.position;

    if (pos.pixels >=
        pos.maxScrollExtent - 200 &&
        chatController.hasMoreMessage &&
        !chatController.isLoadingMoreMessage.value) {
      final roomId =
      _currentRoomId.isNotEmpty
          ? _currentRoomId
          : chatController.roomID.value;

      if (roomId.isNotEmpty) {
        chatController.fetchInboxMessage(
          roomId: roomId,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    // Snapshot the current messages (including anything sent/received
    // during this session) to the local cache before leaving, so re-
    // entering this room later shows them instantly instead of a stale
    // cache flash that only self-corrects after the network fetch lands.
    final roomId = _currentRoomId.isNotEmpty
        ? _currentRoomId
        : chatController.roomID.value;
    if (roomId.isNotEmpty) {
      chatController.persistMessageCache(roomId);
    }

    chatController.roomID.value = '';

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isReceivedRequest ||
        widget.isSendRequest) {
      return Obx(() {
        if (_requestAccepted.value) {
          return _buildChatScaffold(context);
        }

        return _isReceiverView
            ? _buildReceiveRequestView()
            : _buildSendRequestView();
      });
    }

    return _buildChatScaffold(context);
  }

  // ============================================================
  // NORMAL CHAT
  // ============================================================

  Widget _buildChatScaffold(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryBackgroundGradient,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.transparent,
        appBar: MessageAppBar(
          otherUserName: widget.otherUserName,
          otherUserAvatar: widget.otherUserAvatar,
          receiverId: widget.receiverId,
          chatController: chatController,
          licenceId: widget.licenceId,
          isVerified: widget.isVehicleVerified,
          onRateTap: () async {
            await chatController.fetchMyRating(
              widget.receiverId,
            );

            if (!context.mounted) return;

            showRatingDialog(
              context: context,
              status:
              chatController.myRatingForRatee.value
                  ?.status ??
                  '',
              image: widget.otherUserAvatar ?? '',
              name: widget.otherUserName,
              receiverId: widget.receiverId,
              isVerified:
              _effectiveIsVehicleVerified,
            );
          },
          onProfileTap: () async {
            await _groupController.fetchUserProfile(
              widget.receiverId,
            );

            if (!context.mounted) return;

            showDialog(
              context: context,
              builder: (dialogContext) =>
                  Obx(() {
                    final profile =
                        _groupController
                            .viewedProfile
                            .value;

                    final isLoading =
                        _groupController
                            .isLoadingProfile
                            .value;

                    return Dialog(
                      backgroundColor:
                      AppColors.transparent,
                      child: isLoading
                          ? const Center(
                        child:
                        CircularProgressIndicator(),
                      )
                          : profile == null
                          ? Center(
                        child: Text(
                          AppStrings
                              .profileNotFound
                              .tr,
                        ),
                      )
                          : ProfileCard(
                        profile: profile,
                        name:
                        profile.nickName ??
                            "",
                        rating: profile.rating,
                        image:
                        widget.otherUserAvatar ??
                            '',
                        showRating: true,
                        onRatingTap:
                            () async {
                          Navigator.pop(
                            dialogContext,
                          );

                          await chatController
                              .fetchMyRating(
                            widget.receiverId,
                          );

                          if (!context
                              .mounted) {
                            return;
                          }

                          showRatingDialog(
                            context: context,
                            status: chatController
                                .myRatingForRatee
                                .value
                                ?.status ??
                                '',
                            image:
                            widget.otherUserAvatar ??
                                '',
                            name:
                            widget.otherUserName,
                            receiverId:
                            widget.receiverId,
                            isVerified:
                            _effectiveIsVehicleVerified,
                          );
                        },
                      ),
                    );
                  }),
            );
          },
        ),
        body: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  final messages =
                      chatController.userMessageList;

                  final bool showTyping =
                      chatController.isTyping.value;

                  if (chatController
                      .isLoadingMessage
                      .value &&
                      messages.isEmpty) {
                    return MessageScreenShimmer();
                  }

                  if (messages.isEmpty &&
                      !showTyping) {
                    return RefreshIndicator(
                      onRefresh: () =>
                          chatController
                              .fetchInboxMessage(
                            roomId: widget.roomId,
                          ),
                      child: ListView(
                        physics:
                        const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height:
                            MediaQuery.of(context)
                                .size
                                .height *
                                0.4,
                            child: Center(
                              child: Text(
                                AppStrings
                                    .noMessagesYet
                                    .tr,
                                style:
                                const TextStyle(
                                  color:
                                  AppColors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        chatController
                            .fetchInboxMessage(
                          roomId: widget.roomId,
                        ),
                    child: ListView.builder(
                      controller:
                      _scrollController,
                      reverse: true,
                      padding:
                      ResponsiveHelper.symmetric(
                        horizontal:
                        ResponsiveHelper.width(
                          16,
                        ),
                        vertical:
                        ResponsiveHelper.height(
                          8,
                        ),
                      ),
                      itemCount:
                      messages.length +
                          (chatController
                              .hasMoreMessage
                              ? 1
                              : 0) +
                          (showTyping ? 1 : 0),
                      itemBuilder:
                          (context, index) {
                        if (showTyping &&
                            index == 0) {
                          return _buildTypingIndicatorBubble();
                        }

                        final msgIndex =
                        showTyping
                            ? index - 1
                            : index;

                        if (msgIndex ==
                            messages.length) {
                          return Obx(
                                () =>
                            chatController
                                .isLoadingMoreMessage
                                .value
                                ? Padding(
                              padding:
                              ResponsiveHelper
                                  .all(
                                12,
                              ),
                              child:
                              const Center(
                                child:
                                CircularProgressIndicator(),
                              ),
                            )
                                : const SizedBox
                                .shrink(),
                          );
                        }

                        final msg =
                        messages[msgIndex];

                        final bool isMine =
                            msg.isMine == true;

                        final String
                        formattedTime =
                        formatTime(
                          msg.createdAt ?? '',
                        );

                        final bool isFirstMessageOfDay =
                            msgIndex == messages.length - 1 ||
                                DateConverter.isDifferentDay(
                                  msg.createdAt,
                                  messages[msgIndex + 1].createdAt,
                                );

                        final String dateHeader = isFirstMessageOfDay
                            ? DateConverter.formatChatDateHeader(msg.createdAt)
                            : '';

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (isFirstMessageOfDay && dateHeader.isNotEmpty)
                              ChatDateDivider(text: dateHeader),
                            GestureDetector(
                              onLongPress: () {
                                if (isMine &&
                                    msg.id != null) {
                                  _showDeleteMessageDialog(
                                    context,
                                    msg.id!,
                                  );
                                }
                              },
                              child: MessageBubble(
                                message:
                                msg.message ?? '',
                                isMine: isMine,
                                type: msg.type,
                                fileUrl: msg.fileUrl,
                                isRead: msg.isRead,
                                fileName: msg.fileName,
                                fileSize: msg.fileSize,
                                fileMimeType:
                                msg.fileMimeType,
                                durationSeconds:
                                msg.durationSeconds,
                                isDelivered:
                                msg.isDelivered,
                                time: formattedTime
                                    .isNotEmpty
                                    ? formattedTime
                                    : '0:00 PM',
                                avatarUrl:
                                widget.otherUserAvatar,
                                isSending: msg.isSending,
                                localFilePath: msg.localFilePath,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }),
              ),

              Obx(() {
                if (chatController
                    .isBlockedByMe.value ||
                    chatController
                        .isBlockedMe.value) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: EdgeInsets.only(
                    bottom:
                    ResponsiveHelper.padding(
                      8,
                    ),
                  ),
                  child: MessagePresetChips(
                    chatController:
                    chatController,
                  ),
                );
              }),

              Container(
                color: const Color(0xFFF1F5F9),
                child: SafeArea(
                  top: false,
                  bottom: true,
                  child: Obx(() {
                    if (chatController
                        .isBlockedByMe.value) {
                      return BlockByMeWidget(
                        name:
                        widget.otherUserName,
                        onUnblock: () {
                          chatController.unBlock(
                            widget.receiverId,
                            context,
                          );

                          chatController
                              .isBlockedByMe
                              .value = false;
                        },
                      );
                    } else if (chatController
                        .isBlockedMe.value) {
                      return const BlockMeWidget();
                    }

                    return MessageInput(
                      chatController:
                      chatController,
                      currentRoomId:
                      _currentRoomId,
                      receiverId:
                      widget.receiverId,
                      onRoomIdUpdate:
                          (newId) {
                        setState(
                              () => _currentRoomId =
                              newId,
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TYPING INDICATOR
  // ============================================================

  Widget _buildTypingIndicatorBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding:
        ResponsiveHelper.symmetric(
          vertical: 6.0,
        ),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius:
              ResponsiveHelper.borderRadius(
                16,
              ),
              backgroundImage: NetworkImage(
                ImageHandler.imagesHandle(
                  widget.otherUserAvatar,
                  isProfile: true,
                ),
              ),
            ),
            SizedBox(
              width:
              ResponsiveHelper.spacing(
                8,
              ),
            ),
            Container(
              padding:
              ResponsiveHelper.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius:
                BorderRadius.only(
                  topLeft: Radius.circular(
                    ResponsiveHelper
                        .borderRadius(15),
                  ),
                  topRight: Radius.circular(
                    ResponsiveHelper
                        .borderRadius(15),
                  ),
                  bottomRight:
                  Radius.circular(
                    ResponsiveHelper
                        .borderRadius(15),
                  ),
                ),
              ),
              child: Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  _buildDot(0),
                  SizedBox(
                    width:
                    ResponsiveHelper
                        .spacing(3),
                  ),
                  _buildDot(1),
                  SizedBox(
                    width:
                    ResponsiveHelper
                        .spacing(3),
                  ),
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
    return _AnimatedDot(
      delayMs: index * 150,
    );
  }

  // ============================================================
  // DELETE MESSAGE
  // ============================================================

  void _showDeleteMessageDialog(
      BuildContext context,
      String messageId,
      ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
            ResponsiveHelper
                .borderRadius(16),
          ),
        ),
        title: Text(
          AppStrings.deleteMessage.tr,
          style: GoogleFonts.poppins(
            fontSize:
            ResponsiveHelper.fontSize(
              16,
            ),
            fontWeight:
            FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        content: Text(
          AppStrings
              .areYouSureDeleteMessage
              .tr,
          style: GoogleFonts.poppins(
            fontSize:
            ResponsiveHelper.fontSize(
              14,
            ),
            color:
            AppColors.greyShade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx),
            child: Text(
              AppStrings.cancel.tr,
              style: GoogleFonts.poppins(
                fontSize:
                ResponsiveHelper
                    .fontSize(14),
                color: AppColors.grey,
              ),
            ),
          ),
          Obx(
                () => TextButton(
              onPressed: chatController
                  .isDeletingMessage
                  .value
                  ? null
                  : () async {
                final success =
                await chatController
                    .deleteMessageApi(
                  messageId:
                  messageId,
                  context:
                  context,
                );

                if (success) {
                  Navigator.pop(
                    ctx,
                  );
                }
              },
              child: chatController
                  .isDeletingMessage
                  .value
                  ? const SizedBox(
                width: 16,
                height: 16,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color:
                  AppColors.red,
                ),
              )
                  : Text(
                AppStrings.delete.tr,
                style:
                GoogleFonts.poppins(
                  fontSize:
                  ResponsiveHelper
                      .fontSize(
                    14,
                  ),
                  color:
                  AppColors.red,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEND REQUEST VIEW
  // ============================================================

  Widget _buildSendRequestView() {
    final landscape = _isLandscape(context);

    return Container(
      decoration: const BoxDecoration(
        gradient:
        AppColors.primaryBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor:
        AppColors.transparent,
        appBar: AppBar(
          backgroundColor:
          AppColors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Center(
            child: GestureDetector(
              onTap: () =>
                  Navigator.of(context)
                      .pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration:
                BoxDecoration(
                  shape:
                  BoxShape.circle,
                  color: AppColors.white
                      .withValues(
                    alpha: 0.9,
                  ),
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color:
                  AppColors.black87,
                  size: 22,
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              UserAvatar(
                imagePath:
                _effectiveOtherUserAvatar ??
                    AppConst.unknown,
                radius: landscape
                    ? 16
                    : 18,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _effectiveOtherUserName,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            GoogleFonts.poppins(
                              color:
                              AppColors.black87,
                              fontWeight:
                              FontWeight.w700,
                              fontSize:
                              landscape
                                  ? 14
                                  : 15,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Image.asset(
                          _effectiveIsVehicleVerified
                              ? AssetsPath
                              .verified
                              : AssetsPath
                              .unverified,
                          width:
                          ResponsiveHelper
                              .iconSize(
                            16,
                          ),
                          height:
                          ResponsiveHelper
                              .iconSize(
                            16,
                          ),
                        ),
                      ],
                    ),
                    if (_effectiveLicenceId !=
                        null &&
                        _effectiveLicenceId!
                            .isNotEmpty)
                      Text(
                        _effectiveLicenceId!,
                        style:
                        GoogleFonts.poppins(
                          color: AppColors
                              .greyShade600,
                          fontSize:
                          landscape
                              ? 10
                              : 11,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // --------------------------------------------------------
        // IMPORTANT:
        // Bottom action card is Flexible + ScrollView.
        // This prevents landscape RenderFlex overflow.
        // --------------------------------------------------------

        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                final bool isAlreadySent =
                    _isRequestSent.value ||
                        _effectiveRequestId
                            .isNotEmpty;

                if (isAlreadySent) {
                  final presets =
                  chatController
                      .presetMessages
                      .where(
                        (p) => p.type
                        .toUpperCase() ==
                        'ALERT',
                  )
                      .toList();

                  final String sentText =
                  _effectiveFirstMessage
                      .isNotEmpty
                      ? _effectiveFirstMessage
                      : (_selectedPresetIndex
                      .value >=
                      0 &&
                      _selectedPresetIndex
                          .value <
                          presets.length
                      ? (Get.locale
                      ?.languageCode ==
                      'it'
                      ? presets[
                  _selectedPresetIndex
                      .value]
                      .messageIt
                      : presets[
                  _selectedPresetIndex
                      .value]
                      .message)
                      : '');

                  if (sentText.isEmpty) {
                    return const SizedBox
                        .shrink();
                  }

                  final bool isMine =
                      _effectiveIsMine;

                  return Padding(
                    padding:
                    EdgeInsets.symmetric(
                      horizontal:
                      landscape
                          ? 16
                          : 24,
                      vertical:
                      landscape
                          ? 8
                          : 16,
                    ),
                    child: Align(
                      alignment:
                      Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          Center(
                            child:
                            Container(
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal:
                                14,
                                vertical:
                                4,
                              ),
                              decoration:
                              BoxDecoration(
                                color: AppColors
                                    .white
                                    .withValues(
                                  alpha: 0.6,
                                ),
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  16,
                                ),
                              ),
                              child: Text(
                                AppStrings
                                    .today
                                    .tr,
                                style:
                                GoogleFonts
                                    .poppins(
                                  fontSize:
                                  12,
                                  color: AppColors
                                      .greyShade700,
                                  fontWeight:
                                  FontWeight
                                      .w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height:
                            landscape
                                ? 8
                                : 16,
                          ),
                          if (isMine)
                            MessageBubble(
                              message:
                              sentText,
                              isMine: true,
                            )
                          else
                            // MessageBubble already draws its own avatar for
                            // non-mine messages (via avatarUrl) — wrapping it
                            // in another Row+UserAvatar here rendered two
                            // avatars side by side.
                            MessageBubble(
                              message: sentText,
                              isMine: false,
                              avatarUrl: _effectiveOtherUserAvatar,
                            ),
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding:
                  EdgeInsets.symmetric(
                    horizontal:
                    landscape ? 16 : 24,
                    vertical:
                    landscape ? 6 : 16,
                  ),
                  // Scrollable instead of a hard overflow when the avatar +
                  // both texts + preset chips don't all fit in the space
                  // Expanded above leaves (short/landscape screens, or many
                  // presets wrapping to extra lines).
                  child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height:
                        _requestTopSpacing(
                          context,
                        ),
                      ),

                      UserAvatar(
                        imagePath:
                        _effectiveOtherUserAvatar ??
                            AppConst.unknown,
                        radius:
                        _requestAvatarRadius(
                          context,
                        ),
                      ),

                      SizedBox(
                        height:
                        _requestSectionSpacing(
                          context,
                        ),
                      ),

                      Text(
                        AppStrings
                            .youreNotFollowing
                            .tr,
                        textAlign:
                        TextAlign.center,
                        style:
                        GoogleFonts.poppins(
                          fontSize:
                          landscape
                              ? 17
                              : 20,
                          fontWeight:
                          FontWeight.w700,
                          color:
                          AppColors.black87,
                        ),
                      ),

                      SizedBox(
                        height:
                        landscape
                            ? 4
                            : 8,
                      ),

                      Text(
                        AppStrings
                            .sendRequestDesc
                            .tr,
                        textAlign:
                        TextAlign.center,
                        style:
                        GoogleFonts.poppins(
                          fontSize:
                          landscape
                              ? 11
                              : 12.5,
                          color:
                          AppColors
                              .greyShade600,
                          height:
                          1.35,
                        ),
                      ),

                      // A Spacer can't live inside the SingleChildScrollView
                      // above (needs bounded height, scroll views give
                      // unbounded) — fixed gap instead.
                      SizedBox(height: landscape ? 12 : 24),

                      Obx(() {
                        final presets =
                        chatController
                            .presetMessages
                            .where(
                              (p) =>
                          p.type
                              .toUpperCase() ==
                              'ALERT',
                        )
                            .toList();

                        if (presets.isEmpty) {
                          return const SizedBox
                              .shrink();
                        }

                        return Wrap(
                          spacing:
                          landscape
                              ? 6
                              : 8,
                          runSpacing:
                          landscape
                              ? 6
                              : 10,
                          alignment:
                          WrapAlignment
                              .center,
                          children:
                          List.generate(
                            presets.length,
                                (index) {
                              final preset =
                              presets[index];

                              final text =
                              Get.locale
                                  ?.languageCode ==
                                  'it'
                                  ? preset
                                  .messageIt
                                  : preset
                                  .message;

                              final isSelected =
                                  _selectedPresetIndex
                                      .value ==
                                      index;

                              return GestureDetector(
                                onTap: () {
                                  if (_selectedPresetIndex
                                      .value ==
                                      index) {
                                    _selectedPresetIndex
                                        .value = -1;

                                    _selectedPresetId
                                        .value = '';
                                  } else {
                                    _selectedPresetIndex
                                        .value = index;

                                    _selectedPresetId
                                        .value =
                                        preset.id;
                                  }
                                },
                                child:
                                Container(
                                  padding:
                                  EdgeInsets.symmetric(
                                    horizontal:
                                    landscape
                                        ? 12
                                        : 16,
                                    vertical:
                                    landscape
                                        ? 7
                                        : 10,
                                  ),
                                  decoration:
                                  BoxDecoration(
                                    color: isSelected
                                        ? AppColors
                                        .blue
                                        .withValues(
                                      alpha:
                                      0.15,
                                    )
                                        : AppColors
                                        .white
                                        .withValues(
                                      alpha:
                                      0.8,
                                    ),
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      24,
                                    ),
                                    border:
                                    Border.all(
                                      color: isSelected
                                          ? AppColors
                                          .blue
                                          : AppColors
                                          .white
                                          .withValues(
                                        alpha:
                                        0.8,
                                      ),
                                      width: 1.2,
                                    ),
                                  ),
                                  child:
                                  Text(
                                    text,
                                    style:
                                    GoogleFonts
                                        .poppins(
                                      fontSize:
                                      landscape
                                          ? 11
                                          : 12.5,
                                      fontWeight:
                                      isSelected
                                          ? FontWeight
                                          .w600
                                          : FontWeight
                                          .w500,
                                      color: isSelected
                                          ? AppColors
                                          .blue
                                          : AppColors
                                          .black87,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                  ),
                );
              }),
            ),

            // ==================================================
            // FIX:
            // A Flexible(loose) here — competing for flex space with
            // the Expanded above — gets a pre-allocated 50/50 share of
            // the free space regardless of how much the card actually
            // needs; whatever this card doesn't use is NOT handed back
            // to the Expanded sibling (Flutter's flex layout is single-
            // pass), so it shows up as dead space below the card
            // instead. A ConstrainedBox instead sizes to the card's own
            // natural height (so Expanded gets everything the card
            // isn't using), while still capping it so it can't overflow
            // on short/landscape screens — SingleChildScrollView lets
            // it scroll if content ever exceeds that cap.
            // ==================================================

            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                physics:
                const ClampingScrollPhysics(),
                child: Obx(() {
                  final bool isAlreadySent =
                      _isRequestSent.value ||
                          _effectiveRequestId
                              .isNotEmpty;

                  return Container(
                    padding:
                    EdgeInsets.fromLTRB(
                      20,
                      _actionCardTopPadding(
                        context,
                      ),
                      20,
                      _actionCardBottomPadding(
                        context,
                      ),
                    ),
                    decoration:
                    BoxDecoration(
                      gradient:
                      AppColors
                          .containerGradient,
                      borderRadius:
                      const BorderRadius
                          .vertical(
                        top:
                        Radius.circular(
                          28,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors
                              .black
                              .withValues(
                            alpha: 0.05,
                          ),
                          blurRadius: 20,
                          offset:
                          const Offset(
                            0,
                            -4,
                          ),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Text(
                          isAlreadySent
                              ? AppStrings
                              .requestSent
                              .tr
                              : AppStrings
                              .sendRequestTo
                              .tr
                              .replaceAll(
                            '@name',
                            _effectiveOtherUserName,
                          ),
                          textAlign:
                          TextAlign.center,
                          style:
                          GoogleFonts.poppins(
                            fontSize:
                            landscape
                                ? 14
                                : 16,
                            fontWeight:
                            FontWeight.w700,
                            color:
                            AppColors.black87,
                          ),
                        ),

                        SizedBox(
                          height:
                          landscape
                              ? 4
                              : 6,
                        ),

                        Text(
                          isAlreadySent
                              ? AppStrings
                              .requestSentDesc
                              .tr
                              .replaceAll(
                            '@name',
                            _effectiveOtherUserName,
                          )
                              : AppStrings
                              .requestSentDesc
                              .tr
                              .replaceAll(
                            '@name',
                            _effectiveOtherUserName,
                          ),
                          textAlign:
                          TextAlign.center,
                          style:
                          GoogleFonts.poppins(
                            fontSize:
                            landscape
                                ? 10.5
                                : 12,
                            color:
                            AppColors
                                .greyShade600,
                            height:
                            1.3,
                          ),
                        ),

                        SizedBox(
                          height:
                          _actionCardVerticalSpacing(
                            context,
                          ),
                        ),

                        if (isAlreadySent) ...[
                          CustomGradientButton(
                            onPressed: null,
                            keepGradientWhenDisabled:
                            true,
                            gradient:
                            AppColors
                                .buttonGradient,
                            borderColor:
                            const Color(
                              0xFFF59E0B,
                            ).withValues(
                              alpha: 0.4,
                            ),
                            prefixIcon:
                            const Icon(
                              Icons
                                  .access_time_rounded,
                              color:
                              AppColors
                                  .white,
                              size: 18,
                            ),
                            label: AppStrings
                                .pendingReview
                                .tr,
                            textColor:
                            AppColors.white,
                          ),

                          if (_effectiveRequestId
                              .isNotEmpty) ...[
                            SizedBox(
                              height:
                              landscape
                                  ? 8
                                  : 14,
                            ),
                            CustomGradientButton(
                              gradient:
                              AppColors
                                  .redGradient,
                              borderColor:
                              const Color(
                                0xFF7A1C15,
                              ),
                              label: AppStrings
                                  .withdrawRequestLabel
                                  .tr,
                              onPressed: () {
                                ActionConfirmDialog
                                    .show(
                                  context,
                                  title: AppStrings
                                      .withdrawRequestTitle
                                      .tr,
                                  message:
                                  AppStrings
                                      .withdrawRequestQuestion
                                      .tr
                                      .replaceAll(
                                    '@name',
                                    _effectiveOtherUserName,
                                  ),
                                  confirmLabel:
                                  AppStrings
                                      .withdraw
                                      .tr,
                                  icon: Icons
                                      .undo_rounded,
                                  iconColor:
                                  const Color(
                                    0xFFB02517,
                                  ),
                                  confirmGradient:
                                  AppColors
                                      .redGradient,
                                  onConfirm:
                                      () async {
                                    final success =
                                    await messageController
                                        .withdrawMessageRequest(
                                      requestId:
                                      _effectiveRequestId,
                                      context:
                                      context,
                                    );

                                    if (success &&
                                        context
                                            .mounted) {
                                      Navigator.of(
                                        context,
                                      ).pop();
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                child:
                                OutlinedButton(
                                  onPressed:
                                      () =>
                                      Navigator.pop(
                                        context,
                                      ),
                                  style:
                                  OutlinedButton
                                      .styleFrom(
                                    backgroundColor:
                                    const Color(
                                      0xFFF1F5F9,
                                    ),
                                    side:
                                    BorderSide
                                        .none,
                                    padding:
                                    EdgeInsets.symmetric(
                                      vertical:
                                      landscape
                                          ? 10
                                          : 14,
                                    ),
                                    shape:
                                    RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                        30,
                                      ),
                                    ),
                                  ),
                                  child:
                                  Text(
                                    AppStrings
                                        .cancel
                                        .tr,
                                    style:
                                    GoogleFonts
                                        .poppins(
                                      color:
                                      AppColors
                                          .black87,
                                      fontWeight:
                                      FontWeight
                                          .w600,
                                      fontSize:
                                      landscape
                                          ? 12
                                          : 14,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              Expanded(
                                child:
                                Container(
                                  decoration:
                                  BoxDecoration(
                                    gradient:
                                    const LinearGradient(
                                      colors: [
                                        Color(
                                          0xFF0062E0,
                                        ),
                                        Color(
                                          0xFF014495,
                                        ),
                                      ],
                                      begin:
                                      Alignment
                                          .topCenter,
                                      end:
                                      Alignment
                                          .bottomCenter,
                                    ),
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      30,
                                    ),
                                  ),
                                  child:
                                  ElevatedButton(
                                    onPressed:
                                    _isSendingRequest
                                        .value
                                        ? null
                                        : () async {
                                      _isSendingRequest
                                          .value = true;

                                      final success =
                                      await chatController
                                          .createMessageRequest(
                                        receiverId:
                                        widget.receiverId,
                                        presetMessageId:
                                        _selectedPresetId.value.isNotEmpty
                                            ? _selectedPresetId.value
                                            : null,
                                        context:
                                        context,
                                      );

                                      _isSendingRequest
                                          .value = false;

                                      if (success) {
                                        _isRequestSent
                                            .value = true;
                                      }
                                    },
                                    style:
                                    ElevatedButton
                                        .styleFrom(
                                      backgroundColor:
                                      AppColors
                                          .transparent,
                                      shadowColor:
                                      AppColors
                                          .transparent,
                                      padding:
                                      EdgeInsets.symmetric(
                                        vertical:
                                        landscape
                                            ? 10
                                            : 14,
                                      ),
                                      shape:
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                          30,
                                        ),
                                      ),
                                    ),
                                    child:
                                    _isSendingRequest
                                        .value
                                        ? const SizedBox(
                                      width:
                                      20,
                                      height:
                                      20,
                                      child:
                                      CircularProgressIndicator(
                                        color:
                                        AppColors.white,
                                        strokeWidth:
                                        2,
                                      ),
                                    )
                                        : Text(
                                      AppStrings
                                          .sendRequest
                                          .tr,
                                      style:
                                      GoogleFonts
                                          .poppins(
                                        color:
                                        AppColors.white,
                                        fontWeight:
                                        FontWeight.w600,
                                        fontSize:
                                        landscape
                                            ? 12
                                            : 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RECEIVE REQUEST VIEW
  // ============================================================

  Widget _buildReceiveRequestView() {
    final landscape = _isLandscape(context);

    return Container(
      decoration: const BoxDecoration(
        gradient:
        AppColors.primaryBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor:
        AppColors.transparent,
        appBar: AppBar(
          backgroundColor:
          AppColors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Center(
            child: GestureDetector(
              onTap: () =>
                  Navigator.of(context)
                      .pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration:
                BoxDecoration(
                  shape:
                  BoxShape.circle,
                  color: AppColors.white
                      .withValues(
                    alpha: 0.9,
                  ),
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color:
                  AppColors.black87,
                  size: 22,
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              UserAvatar(
                imagePath:
                _effectiveOtherUserAvatar ??
                    AppConst.unknown,
                radius:
                landscape ? 16 : 18,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _effectiveOtherUserName,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            GoogleFonts.poppins(
                              color:
                              AppColors.black87,
                              fontWeight:
                              FontWeight.w700,
                              fontSize:
                              landscape
                                  ? 14
                                  : 15,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Image.asset(
                          _effectiveIsVehicleVerified
                              ? AssetsPath
                              .verified
                              : AssetsPath
                              .unverified,
                          width:
                          ResponsiveHelper
                              .iconSize(
                            16,
                          ),
                          height:
                          ResponsiveHelper
                              .iconSize(
                            16,
                          ),
                        ),
                      ],
                    ),
                    if (_effectiveLicenceId !=
                        null &&
                        _effectiveLicenceId!
                            .isNotEmpty)
                      Text(
                        _effectiveLicenceId!,
                        style:
                        GoogleFonts.poppins(
                          color: AppColors
                              .greyShade600,
                          fontSize:
                          landscape
                              ? 10
                              : 11,
                        ),
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
              child: Padding(
                padding:
                EdgeInsets.symmetric(
                  horizontal:
                  landscape ? 12 : 16,
                  vertical:
                  landscape ? 8 : 16,
                ),
                child:
                Builder(builder: (context) {
                  if (_effectiveFirstMessage
                      .isEmpty) {
                    return const SizedBox
                        .shrink();
                  }

                  final bool isMine =
                      _effectiveIsMine;

                  return Align(
                    alignment:
                    Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Center(
                          child:
                          Container(
                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            decoration:
                            BoxDecoration(
                              color: AppColors
                                  .white
                                  .withValues(
                                alpha: 0.6,
                              ),
                              borderRadius:
                              BorderRadius
                                  .circular(
                                16,
                              ),
                            ),
                            child: Text(
                              AppStrings
                                  .today
                                  .tr,
                              style: GoogleFonts
                                  .poppins(
                                fontSize: 12,
                                color: AppColors
                                    .greyShade700,
                                fontWeight:
                                FontWeight
                                    .w500,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height:
                          landscape
                              ? 8
                              : 16,
                        ),

                        if (isMine)
                          MessageBubble(
                            message:
                            _effectiveFirstMessage,
                            isMine: true,
                          )
                        else
                          // MessageBubble already draws its own avatar for
                          // non-mine messages (via avatarUrl) — wrapping it
                          // in another Row+UserAvatar here rendered two
                          // avatars side by side.
                          MessageBubble(
                            message: _effectiveFirstMessage,
                            isMine: false,
                            avatarUrl: _effectiveOtherUserAvatar,
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            // ==================================================
            // FIX:
            // A Flexible(loose) here competes for flex space 50/50
            // with the Expanded above regardless of actual content
            // need, leaving dead space below the card when it doesn't
            // use its share (Flutter's flex layout is single-pass, so
            // unused loose-child space isn't handed back). A
            // ConstrainedBox sizes to the card's own natural height
            // instead (so Expanded gets everything it isn't using),
            // while still capping it so it can't overflow on
            // short/landscape screens — SingleChildScrollView lets it
            // scroll if content ever exceeds that cap.
            // ==================================================

            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                physics:
                const ClampingScrollPhysics(),
                child: Container(
                  padding:
                  EdgeInsets.fromLTRB(
                    16,
                    _actionCardTopPadding(
                      context,
                    ),
                    16,
                    _actionCardBottomPadding(
                      context,
                    ),
                  ),
                  decoration:
                  BoxDecoration(
                    color: AppColors.white
                        .withValues(
                      alpha: 0.92,
                    ),
                    borderRadius:
                    const BorderRadius
                        .vertical(
                      top:
                      Radius.circular(
                        28,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors
                            .black
                            .withValues(
                          alpha: 0.05,
                        ),
                        blurRadius: 20,
                        offset:
                        const Offset(
                          0,
                          -4,
                        ),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings
                            .acceptRequestFrom
                            .tr
                            .replaceAll(
                          '@name',
                          _effectiveOtherUserName,
                        ),
                        textAlign:
                        TextAlign.center,
                        style:
                        GoogleFonts.poppins(
                          fontSize:
                          landscape
                              ? 14
                              : 16,
                          fontWeight:
                          FontWeight.w700,
                          color:
                          AppColors.black87,
                        ),
                      ),

                      SizedBox(
                        height:
                        landscape
                            ? 4
                            : 6,
                      ),

                      Text(
                        AppStrings
                            .acceptRequestDesc
                            .tr,
                        textAlign:
                        TextAlign.center,
                        style:
                        GoogleFonts.poppins(
                          fontSize:
                          landscape
                              ? 10.5
                              : 12,
                          color: AppColors
                              .greyShade600,
                          height: 1.3,
                        ),
                      ),

                      SizedBox(
                        height:
                        _actionCardVerticalSpacing(
                          context,
                        ),
                      ),

                      Row(
                        children: [
                          Expanded(
                            child:
                            ElevatedButton(
                              onPressed: () {
                                ActionConfirmDialog
                                    .show(
                                  context,
                                  title: AppStrings
                                      .blockUserTitle
                                      .tr
                                      .replaceAll(
                                    '@name',
                                    _effectiveOtherUserName,
                                  ),
                                  message:
                                  AppStrings
                                      .blockUserDesc
                                      .tr,
                                  confirmLabel:
                                  AppStrings
                                      .block
                                      .tr,
                                  icon: Icons
                                      .block_rounded,
                                  iconColor:
                                  const Color(
                                    0xFF7A1C15,
                                  ),
                                  confirmGradient:
                                  const LinearGradient(
                                    colors: [
                                      Color(
                                        0xFF7A1C15,
                                      ),
                                      Color(
                                        0xFF4A0F0A,
                                      ),
                                    ],
                                    begin:
                                    Alignment
                                        .topCenter,
                                    end:
                                    Alignment
                                        .bottomCenter,
                                  ),
                                  onConfirm:
                                      () async {
                                    if (_effectiveRequestId
                                        .isNotEmpty) {
                                      await messageController
                                          .blockMessageRequest(
                                        requestId:
                                        _effectiveRequestId,
                                        context:
                                        context,
                                      );
                                    } else {
                                      await chatController
                                          .block(
                                        widget
                                            .receiverId,
                                        context,
                                      );
                                    }

                                    if (context
                                        .mounted) {
                                      Navigator.pop(
                                        context,
                                      );
                                    }
                                  },
                                );
                              },
                              style:
                              ElevatedButton
                                  .styleFrom(
                                backgroundColor:
                                const Color(
                                  0xFF7A1C15,
                                ),
                                padding:
                                EdgeInsets.symmetric(
                                  vertical:
                                  landscape
                                      ? 10
                                      : 13,
                                ),
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    30,
                                  ),
                                ),
                              ),
                              child: Text(
                                AppStrings
                                    .block
                                    .tr,
                                style:
                                GoogleFonts
                                    .poppins(
                                  color:
                                  AppColors
                                      .white,
                                  fontWeight:
                                  FontWeight
                                      .w600,
                                  fontSize:
                                  landscape
                                      ? 12
                                      : 14,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Expanded(
                            child:
                            ElevatedButton(
                              onPressed: () {
                                ActionConfirmDialog
                                    .show(
                                  context,
                                  title: AppStrings
                                      .rejectRequestTitle
                                      .tr,
                                  message: AppStrings
                                      .rejectRequestFrom
                                      .tr
                                      .replaceAll(
                                    '@name',
                                    _effectiveOtherUserName,
                                  ),
                                  confirmLabel:
                                  AppStrings
                                      .reject
                                      .tr,
                                  icon: Icons
                                      .cancel_outlined,
                                  iconColor:
                                  const Color(
                                    0xFFB02517,
                                  ),
                                  confirmGradient:
                                  const LinearGradient(
                                    colors: [
                                      Color(
                                        0xFFB02517,
                                      ),
                                      Color(
                                        0xFF7A1C15,
                                      ),
                                    ],
                                    begin:
                                    Alignment
                                        .topCenter,
                                    end:
                                    Alignment
                                        .bottomCenter,
                                  ),
                                  onConfirm:
                                      () async {
                                    if (_effectiveRequestId
                                        .isNotEmpty) {
                                      await messageController
                                          .rejectMessageRequest(
                                        requestId:
                                        _effectiveRequestId,
                                        context:
                                        context,
                                      );
                                    }

                                    if (context
                                        .mounted) {
                                      Navigator.pop(
                                        context,
                                      );
                                    }
                                  },
                                );
                              },
                              style:
                              ElevatedButton
                                  .styleFrom(
                                backgroundColor:
                                const Color(
                                  0xFFB02517,
                                ),
                                padding:
                                EdgeInsets.symmetric(
                                  vertical:
                                  landscape
                                      ? 10
                                      : 13,
                                ),
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    30,
                                  ),
                                ),
                              ),
                              child: Text(
                                AppStrings
                                    .reject
                                    .tr,
                                style:
                                GoogleFonts
                                    .poppins(
                                  color:
                                  AppColors
                                      .white,
                                  fontWeight:
                                  FontWeight
                                      .w600,
                                  fontSize:
                                  landscape
                                      ? 12
                                      : 14,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Expanded(
                            child:
                            Container(
                              decoration:
                              BoxDecoration(
                                gradient:
                                const LinearGradient(
                                  colors: [
                                    Color(
                                      0xFF0062E0,
                                    ),
                                    Color(
                                      0xFF014495,
                                    ),
                                  ],
                                  begin:
                                  Alignment
                                      .topCenter,
                                  end:
                                  Alignment
                                      .bottomCenter,
                                ),
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  30,
                                ),
                              ),
                              child:
                              ElevatedButton(
                                onPressed: () {
                                  ActionConfirmDialog
                                      .show(
                                    context,
                                    title: AppStrings
                                        .acceptRequestTitle
                                        .tr,
                                    message: AppStrings
                                        .acceptRequestFromDesc
                                        .tr
                                        .replaceAll(
                                      '@name',
                                      _effectiveOtherUserName,
                                    ),
                                    confirmLabel:
                                    AppStrings
                                        .accept
                                        .tr,
                                    icon: Icons
                                        .check_circle_outline_rounded,
                                    iconColor:
                                    AppColors
                                        .blue,
                                    onConfirm:
                                        () async {
                                      if (_effectiveRequestId
                                          .isEmpty) {
                                        return;
                                      }

                                      final roomId =
                                      await messageController
                                          .acceptMessageRequest(
                                        requestId:
                                        _effectiveRequestId,
                                        context:
                                        context,
                                      );

                                      if (roomId ==
                                          null) {
                                        return;
                                      }

                                      _currentRoomId =
                                          roomId;

                                      chatController
                                          .roomID
                                          .value = roomId;

                                      chatController
                                          .fetchInboxMessage(
                                        roomId:
                                        roomId,
                                        refresh:
                                        true,
                                      );

                                      _requestAccepted
                                          .value = true;
                                    },
                                  );
                                },
                                style:
                                ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                  AppColors
                                      .transparent,
                                  shadowColor:
                                  AppColors
                                      .transparent,
                                  padding:
                                  EdgeInsets.symmetric(
                                    vertical:
                                    landscape
                                        ? 10
                                        : 13,
                                  ),
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      30,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  AppStrings
                                      .accept
                                      .tr,
                                  style:
                                  GoogleFonts
                                      .poppins(
                                    color:
                                    AppColors
                                        .white,
                                    fontWeight:
                                    FontWeight
                                        .w600,
                                    fontSize:
                                    landscape
                                        ? 12
                                        : 14,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ANIMATED DOT
// ============================================================

class _AnimatedDot extends StatefulWidget {
  final int delayMs;

  const _AnimatedDot({
    required this.delayMs,
  });

  @override
  State<_AnimatedDot> createState() =>
      _AnimatedDotState();
}

class _AnimatedDotState
    extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration:
      const Duration(milliseconds: 600),
    );

    _animation =
        Tween<double>(
          begin: 0.4,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
          ),
        );

    Future.delayed(
      Duration(
        milliseconds: widget.delayMs,
      ),
          () {
        if (mounted) {
          _controller.repeat(
            reverse: true,
          );
        }
      },
    );
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
          decoration:
          const BoxDecoration(
            color: Color(0xFF6A6969),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}