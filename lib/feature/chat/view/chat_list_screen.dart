import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import 'package:platchatapp/feature/chat/view/message_screen.dart';
import 'package:platchatapp/helper/data_converter/data_converter.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

import '../../../core/router/routes_name.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../repository/chat_controller.dart';
import '../../profile/view/app_menu_drawer.dart';
import 'chat_tile.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatController controller = Get.find<ChatController>();
  final ScrollController scrollController = ScrollController();

  // @override
  // void initState() {
  //   super.initState();
  //
  //   /// Socket init (ONLY ONCE)
  //   if (!AppSocket.isConnected) {
  //     AppSocket.init(
  //       onSocketConnect: () {
  //         debugPrint('Socket connected from ChatListScreen');
  //       },
  //     );
  //   }
  //   controller.newMessage();
  //   controller.fetchChatRooms(refresh: true);
  //
  //   /// First API call
  //   // controller.fetchChatRooms();
  //
  //   /// Pagination listener
  //   scrollController.addListener(_onScroll);
  // }

  @override
  void initState() {
    super.initState();

    /// Socket init (ONLY ONCE)
    if (!AppSocket.isConnected) {
      AppSocket.init(
        onSocketConnect: () {
          debugPrint('Socket connected from ChatListScreen');
        },
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initSocketListeners();
      controller.fetchChatRooms(refresh: true);
      controller.newMessage();
    });

    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 100 &&
        controller.hasMore &&
        !controller.isLoadingMore.value) {
      controller.fetchChatRooms(loadMore: true);
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
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: true,
        title: Text(
          'all_chat'.tr,
          style: TextStyle(
            color: AppColors.black,
            fontSize: ResponsiveHelper.fontSize(18),
          ),
        ),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(
                  Icons.menu_outlined,
                  color: AppColors.black,
                  size: ResponsiveHelper.iconSize(24),
                ),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      endDrawer: const AppMenuDrawer(),

      body: RefreshIndicator(
        onRefresh: () => controller.fetchChatRooms(refresh: true),
        child: Column(
          children: [
            /// Search bar
            Padding(
              padding: EdgeInsets.all(ResponsiveHelper.padding(12)),
              child: GestureDetector(
                onTap: () {
                  context.pushNamed(RouteName.searchList);
                },
                child: AbsorbPointer(
                  child: TextField(
                    style: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
                    decoration: InputDecoration(
                      hintText: 'search_here'.tr,
                      hintStyle: TextStyle(
                        fontSize: ResponsiveHelper.fontSize(16),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: ResponsiveHelper.iconSize(24),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.borderRadius(30),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// Chat list
            Expanded(
              child: Obx(() {
                // final chatList = controller.userChatList;

                /// First load
                if (controller.isLoadingChat.value &&
                    controller.userChatList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                /// Empty state
                if (controller.userChatList.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * .3),
                      Center(
                        child: Text(
                          'no_chats'.tr,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.fontSize(16),
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                /// Nested Obx for pagination/loading inside ListView.builder

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: scrollController,
                  itemCount: controller.userChatList.length + 1,
                  itemBuilder: (context, index) {
                    /// Pagination loader
                    if (index == controller.userChatList.length) {
                      if (controller.isLoadingMore.value) {
                        return const Padding(
                          padding: EdgeInsets.all(8),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    final room = controller.userChatList[index];

                    return ChatTile(
                      isBlock: false,
                      name: room.otherUser?.nickName ?? "No Name",
                      message: room.latestMessage?.message ?? "",
                      fontWeight: room.latestMessage!.isRead == true
                          ? FontWeight.w400
                          : FontWeight.w700,
                      time: formatTime(room.latestMessage?.createdAt ?? ""),
                      imagePath: ImageHandler.imagesHandle(
                        room.otherUser?.avatar ?? AppConst.unknown,
                        isProfile: true,
                      ),
                      onTap: () {
                        MessageInformation messageInformation =
                            MessageInformation(
                              roomID: room.id ?? '',
                              otherUserName: room.otherUser?.nickName ?? 'User',
                              otherUserAvatar:
                                  room.otherUser?.avatar ?? AppConst.unknown,
                              receiverId: room.otherUser?.id ?? '',
                              isBlockedByMe: room.isBlockedByMe,
                              isBlockedMe: room.isBlockedMe,
                            );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessageScreen(
                              roomId: messageInformation.roomID,
                              otherUserName: messageInformation.otherUserName,
                              otherUserAvatar:
                                  messageInformation.otherUserAvatar,
                              receiverId: messageInformation.receiverId,
                              isBlockedByMe: messageInformation.isBlockedByMe,
                              isBlockedMe: messageInformation.isBlockedMe,
                            ),
                          ),
                        );
                        // context.pushNamed(
                        //   RouteName.message,
                        //   extra: {
                        //     'roomId': room.id ?? '',
                        //     'otherUserName': room.otherUser?.nickName ?? 'User',
                        //     'otherUserAvatar':
                        //         room.otherUser?.avatar ?? AppConst.unknown,
                        //     'receiverId': room.otherUser?.id ?? '',
                        //     "isBlockedByMe": room.isBlockedByMe,
                        //     "isBlockedMe": room.isBlockedMe,
                        //   },
                        // );
                      },
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
}

class MessageInformation {
  final String roomID;
  final String otherUserName;
  final String otherUserAvatar;
  final String receiverId;
  final bool? isBlockedByMe;
  final bool? isBlockedMe;

  MessageInformation({
    required this.roomID,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.receiverId,
    this.isBlockedByMe,
    this.isBlockedMe,
  });
}
