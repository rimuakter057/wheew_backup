
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:platchatapp/feature/chat/model/chat_model.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/helper/data_converter/data_converter.dart';
import '../../../core/router/routes_name.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../utils/app_const/app_const.dart';
import '../../../utils/color/app_colors.dart';

import 'widgets/chat_tile.dart';

class SearchListScreen extends StatefulWidget {
  const SearchListScreen({super.key});

  @override
  State<SearchListScreen> createState() => _SearchListScreenState();
}

class _SearchListScreenState extends State<SearchListScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final ChatController controller =Get.find<ChatController>();

  @override
  void initState() {
    super.initState();


    // Auto focus the search field
    Future.delayed(const Duration(milliseconds: 200), () {
      _focusNode.requestFocus();
    });



  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
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
      ),
      body: GetBuilder<ChatController>(
        init: Get.find<ChatController>(),
        builder: (controller) {
          final displayList = controller.searchResults;

          return Column(
            children: [
              // Search bar
              Padding(
                padding: EdgeInsets.all(ResponsiveHelper.padding(12)),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: (value) => controller.searchUsers(value),
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
                    suffixIcon: controller.isSearching
                        ? Padding(
                      padding: EdgeInsets.all(
                        ResponsiveHelper.padding(12),
                      ),
                      child: SizedBox(
                        width: ResponsiveHelper.width(20),
                        height: ResponsiveHelper.height(20),
                        child: CircularProgressIndicator(
                          strokeWidth: ResponsiveHelper.borderWidth(2),
                        ),
                      ),
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.borderRadius(30),
                      ),
                    ),
                  ),
                ),
              ),

              // Search results
              Expanded(
                child: !controller.hasSearched
                    ? const SizedBox() // ← screen open হলে সম্পূর্ণ empty
                    : controller.isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : controller.searchResults.isEmpty
                    ? const Center(
                  child: Text(
                    "No users found",
                    style: TextStyle(fontSize: 16),
                  ),
                )
                    : ListView.builder(
                  itemCount: controller.searchResults.length,
                  itemBuilder: (context, index) {
                    final user = controller.searchResults[index];
                    return ChatTile(
                      isBlock: false,
                      name: user.nickName ?? '',
                      message: user.designation ?? '',
                      fontWeight: FontWeight.w400,
                      time: user.createdAt != null
                          ? formatTime(user.createdAt.toString())
                          : '',
                      imagePath: user.avatar ?? AppConst.unknown,

                      onTap: () async {
                        // ✅ navigate করার আগে roomId নাও
                        final roomId = user.existingRoom?.id ?? '';

                        // ✅ roomID clear করো যাতে নতুন value track করা যায়
                        controller.roomID.value = roomId;

                        await context.pushNamed(
                          RouteName.message,
                          extra: {
                            'roomId': roomId,
                            'otherUserName': user.nickName,
                            'otherUserAvatar': user.avatar ?? AppConst.unknown,
                            'receiverId': user.id,
                            "isBlockedByMe": false,
                            "isBlockedMe": false,
                          },
                        );

                        // ✅ Message screen থেকে ফিরে আসার পর
                        // controller.roomID.value এ নতুন roomId থাকবে
                        final newRoomId = controller.roomID.value;
                        if (newRoomId.isNotEmpty && (user.existingRoom?.id ?? '') != newRoomId) {
                          setState(() {
                            user.existingRoom = ExistingRoom2(id: newRoomId);
                          });
                        }
                      },




                    );
                  },
                ),
              ),


            ],
          );
        },
      ),
    );
  }
}