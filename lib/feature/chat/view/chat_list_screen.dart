import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/core/service/socket_service.dart';
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
  final ChatController controller = Get.put(ChatController());
  final ScrollController scrollController = ScrollController();
  //
  // @override
  // void initState() {
  //   super.initState();
  //
  //   controller.fetchChatRooms();
  //
  //   scrollController.addListener(() {
  //     if (scrollController.position.pixels >=
  //         scrollController.position.maxScrollExtent - 100 &&
  //         controller.hasMore &&
  //         !controller.isLoadingMore.value) {
  //       controller.fetchChatRooms();
  //     }
  //   });
  //
  //   if (!SocketApi.isConnected) {
  //     SocketApi.init(
  //       onSocketConnect: () {
  //         debugPrint('Socket connected from ChatListScreen');
  //       },
  //     );
  //   }
  // }
  //
  // @override
  // void dispose() {
  //   scrollController.dispose();
  //   super.dispose();
  // }

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

      body: Column(
        children: [
          // Search bar (clickable)
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
                    hintStyle: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
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

          // // Expanded ListView for user chat list
          // Expanded(
          //   child: Obx(() {
          //     final chatList = controller.userChatList;
          //
          //     // Loading indicator while first page is loading
          //     if (controller.isLoadingChat.value && chatList.isEmpty) {
          //       return const Center(child: CircularProgressIndicator());
          //     }
          //
          //     // Empty list text
          //     if (chatList.isEmpty) {
          //       return Center(
          //         child: Text(
          //           'no_chats'.tr, // "No chats available" translation key
          //           style: TextStyle(
          //             fontSize: ResponsiveHelper.fontSize(16),
          //             color: Colors.grey,
          //           ),
          //         ),
          //       );
          //     }
          //
          //     // List with pagination
          //     return RefreshIndicator(
          //       onRefresh: () => controller.fetchChatRooms(refresh: true),
          //       child: ListView.builder(
          //         controller: scrollController,
          //         itemCount: chatList.length + 1, // +1 for loading more indicator
          //         itemBuilder: (context, index) {
          //           if (index == chatList.length) {
          //             return controller.hasMore
          //                 ? const Padding(
          //               padding: EdgeInsets.all(8),
          //               child: Center(
          //                 child: CircularProgressIndicator(),
          //               ),
          //             )
          //                 : const SizedBox.shrink();
          //           }
          //
          //           final chat = chatList[index];
          //           return ChatTile(
          //             name: chat.otherUser?.nickName ?? "No Name",
          //             message: chat.latestMessage?.message ?? "",
          //             time: chat.latestMessage?.createdAt ?? "",
          //             imagePath: chat.otherUser?.avatar ??
          //                 "assets/images/person1.png",
          //             onTap: () {
          //               context.pushNamed(RouteName.message);
          //             },
          //           );
          //         },
          //       ),
          //     );
          //   }),
          // )




        ],
      ),


    );
  }
}
