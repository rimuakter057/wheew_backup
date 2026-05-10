import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import 'package:platchatapp/feature/chat/view/message_screen.dart';
import 'package:platchatapp/feature/chat/view/widgets/chat_list_screen_shimmer.dart';
import 'package:platchatapp/helper/data_converter/data_converter.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import 'package:platchatapp/utils/extension/base_extension.dart';
import '../../../core/router/routes_name.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../share/widgets/custom_image/custom_image.dart';
import '../../../utils/assets_path/assets_path.dart';
import '../repository/chat_controller.dart';
import '../../profile/repository/profile_controller.dart';
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
  }

  void _onScroll() {
    if (!scrollController.hasClients) return; // ✅ safety check

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200 && // ✅ 200px threshold
        controller.hasMore &&
        !controller.isLoadingMore.value &&
        !controller.isLoadingChat.value) { // ✅ first load চলাকালীন trigger হবে না
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
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: true,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  AssetsPath.homeJson,
                  width: ResponsiveHelper.iconSize(28),
                  height: ResponsiveHelper.iconSize(28),
                  fit: BoxFit.cover,
                  repeat: true,
                ),
                SizedBox(width: ResponsiveHelper.spacing(6)),
                CustomImage(
                  imageSrc: AssetsPath.chatList,
                  height: ResponsiveHelper.height(28),
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              _showCreateGroup(context: context, name: 'Rimu');
            },
            child: Padding(
              padding: EdgeInsets.only(right: ResponsiveHelper.width(16)),
              child: CircleAvatar(
                radius: ResponsiveHelper.iconSize(25),
                backgroundColor: AppColors.greyShade,
                child: CustomImage(
                  imageSrc: AssetsPath.group,
                  height: ResponsiveHelper.iconSize(25),
                  width: ResponsiveHelper.iconSize(25),
                ),
              ),
            ),
          ),
        ],
      ),

      body: RefreshIndicator(
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
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: ResponsiveHelper.fontSize(18),
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
                      fontWeight: room.latestMessage!.isRead == true
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
    );
  }









  void _showCreateGroup({
    required BuildContext context,
    required String name,
  })
  {
    final TextEditingController _groupNameController = TextEditingController();
    final TextEditingController _descriptionController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.spacing(24),
          ),
          child: Container(
            padding: EdgeInsets.only(
              top: ResponsiveHelper.spacing(20),
              left: ResponsiveHelper.spacing(20),
              right: ResponsiveHelper.spacing(20),
              bottom: ResponsiveHelper.spacing(24),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.borderRadius(24),
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Close Button ──────────────────────────
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(ResponsiveHelper.spacing(4)),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: ResponsiveHelper.iconSize(16),
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(4)),

                  // ── Title ─────────────────────────────────
                  Text(
                    "Create Group Chat",
                    style: context.bodyMedium.copyWith(color: AppColors.black),
                  ),
                  SizedBox(height: ResponsiveHelper.height(8)),

                  Text(
                    "Connect with multiple people at once",
                    style: context.bodySmall,
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(20)),

                  // ── Group Name Label ──────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Group Name *",
                      style: context.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.spacing(8)),

                  // ── Group Name TextField ──────────────────


                  TextFormField(
                    controller: _groupNameController,
                    style: TextStyle(fontSize: ResponsiveHelper.fontSize(13)),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a group name';
                      }
                      if (value.trim().length < 3) {
                        return 'Group name must be at least 3 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter group name...',
                    ),
                  ),

                  SizedBox(height: ResponsiveHelper.spacing(16)),


                  // ── Submit Button ─────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: ResponsiveHelper.buttonHeight(48),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final groupName = _groupNameController.text.trim();
                          final description = _descriptionController.text.trim();

                          Navigator.pop(context);

                          // ✅ এখানে আপনার ChatController এর group create method call করুন
                          // Get.find<ChatController>().createGroup(
                          //   groupName: groupName,
                          //   description: description,
                          // );

                          debugPrint('Group Name: $groupName');
                          debugPrint('Description: $description');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueClient,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.borderRadius(12),
                          ),
                        ),
                      ),
                      child: Text(
                        'Create Group',
                        style: context.bodySmall.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
