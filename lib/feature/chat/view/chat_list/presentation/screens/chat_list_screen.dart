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
import 'package:platchatapp/feature/chat/view/chat_list/presentation/widgets/chat_list_search_bar.dart';
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

    // Socket connect করো যদি এখনো connected না থাকে
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
      Get.find<MessageController>().fetchMessageRequestInbox(refresh: true);
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

  void _showMessageRequestBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryBackgroundGradient,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveHelper.borderRadius(28)),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.padding(20),
            vertical: ResponsiveHelper.padding(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: ResponsiveHelper.width(40),
                  height: ResponsiveHelper.height(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(2)),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.spacing(16)),

              Text(
                AppStrings.messageRequests.tr,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: ResponsiveHelper.fontSize(20),
                  color: AppColors.textBlack,
                ),
              ),

              SizedBox(height: ResponsiveHelper.spacing(16)),

              // Received Requests option
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  context.pushNamed(RouteName.messageRequests);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.padding(10)),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(ResponsiveHelper.padding(10)),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.mail_outline_rounded,
                          color: AppColors.blue,
                          size: ResponsiveHelper.iconSize(20),
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.spacing(14)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.receiveRequestTab.tr,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: ResponsiveHelper.fontSize(15),
                                color: AppColors.textBlack,
                              ),
                            ),
                            SizedBox(height: ResponsiveHelper.spacing(2)),
                            Text(
                              'Requests others sent to you',
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveHelper.fontSize(12),
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey.shade400,
                        size: ResponsiveHelper.iconSize(22),
                      ),
                    ],
                  ),
                ),
              ),

              Divider(height: 1, thickness: 0.5, color: Colors.grey.shade300),

              // Sent Requests option
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  context.pushNamed(RouteName.sendRequests);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.padding(10)),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(ResponsiveHelper.padding(10)),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.send_outlined,
                          color: AppColors.blue,
                          size: ResponsiveHelper.iconSize(20),
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.spacing(14)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.sentRequests.tr,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: ResponsiveHelper.fontSize(15),
                                color: AppColors.textBlack,
                              ),
                            ),
                            SizedBox(height: ResponsiveHelper.spacing(2)),
                            Text(
                              'Requests you sent to others',
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveHelper.fontSize(12),
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey.shade400,
                        size: ResponsiveHelper.iconSize(22),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: ResponsiveHelper.spacing(16)),
            ],
          ),
        ),
      ),
    );
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
              color: isActive ? Colors.white : const Color(0xFF6E7C8E),
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
      // ── App Bar: logo + create group button ─────────────────
      appBar: ChatListAppBar(

        onCreateGroupTap: () =>
            showCreateGroupDialog(context: context, controller: controller),



        onScanTap: () async {
          final result = await showModalBottomSheet<String>(
            context: context,
            backgroundColor: Colors.transparent,
            barrierColor: Colors.black.withOpacity(0.35),
            isScrollControlled: true,
            builder: (context) {
              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.padding(20),
                    vertical: ResponsiveHelper.padding(12),
                  ),
                  child: ScanOptionsCard(
                    onOcrTap: () => Navigator.pop(context, 'ocr'),
                    onQrTap: () => Navigator.pop(context, 'scan'),
                  ),
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
        _showMessageRequestBottomSheet(context);
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
              // ── Search Bar: tap করলে search screen এ যায় ────
              //const ChatListSearchBar(),

              // ── Message Center: Send Message / Receive Request tabs ──
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
              //             color: Colors.black87,
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
              //                 color: Colors.white,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //           );
              //         }),
              //         const Spacer(),
              //         Icon(
              //           Icons.chevron_right,
              //           color: Colors.grey.shade400,
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
                  color: Colors.white.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(30)),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildTabItem(0, 'All'),
                    _buildTabItem(1, 'Individual'),
                    _buildTabItem(2, 'Group'),
                  ],
                ),
              ),

              // ── Chat List ────────────────────────────────────
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

                  // কোনো chat না থাকলে empty state
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


                  // Chat list দেখাও
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: scrollController,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: ResponsiveHelper.padding(16),
                        right: ResponsiveHelper.padding(16),
                        top: ResponsiveHelper.padding(4),
                        bottom: ResponsiveHelper.padding(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(24)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
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
                                  color: Colors.grey.shade200,
                                  indent: ResponsiveHelper.padding(64),
                                  endIndent: ResponsiveHelper.padding(14),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                            itemBuilder: (context, index) {
                              // List এর শেষে pagination loader
                              if (index == displayChats.length) {
                                return controller.isLoadingMore.value
                                    ? Padding(
                                        padding: ResponsiveHelper.all(8),
                                        child: const Center(child: CircularProgressIndicator()),
                                      )
                                    : const SizedBox.shrink();
                              }

                              final Rooms room = displayChats[index];
                              final bool isGroup = room.isGroup;
                              final bool isTyping = controller.inboxTypingMap[room.id] == true;

                              // Latest message text তৈরি করো
                              final String lastMessage = isTyping
                                  ? AppStrings.typing.tr
                                  : _buildLastMessage(room, isGroup);

                              return GestureDetector(
                                onLongPress: () => _showDeleteDialog(context, room),
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

                                  // unread হলে bold
                                  fontWeight: room.latestMessage?.isUnread == true
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  time: room.latestMessage?.createdAt != null
                                      ? formatTime(room.latestMessage!.createdAt!)
                                      : '',
                                  // group chat এ block নেই
                                  isBlockedByMe: !isGroup && room.isBlockedByMe == true,
                                  isBlockedMe: !isGroup && room.isBlockedMe == true,
                                  onUnblock: () {
                                    if (room.otherUser?.id != null) {
                                      controller.unBlock(room.otherUser!.id!, context);
                                    }
                                  },
                                  isGroup: isGroup,
                                  plateNumber: room.otherUser?.licenceId,
                                  // group এ rating নেই
                                  // rating: isGroup ? null : ((room.otherUser?.rating ?? 0) > 0 ? (room.otherUser!.rating!).toDouble() : null),
                                  rating: isGroup ? null : (room.otherUser?.rating ?? 0).toDouble(),
                                  totalRating: isGroup ? null : (room.otherUser?.totalRatings ?? 0).toInt(),
                                  ratingColor: (room.otherUser?.rating ?? 0) > 0 ? null : Colors.grey,
                                  // ✅ unread badge — নিজের message হলে 0 দেখাবে
                                  unreadCount: room.latestMessage?.isMine == true
                                      ? 0
                                      : (room.unreadCount ?? 0),
                                  isRead: room.latestMessage?.isRead,
                                  isDelivered: room.latestMessage?.isDelivered,
                                  isVehicleVerified: room.otherUser?.isVehicleVerified,
                                  onTap: () => navigateToChat(context: context, room: room),
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

  /// Group হলে sender name prefix যোগ করে, না হলে plain message দেখায়
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
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(2)),
              ),
            ),

            // Chat name preview
            Padding(
              padding: ResponsiveHelper.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, color: Colors.grey),
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
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                AppStrings.deleteChat.tr,
                style: GoogleFonts.poppins(
                  color: Colors.red,
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
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),

              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
             // controller.deleteChat(room.id); // আপনার controller এ এই method থাকতে হবে
            },
            child: Text(
              AppStrings.deleteMessage.tr,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
