import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import 'package:platchatapp/feature/chat/view/message_screen.dart';
import 'package:platchatapp/feature/chat/view/widgets/chat_list_screen_shimmer.dart';
import 'package:platchatapp/feature/helper/custom_image/custom_image.dart';
import 'package:platchatapp/helper/data_converter/data_converter.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import '../../../core/router/routes_name.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../utils/assets_path/assets_path.dart';
import '../repository/chat_controller.dart';
import '../../profile/repository/profile_controller.dart';
import '../../profile/view/app_menu_drawer.dart';
import 'widgets/chat_tile.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {


  final ChatController controller = Get.find<ChatController>();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

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

      // ✅ Load profile data when chat list opens
      Get.find<ProfileController>().reloadProfile();
    });

    scrollController.addListener(_onScroll);

    // ✅ FIX: chat list update হলেই (নতুন data আসার পর) check করো
    // content screen পূরণ করার মতো যথেষ্ট আছে কিনা। যদি না থাকে এবং
    // আরও data থাকে (hasMore == true), automatically পরের page load করো.
    // এটা জরুরি কারণ ছোট list (যেখানে scroll করার জায়গাই নেই) এর জন্য
    // scroll-based pagination কখনোই trigger হয় না, ফলে বাকি data
    // লোডই হয় না।
    controller.userChatList.listen((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkIfNeedMoreData();
      });
    });
  }

  void _onScroll() {
    if (!scrollController.hasClients) return; // ✅ safety check

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent -
            200 && // ✅ 200px threshold
        controller.hasMore &&
        !controller.isLoadingMore.value &&
        !controller.isLoadingChat.value) {
      // ✅ first load চলাকালীন trigger হবে না
      controller.fetchChatList(loadMore: true);
    }
  }

  // ✅ FIX: scroll করার মতো content না থাকলেও (maxScrollExtent == 0)
  // বাকি data load করার জন্য। ছোট chat list এ এটাই মূল সমাধান।
  void _checkIfNeedMoreData() {
    if (!scrollController.hasClients) return;

    if (scrollController.position.maxScrollExtent == 0 &&
        controller.hasMore &&
        !controller.isLoadingMore.value &&
        !controller.isLoadingChat.value) {
      controller.fetchChatList(loadMore: true);
    }
  }

  // final ChatController controller = Get.find<ChatController>();
  // final ScrollController scrollController = ScrollController();
  //
  // @override
  // void initState() {
  //   super.initState();
  //
  //   if (!AppSocket.isConnected) {
  //     AppSocket.init(
  //       onSocketConnect: () {
  //         debugPrint('Socket connected from ChatListScreen');
  //       },
  //     );
  //   }
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     controller.initSocketListeners();
  //     controller.fetchChatList(refresh: true);
  //     controller.newMessage();
  //
  //     // ✅ Load profile data when chat list opens
  //     Get.find<ProfileController>().reloadProfile();
  //   });
  //
  //   scrollController.addListener(_onScroll);
  // }
  //
  // void _onScroll() {
  //   if (!scrollController.hasClients) return; // ✅ safety check
  //
  //   if (scrollController.position.pixels >=
  //       scrollController.position.maxScrollExtent - 200 && // ✅ 200px threshold
  //       controller.hasMore &&
  //       !controller.isLoadingMore.value &&
  //       !controller.isLoadingChat.value) { // ✅ first load চলাকালীন trigger হবে না
  //     controller.fetchChatList(loadMore: true);
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
        title: Stack(
          alignment: Alignment.center,
          children: [
                CustomImage(
                  imageSrc: AssetsPath.wheew,
                  height: ResponsiveHelper.height(28),
                  fit: BoxFit.contain,
                ),
            // Row(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     Lottie.asset(
            //       'assets/animations/icon_animated.json',
            //       width: ResponsiveHelper.iconSize(28),
            //       height: ResponsiveHelper.iconSize(28),
            //       fit: BoxFit.cover,
            //       repeat: true,
            //     ),
            //     SizedBox(width: ResponsiveHelper.spacing(6)),
            //     CustomImage(
            //       imageSrc: AssetsPath.chatList,
            //       height: ResponsiveHelper.height(28),
            //       fit: BoxFit.contain,
            //     ),
            //   ],
            // ),
          ],
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
                  // ✅ Reload profile every time drawer opens
                  Get.find<ProfileController>().reloadProfile();
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),

      // ✅ Also reload on drawer open/close
      onEndDrawerChanged: (isOpen) {
        if (isOpen) {
          Get.find<ProfileController>().reloadProfile();
        }
      },

      endDrawer: const AppMenuDrawer(),

      body: SafeArea(
        top: true,
        bottom: true,
        child: RefreshIndicator(
          color: AppColors.white,
          backgroundColor: AppColors.blueClient,
          onRefresh: () => controller.fetchChatList(refresh: true),
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
                  /// First load
                  if (controller.isLoadingChat.value &&
                      controller.userChatList.isEmpty) {
                    return const ChatListShimmer();
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
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: ResponsiveHelper.fontSize(18),
                              color: AppColors.black,

                            ),
                          ),
                        ),
                      ],
                    );
                  }

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
                        name: room.otherUser?.nickName ?? 'No Name',
                        message: room.latestMessage?.message ?? '',
                        fontWeight:  (room.latestMessage?.isRead ?? true)
                            ? FontWeight.w400
                            : FontWeight.w700,
                        time: formatTime(room.latestMessage?.createdAt ?? ''),
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
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
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
