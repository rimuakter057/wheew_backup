import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import 'package:platchatapp/feature/chat/model/user_chat_model.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/chat/view/chat_list/presentation/widgets/chat_list_appbar.dart';
import 'package:platchatapp/feature/chat/view/chat_list/presentation/widgets/chat_list_search_bar.dart';
import 'package:platchatapp/feature/chat/view/chat_list/presentation/widgets/chat_navigator.dart';
import 'package:platchatapp/feature/chat/view/chat_list/presentation/widgets/create_group.dart';
import 'package:platchatapp/feature/chat/view/widgets/chat_list_screen_shimmer.dart';
import 'package:platchatapp/feature/chat/view/widgets/chat_tile.dart';
import 'package:platchatapp/feature/profile/repository/profile_controller.dart';
import 'package:platchatapp/helper/data_converter/data_converter.dart';
import 'package:platchatapp/helper/fromate_rating/formate_rating.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

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
      controller.initSocketListeners(); // socket events listen শুরু
      controller.fetchChatList(refresh: true); // প্রথমবার chat list load
      controller.newMessage(); // নতুন message socket listen
      Get.find<ProfileController>().reloadProfile(); // profile reload
    });

    scrollController.addListener(_onScroll);
  }

  /// Scroll করে উপরে গেলে পুরনো data (pagination) load করে
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
                // প্রথম load এ shimmer দেখাও
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
                        child: Text(
                          'no_chats'.tr,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: ResponsiveHelper.fontSize(18),
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

                    // Latest message text তৈরি করো
                    final String lastMessage = _buildLastMessage(room, isGroup);

                    return ChatTile(
                      name: room.displayName,
                      imagePath: isGroup
                          ? "https://cdn-icons-png.flaticon.com/512/2352/2352167.png"
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
                      // group এ rating নেই
                      rating: isGroup ? null :room.otherUser?.rating,
                      onTap: () => navigateToChat(context: context, room: room),
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

  /// Latest message preview text তৈরি করে
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
}
