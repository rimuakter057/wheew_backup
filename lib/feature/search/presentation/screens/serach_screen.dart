// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/chat/model/chat_model.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/helper/data_converter/data_converter.dart';
import 'package:platchatapp/share/widgets/avatar/user_avatar.dart' show UserAvatar;
import 'package:platchatapp/utils/extension/base_extension.dart';
import '../../../../core/router/routes_name.dart';
import '../../../../helper/responsive_helper/responsive_helper.dart';
import '../../../../utils/app_const/app_const.dart';
import '../../../../utils/color/app_colors.dart';

import '../../../chat/view/widgets/chat_tile.dart';

class SearchListScreen extends StatefulWidget {
  const SearchListScreen({super.key});

  @override
  State<SearchListScreen> createState() => _SearchListScreenState();
}

class _SearchListScreenState extends State<SearchListScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final ChatController controller = Get.find<ChatController>();

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
        leading: IconButton(onPressed: (){
          context.pop();
        }, icon: Icon(Icons.arrow_back_ios,color: AppColors.black,)),
        title: Text(

          'Search Drivers'.tr,
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
                    hintText: 'Search by name or vehicle code...'.tr,
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

              // Search results
              // Search results
          Expanded(
          child: Obx(() => !controller.hasSearched.value
          ? const SizedBox()
              : controller.isSearching.value
          ? const Center(child: CircularProgressIndicator())
              : controller.searchResults.isEmpty
          ?  Center(
          child: Text("No users found", style:context.bodySmall.copyWith(color: AppColors.black)),
          )
              :  ListView.builder(
          itemCount: controller.searchResults.length,
          itemBuilder: (context, index) {
          final user = controller.searchResults[index];


                    return GestureDetector(
                      onTap: () async {
                        await controller.createMessageRequest(
                          receiverId: user.id ?? '',
                          firstMessage: "Hi, can I message you?",
                          context: context,
                        );
                      },
                      child: Container(
                        padding: ResponsiveHelper.all(16),
                        margin: ResponsiveHelper.symmetric(horizontal: 12,vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.greyBorder),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                UserAvatar(imagePath: user.avatar ?? AppConst.unknown),
                                SizedBox(width: ResponsiveHelper.width(12)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.nickName ?? '',
                                        style: context.bodyMedium.copyWith(color: AppColors.black,fontSize: ResponsiveHelper.fontSize(16)),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.orange, size: ResponsiveHelper.iconSize(14)),
                                          SizedBox(width: ResponsiveHelper.width(4)),
                                          Text(
                                            user.rating!.toStringAsFixed(1),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.questrial(
                                              fontSize: ResponsiveHelper.fontSize(14),
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textBlack,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // child: ChatTile(
                        //   isBlock: false,
                        //   name: user.nickName ?? '',
                        //   message: user.designation ?? '',
                        //   fontWeight: FontWeight.w400,
                        //   time: user.createdAt != null
                        //       ? formatTime(user.createdAt.toString())
                        //       : '',
                        //   imagePath:
                        //   user.avatar ?? AppConst.unknown,
                        //
                        //   onTap: () async {
                        //     final roomId =
                        //         user.existingRoom?.id ?? '';
                        //
                        //     debugPrint(
                        //       "before search navigate room id================================== $roomId",
                        //     );
                        //
                        //     controller.roomID.value = roomId;
                        //
                        //     await context.pushNamed(
                        //       RouteName.message,
                        //       extra: {
                        //         'roomId': roomId,
                        //         'otherUserName': user.nickName,
                        //         'otherUserAvatar':
                        //         user.avatar ??
                        //             AppConst.unknown,
                        //         'receiverId': user.id,
                        //         "isBlockedByMe": false,
                        //         "isBlockedMe": false,
                        //         'voiceAutoSend': false,
                        //         'voiceMessage': null,
                        //       },
                        //     );
                        //
                        //     debugPrint(
                        //       "after search navigate room id================================== $roomId",
                        //     );
                        //
                        //     final newRoomId =
                        //         controller.roomID.value;
                        //
                        //     if (newRoomId.isNotEmpty &&
                        //         (user.existingRoom?.id ?? '') !=
                        //             newRoomId) {
                        //       setState(() {
                        //         user.existingRoom =
                        //             ExistingRoom2(
                        //               id: newRoomId,
                        //             );
                        //       });
                        //     }
                        //   },
                        // ),
                      ),
                    );
                  },
                ),
              ),
          ),
            ],
          );
        },
      ),
    );
  }
}
