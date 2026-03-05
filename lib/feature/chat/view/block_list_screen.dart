// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/core/service/socket_service.dart';
import 'package:platchatapp/helper/data_converter/data_converter.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../repository/chat_controller.dart';
import 'widgets/chat_tile.dart';

class BlockListScreen extends StatefulWidget {
  const BlockListScreen({super.key});

  @override
  State<BlockListScreen> createState() => _BlockListScreenState();
}

class _BlockListScreenState extends State<BlockListScreen> {
  final ChatController controller = Get.find<ChatController>();

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
      controller.fetchBlockList(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: true,
        title: Text(
          "block_".tr,
          style: GoogleFonts.poppins(
            color: AppColors.black,
            fontSize: ResponsiveHelper.fontSize(18),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () => controller.fetchChatRooms(refresh: true),
        child: Obx(() {
          // final chatList = controller.userChatList;

          /// First load
          if (controller.isLoadingBlockList.value &&
              controller.userBlockList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          /// Empty state
          if (controller.userBlockList.isEmpty) {
            return ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * .3),
                Center(
                  child: Text(
                    'empty_block_list'.tr,
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
            itemCount: controller.userBlockList.length,
            itemBuilder: (context, index) {
              final block = controller.userBlockList[index];

              final user = block.blockedUser;
              final blockedUserId = block.id;

              return ChatTile(
                isBlock: true,
                onUnblock: () {
                  //
                  // controller.unBlock(blockedUserId!, context);
                  // controller.isBlockedByMe.value = false;
                },

                /// Name show
                name: user?.nickName ?? "Unknown",

                /// message এর জায়গায় status
                message: "blocked_user".tr,

                /// font weight normal
                fontWeight: FontWeight.w400,

                /// time show
                time: formatTime(block.createdAt ?? ""),

                /// image show
                imagePath: ImageHandler.imagesHandle(
                  user?.avatar ?? AppConst.unknown,
                  isProfile: true,
                ),

                onTap: () {
                  // debugPrint("Blocked user click: ${user?.nickName}");
                },
              );
            },
          );
        }),
      ),
    );
  }
}
