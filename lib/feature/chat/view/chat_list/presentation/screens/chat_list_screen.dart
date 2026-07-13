import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/router/routes_name.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import 'package:platchatapp/feature/chat/model/user_chat_model.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/chat/view/chat_list/presentation/widgets/chat_list_appbar.dart';
import 'package:platchatapp/feature/chat/view/chat_list/presentation/widgets/chat_list_search_bar.dart';
import 'package:platchatapp/feature/chat/view/chat_list/presentation/widgets/chat_navigator.dart';
import 'package:platchatapp/feature/chat/view/chat_list/presentation/widgets/create_group.dart';
import 'package:platchatapp/feature/chat/view/widgets/chat_list_screen_shimmer.dart';
import 'package:platchatapp/feature/chat/view/widgets/chat_tile.dart';
import 'package:platchatapp/feature/main/data/main_nav_.dart';
import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
import 'package:platchatapp/helper/data_converter/data_converter.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/language/app_string.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatController controller = Get.put(ChatController());
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── App Bar: logo + create group button ─────────────────
      appBar: ChatListAppBar(
        onCreateGroupTap: () =>
            showCreateGroupDialog(context: context, controller: controller),

        // onScanTap: () {
        //   context.pushNamed(RouteName.ocrScanner);
        //   context.pushNamed(RouteName.scanScreen);
        // },
        //
        onScanTap: () async {
          final result = await showModalBottomSheet<String>(
            context: context,
            builder: (context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.document_scanner),
                      title: Text(AppStrings.ocrScanner.tr),
                      onTap: () => Navigator.pop(context, 'ocr'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.qr_code_scanner),
                      title: Text(AppStrings.scanQrCode.tr),
                      onTap: () => Navigator.pop(context, 'scan'),
                    ),
                  ],
                ),
              );
            },
          );

          if (result == 'ocr') {
            context.pushNamed(RouteName.ocrScanner);
          } else if (result == 'scan') {
            context.pushNamed(RouteName.scanScreen);
          }
        },

      ),

      body: RefreshIndicator(
        color: AppColors.white,
        backgroundColor: AppColors.blue,
        onRefresh: () => controller.fetchChatList(refresh: true),
        child: Column(
          children: [
            // ── Search Bar: tap করলে search screen এ যায় ────
            const ChatListSearchBar(),

            // ── Chat List ────────────────────────────────────
            Expanded(


          child: Obx(() {



                if (controller.isLoadingChat.value &&
                    controller.userChatList.isEmpty) {
                  return const ChatListShimmer();
                }

                // কোনো chat না থাকলে empty state
                if (controller.userChatList.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * .3),
                      Center(

                        child: Padding(
                          padding:  ResponsiveHelper.symmetric(horizontal: 8.0),
                          child: Text(
                            'no_chats'.tr,
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
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: scrollController,
                  itemCount: controller.userChatList.length + 1,
                  itemBuilder: (context, index) {
                    // List এর শেষে pagination loader
                    if (index == controller.userChatList.length) {
                      return controller.isLoadingMore.value
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : const SizedBox.shrink();
                    }

                    final Rooms room = controller.userChatList[index];
                    final bool isGroup = room.isGroup;
                    final bool isTyping = controller.inboxTypingMap[room.id] == true;

                    // Latest message text তৈরি করো
                    final String lastMessage = isTyping
                        ? 'typing_'.tr
                        : _buildLastMessage(room, isGroup);

                    return GestureDetector(
                      onLongPress: () => _showDeleteDialog(context, room),
                      child: ChatTile(
                        name: room.displayName,
                    imagePath:  isGroup
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
                        isBlock:
                            !isGroup &&
                            (room.isBlockedByMe == true ||
                                room.isBlockedMe == true),
                        isGroup: isGroup,
                        plateNumber: room.otherUser?.licenceId,
                        // group এ rating নেই
                      //  rating: isGroup ? null : ((room.otherUser?.rating ?? 0) > 0 ? (room.otherUser!.rating!).toDouble() : null),
                        rating: isGroup ? null : (room.otherUser?.rating ?? 0).toDouble(),
                        totalRating: isGroup ? null : (room.otherUser?.totalRatings ?? 0).toInt(),
                        ratingColor:(room.otherUser?.rating ?? 0) > 0 ? null : Colors.grey,
                        // ✅ unread badge — নিজের message হলে 0 দেখাবে
                        unreadCount: room.latestMessage?.isMine == true
                            ? 0
                            : (room.unreadCount ?? 0),
                        isVehicleVerified:  room.otherUser?.isVehicleVerified,
                        onTap: () => navigateToChat(context: context, room: room),
                      ),
                    );
                  },
                );
              }),
            ),



          ],
        ),
      ),
    );
  }

  /// Group হলে sender name prefix যোগ করে, না হলে plain message দেখায়
  String _buildLastMessage(Rooms room, bool isGroup) {
    if (room.latestMessage?.message == null) {
      return isGroup ? 'no_messages_yet'.tr : '';
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Chat name preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(
                    room.displayName,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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
                'delete_chat'.tr,
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
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
                'cancel'.tr,
                style: GoogleFonts.poppins(),
              ),
              onTap: () => Navigator.pop(ctx),
            ),

            const SizedBox(height: 8),
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
          'delete_chat'.tr,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'delete_chat_confirm'.tr, // "Are you sure you want to delete this chat?"
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('cancel'.tr, style: GoogleFonts.poppins()),
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
              'delete'.tr,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
