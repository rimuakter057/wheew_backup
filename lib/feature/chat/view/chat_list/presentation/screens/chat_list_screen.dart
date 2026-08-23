import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/core/service/notification_service.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import 'package:platchatapp/feature/chat/model/user_chat_model.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/chat/view/chat_list/presentation/widgets/chat_list_appbar.dart';
import 'package:platchatapp/feature/chat/view/chat_list/presentation/widgets/chat_navigator.dart';
import 'package:platchatapp/feature/chat/view/chat_list/presentation/widgets/create_group.dart';
import 'package:platchatapp/feature/chat/view/message/controller/message_controller.dart';
import 'package:platchatapp/feature/chat/view/widgets/chat_list_screen_shimmer.dart';
import 'package:platchatapp/feature/chat/view/widgets/chat_tile.dart';
import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
import 'package:platchatapp/feature/scan/presentation/widget/scan_options_card.dart';
import 'package:platchatapp/helper/data_converter/data_converter.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';

import '../../../../../../core/router/route_path.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatController controller = Get.put(ChatController());
  final ScrollController scrollController = ScrollController();
  int _selectedTabIndex = 0; // 0: All, 1: Individual, 2: Group

  @override
  void initState() {
    super.initState();

    // Chat List screen is where notification permission is requested —
    // denial only disables push notifications; the rest of the app keeps
    // working (see NotificationService.init's internal try/catch).
    NotificationService.instance.init();

    // Socket connect à¦•à¦°à§‹ à¦¯à¦¦à¦¿ à¦à¦–à¦¨à§‹ connected à¦¨à¦¾ à¦¥à¦¾à¦•à§‡
    if (!AppSocket.isConnected) {
      AppSocket.init(
        onSocketConnect: () {
          debugPrint('Socket connected from ChatListScreen');
        },
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initSocketListeners();
      controller.fetchChatList(refresh: true);
      controller.newMessage();
      Get.find<ProfileController>().reloadProfile();
      // Real-time-ish received-request count badge, same idea as the
      // notification bell's unread count.
      Get.find<MessageController>().fetchMessageRequestCounts();
    });

    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        controller.hasMore &&
        !controller.isLoadingMore.value &&
        !controller.isLoadingChat.value) {
      controller.fetchChatList(loadMore: true);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Widget _buildTabItem(int index, String title) {
    final bool isActive = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [
                      Color(0xFF0062E0),
                      Color(0xFF014495),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(25)),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF014495).withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: isActive ? AppColors.white : const Color(0xFF6E7C8E),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: ResponsiveHelper.fontSize(13),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // -- App Bar: logo + create group button -----------------
      appBar: ChatListAppBar(

        onCreateGroupTap: () =>
            showCreateGroupDialog(context: context, controller: controller),



        onScanTap: () async {
          final result = await showGeneralDialog<String>(
            context: context,
            barrierDismissible: true,
            barrierLabel: AppStrings.dismiss.tr,
            barrierColor: AppColors.black.withOpacity(0.35),
            transitionDuration: const Duration(milliseconds: 200),
            pageBuilder: (dialogContext, animation, secondaryAnimation) {
              final double topPadding =
                  MediaQuery.of(dialogContext).padding.top + kToolbarHeight;
              return Stack(
                children: [
                  Positioned(
                    top: topPadding + ResponsiveHelper.padding(6),
                    left: ResponsiveHelper.padding(16),
                    width: MediaQuery.of(dialogContext).size.width * 0.85,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: ResponsiveHelper.padding(14),
                          ),
                          child: ClipPath(
                            clipper: _TopTriangleClipper(),
                            child: Container(
                              width: 14,
                              height: 8,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        ScanOptionsCard(
                          onOcrTap: () => Navigator.pop(dialogContext, 'ocr'),
                          onQrTap: () => Navigator.pop(dialogContext, 'scan'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                  alignment: const Alignment(-0.85, -0.9),
                  child: child,
                ),
              );
            },
          );

          if (result == 'ocr') {
            context.pushNamed(RouteName.ocrScanner);
          } else if (result == 'scan') {
            context.pushNamed(RouteName.scanScreen);
          }
        }, onTapSearch: () {
        context.push(RoutePath.searchList);

      }, messageRequest: () {
        context.pushNamed(RouteName.sendRequests);
      },

      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryBackgroundGradient

        ),
        child: RefreshIndicator(
          color: AppColors.white,
          backgroundColor: AppColors.blue,
          onRefresh: () => controller.fetchChatList(refresh: true),
          child: Column(
            children: [
              // -- Search Bar: tap à¦•à¦°à¦²à§‡ search screen à¦ à¦¯à¦¾à¦¯à¦¼ ----
              //const ChatListSearchBar(),

              // -- Message Center: Send Message / Receive Request tabs --
              // InkWell(
              //   onTap: () => context.pushNamed(RouteName.messageCenter),
              //   child: Padding(
              //     padding: EdgeInsets.symmetric(
              //       horizontal: ResponsiveHelper.width(16),
              //       vertical: ResponsiveHelper.height(10),
              //     ),
              //     child: Row(
              //       children: [
              //         Icon(
              //           Icons.mark_email_unread_outlined,
              //           color: AppColors.blue,
              //           size: ResponsiveHelper.iconSize(20),
              //         ),
              //         SizedBox(width: ResponsiveHelper.width(8)),
              //         Text(
              //           AppStrings.messageRequests.tr,
              //           style: GoogleFonts.poppins(
              //             fontWeight: FontWeight.w600,
              //             fontSize: ResponsiveHelper.fontSize(14),
              //             color: AppColors.black87,
              //           ),
              //         ),
              //         SizedBox(width: ResponsiveHelper.width(8)),
              //         Obx(() {
              //           final count = Get.find<MessageController>().totalRequestsCount.value;
              //           if (count <= 0) return const SizedBox.shrink();
              //           return Container(
              //             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              //             decoration: const BoxDecoration(
              //               color: Color(0xFF2F80ED),
              //               borderRadius: BorderRadius.all(Radius.circular(20)),
              //             ),
              //             child: Text(
              //               '$count',
              //               style: const TextStyle(
              //                 fontSize: 11,
              //                 color: AppColors.white,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //           );
              //         }),
              //         const Spacer(),
              //         Icon(
              //           Icons.chevron_right,
              //           color: AppColors.greyShade400,
              //           size: ResponsiveHelper.iconSize(20),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),


              ///tab bar and multiple tab all individual and group
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.padding(20),
                  vertical: ResponsiveHelper.padding(10),
                ),
                height: ResponsiveHelper.height(46),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(30)),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.8),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildTabItem(0, AppStrings.all.tr),
                    _buildTabItem(1, AppStrings.individual.tr),
                    _buildTabItem(2, AppStrings.group.tr),
                  ],
                ),
              ),

              // -- Chat List ------------------------------------
              Expanded(
            child: Obx(() {



                  if (controller.isLoadingChat.value &&
                      controller.userChatList.isEmpty) {
                    return const ChatListShimmer();
                  }

                  final List<Rooms> displayChats = _selectedTabIndex == 1
                      ? controller.userChatList.where((room) => !room.isGroup).toList()
                      : (_selectedTabIndex == 2
                          ? controller.userChatList.where((room) => room.isGroup).toList()
                          : controller.userChatList);

                  // à¦•à§‹à¦¨à§‹ chat à¦¨à¦¾ à¦¥à¦¾à¦•à¦²à§‡ empty state
                  if (displayChats.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * .25),
                        Center(

                          child: Padding(
                            padding:  ResponsiveHelper.symmetric(horizontal: 8.0),
                            child: Text(
                              AppStrings.noChats.tr,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: ResponsiveHelper.fontSize(18),
                                color: AppColors.black,

                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }


                  // Chat list দেখাও — outer SingleChildScrollView owns all
                  // scrolling (same pattern as BlockListScreen), so the
                  // white card's height stays tied to its actual content
                  // instead of the shrinkWrapped ListView fighting an
                  // Expanded parent for space.
                  return SingleChildScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                    padding: EdgeInsets.only(
                      left: ResponsiveHelper.padding(16),
                      right: ResponsiveHelper.padding(16),
                      top: ResponsiveHelper.padding(4),
                      bottom: ResponsiveHelper.padding(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.white),
                        color:Color(0xFFDFE6EF),
                        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(24)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.04),
                            blurRadius: 15,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(24)),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayChats.length + 1,
                            separatorBuilder: (context, index) {
                              if (index < displayChats.length - 1) {
                                return Divider(
                                  height: 1,
                                  thickness: 0.5,
                                  color: AppColors.divider,
                                  indent: ResponsiveHelper.padding(64),
                                  endIndent: ResponsiveHelper.padding(14),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                            itemBuilder: (context, index) {
                              // List à¦à¦° à¦¶à§‡à¦·à§‡ pagination loader
                              if (index == displayChats.length) {
                                return controller.isLoadingMore.value
                                    ? Padding(
                                        padding: ResponsiveHelper.all(8),
                                        child: const Center(child: CircularProgressIndicator()),
                                      )
                                    : const SizedBox.shrink();
                              }

                              final Rooms room = displayChats[index];
                              final bool isMessageRequest = room.isMessageRequest;
                              final bool isGroup = room.isGroup;
                              final bool isTyping = controller.inboxTypingMap[room.id] == true;

                              // Latest message text à¦¤à§ˆà¦°à¦¿ à¦•à¦°à§‹
                              final String lastMessage = isTyping
                                  ? AppStrings.typing.tr
                                  : (isMessageRequest
                                      ? (room.requestFirstMessage ?? '')
                                      : _buildLastMessage(room, isGroup));

                              return GestureDetector(
                                onLongPress: isMessageRequest
                                    ? null
                                    : () => _showDeleteDialog(context, room),
                                child: ChatTile(
                                  name: room.displayName,
                                  imagePath: isGroup
                                      ? (room.displayAvatar.isNotEmpty
                                          ? ImageHandler.imagesHandle(room.displayAvatar, isProfile: true)
                                          : 'assets/icons/group_chat.svg')
                                      : ImageHandler.imagesHandle(
                                          room.displayAvatar.isNotEmpty
                                              ? room.displayAvatar
                                              : AppConst.unknown,
                                          isProfile: true,
                                        ),
                                  message: lastMessage,

                                  // unread à¦¹à¦²à§‡ bold
                                  fontWeight: (isMessageRequest
                                          ? (room.unreadCount ?? 0) > 0
                                          : room.latestMessage?.isUnread == true)
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  time: room.latestMessage?.createdAt != null
                                      ? formatTime(room.latestMessage!.createdAt!)
                                      : (isMessageRequest && room.createdAt != null
                                          ? formatTime(room.createdAt!)
                                          : ''),
                                  // group chat à¦ block à¦¨à§‡à¦‡
                                  isBlockedByMe: !isGroup && room.isBlockedByMe == true,
                                  isBlockedMe: !isGroup && room.isBlockedMe == true,
                                  onUnblock: () {
                                    if (room.otherUser?.id != null) {
                                      controller.unBlock(room.otherUser!.id!, context);
                                    }
                                  },
                                  isGroup: isGroup,
                                  plateNumber: room.otherUser?.licenceId,
                                  // group à¦ rating à¦¨à§‡à¦‡
                                  // rating: isGroup ? null : ((room.otherUser?.rating ?? 0) > 0 ? (room.otherUser!.rating!).toDouble() : null),
                                  rating: isGroup ? null : (room.otherUser?.rating ?? 0).toDouble(),
                                  totalRating: isGroup ? null : (room.otherUser?.totalRatings ?? 0).toInt(),
                                  ratingColor: (room.otherUser?.rating ?? 0) > 0 ? null : AppColors.grey,
                                  // ✅ unread badge — নিজের message হলে 0 দেখাবে
                                  unreadCount: isMessageRequest
                                      ? (room.unreadCount ?? 0)
                                      : (room.latestMessage?.isMine == true ? 0 : (room.unreadCount ?? 0)),
                                  isRead: room.latestMessage?.isRead,
                                  isDelivered: room.latestMessage?.isDelivered,
                                  isVehicleVerified: room.otherUser?.isVehicleVerified,
                                  onTap: () {
                                    if (isMessageRequest) {
                                      // Pending request, no chat room yet —
                                      // opens the same accept/reject flow as
                                      // the Receive Requests screen.
                                      context.pushNamed(
                                        RouteName.message,
                                        extra: {
                                          'roomId': room.requestRoomId ?? '',
                                          'otherUserName': room.displayName,
                                          'otherUserAvatar': room.displayAvatar,
                                          'receiverId': room.otherUser?.id ?? '',
                                          'firstMessage': room.requestFirstMessage ?? '',
                                          'requestId': room.requestId ?? room.id ?? '',
                                          'licenceId': room.otherUser?.licenceId ?? '',
                                          'isReceivedRequest': true,
                                        },
                                      );
                                    } else {
                                      navigateToChat(context: context, room: room);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),



            ],
          ),
        ),
      ),
    );
  }

  /// Group à¦¹à¦²à§‡ sender name prefix à¦¯à§‹à¦— à¦•à¦°à§‡, à¦¨à¦¾ à¦¹à¦²à§‡ plain message à¦¦à§‡à¦–à¦¾à¦¯à¦¼
  String _buildLastMessage(Rooms room, bool isGroup) {
    if (room.latestMessage?.message == null) {
      return isGroup ? AppStrings.noMessagesYet.tr : '';
    }

    if (isGroup) {
      if (room.latestMessage?.isMine == true) {
        return room.latestMessage!.message!;
      }
      final String senderName = room.latestMessage?.sender?.nickName ?? '';
      return senderName.isNotEmpty
          ? '$senderName: ${room.latestMessage!.message!}'
          : room.latestMessage!.message!;
    }

    return room.latestMessage!.message!;
  }

  ///show delete

  void _showDeleteDialog(BuildContext context, Rooms room) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveHelper.borderRadius(16)),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: ResponsiveHelper.symmetric(vertical: 8),
              width: ResponsiveHelper.width(40),
              height: ResponsiveHelper.height(4),
              decoration: BoxDecoration(
                color: AppColors.greyShade300,
                borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(2)),
              ),
            ),

            // Chat name preview
            Padding(
              padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, color: AppColors.grey),
                  SizedBox(width: ResponsiveHelper.spacing(12)),
                  Text(
                    room.displayName,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveHelper.fontSize(16),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Delete option
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.red),
              title: Text(
                AppStrings.deleteChat.tr,
                style: GoogleFonts.poppins(
                  color: AppColors.red,
                  fontWeight: FontWeight.w500,
                  fontSize: ResponsiveHelper.fontSize(16),
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, room);
              },
            ),

            // Cancel
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(
                AppStrings.cancel.tr,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveHelper.fontSize(16),
                ),
              ),
              onTap: () => Navigator.pop(ctx),
            ),

            SizedBox(height: ResponsiveHelper.spacing(8)),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Rooms room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          AppStrings.deleteChat.tr,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          AppStrings.deleteChatConfirm.tr, // "Are you sure you want to delete this chat?"
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel.tr, style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),

              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
             // controller.deleteChat(room.id); // à¦†à¦ªà¦¨à¦¾à¦° controller à¦ à¦à¦‡ method à¦¥à¦¾à¦•à¦¤à§‡ à¦¹à¦¬à§‡
            },
            child: Text(
              AppStrings.deleteMessage.tr,
              style: GoogleFonts.poppins(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopTriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}



