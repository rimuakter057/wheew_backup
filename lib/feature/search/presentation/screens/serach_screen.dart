// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/chat/model/chat_model.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/share/widgets/avatar/user_avatar.dart' show UserAvatar;
import 'package:platchatapp/utils/extension/base_extension.dart';
import '../../../../core/router/routes_name.dart';
import '../../../../helper/responsive_helper/responsive_helper.dart';
import '../../../../utils/app_const/app_const.dart';
import '../../../../utils/color/app_colors.dart';


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
    controller.searchResults.clear();
    controller.hasSearched.value = false;
    controller.isSearching.value = false;

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    controller.searchResults.clear();
    controller.hasSearched.value = false;
    controller.isSearching.value = false;
    super.dispose();
  }

  // ✅ Send Request — full screen (preset picker + normal send), no dialog/input field
  void _openSendRequestScreen(BuildContext context, dynamic user) {
    context.pushNamed(
      RouteName.message,
      extra: {
        'roomId': '',
        'otherUserName': user.nickName ?? '',
        'otherUserAvatar': user.avatar ?? '',
        'receiverId': user.id ?? '',
        'licenceId': user.licenceId ?? '',
        'isSendRequest': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.primaryBackgroundGradient),
      child: Scaffold(
           backgroundColor: AppColors.transparent,
        body: GetBuilder<ChatController>(
          init: Get.find<ChatController>(),
          builder: (controller) {
            final displayList = controller.searchResults;

            return Column(
              children: [


           SizedBox(height: ResponsiveHelper.height(80),),
                // Search bar
                // Search bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.padding(12),
                    vertical: ResponsiveHelper.padding(12),
                  ),
                  child: Row(
                    children: [
                      // ✅ Circular Back Button
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: ResponsiveHelper.width(48),
                          height: ResponsiveHelper.width(48),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFFFFF), Color(0xFFE9EEF5)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF071224).withValues(alpha: 0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: ResponsiveHelper.iconSize(18),
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.width(10)),

                      // ✅ Search Field
                      Expanded(
                        child: Container(
                          height: ResponsiveHelper.height(48),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFFFFF), Color(0xFFE9EEF5)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.borderRadius(30),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF071224).withValues(alpha: 0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            onChanged: (value) {
                              controller.searchUsers(value);
                              setState(() {}); // ✅ clear icon show/hide রিফ্রেশ করার জন্য
                            },
                            style: TextStyle(fontSize: ResponsiveHelper.fontSize(15)),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              hintText: AppStrings.searchByNameOrVehicleCode.tr,
                              hintStyle: TextStyle(
                                fontSize: ResponsiveHelper.fontSize(15),
                                color: AppColors.grey[400],
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                size: ResponsiveHelper.iconSize(22),
                                color: AppColors.grey[500],
                              ),
                              // ✅ Clear (X) icon — শুধু text থাকলেই দেখাবে
                              suffixIcon: _controller.text.isNotEmpty
                                  ? GestureDetector(
                                onTap: () {
                                  _controller.clear();
                                  controller.searchUsers('');
                                  setState(() {});
                                },
                                child: Icon(
                                  Icons.close_rounded,
                                  size: ResponsiveHelper.iconSize(20),
                                  color: AppColors.grey[500],
                                ),
                              )
                                  : null,
                              filled: true,
                              fillColor: AppColors.transparent,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: ResponsiveHelper.height(14),
                                horizontal: ResponsiveHelper.width(4),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search results
                Expanded(
                  child: Obx(
                    () => !controller.hasSearched.value
                        ? const SizedBox()
                        : controller.isSearching.value
                        ? const Center(child: CircularProgressIndicator())
                        : controller.searchResults.isEmpty
                        ? Center(
                            child: Text(
                              AppStrings.noUsersFound.tr,
                              style: context.bodySmall.copyWith(
                                color: AppColors.black,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: controller.searchResults.length,
                            itemBuilder: (context, index) {
                              final user = controller.searchResults[index];
                              final roomId = user.existingRoom?.id ?? '';
                              final hasRoom = roomId.isNotEmpty;

                              return GestureDetector(
                                onTap: () async {
                                  if (hasRoom) {
                                    debugPrint(
                                      "room exists, navigating directly ================================== $roomId",
                                    );

                                    controller.roomID.value = roomId;

                                    await context.pushNamed(
                                      RouteName.message,
                                      extra: {
                                        'roomId': roomId,
                                        'otherUserName': user.nickName,
                                        'otherUserAvatar':
                                            user.avatar ?? AppConst.unknown,
                                        'receiverId': user.id,
                                        "isBlockedByMe": false,
                                        "isBlockedMe": false,
                                        'voiceAutoSend': false,
                                        'voiceMessage': null,
                                      },
                                    );

                                    final newRoomId =
                                        controller.roomID.value;

                                    if (newRoomId.isNotEmpty &&
                                        (user.existingRoom?.id ?? '') !=
                                            newRoomId) {
                                      setState(() {
                                        user.existingRoom = ExistingRoom2(
                                          id: newRoomId,
                                        );
                                      });
                                    }
                                  } else {
                                    // Already-pending users must reopen on the
                                    // "Request Sent / Pending Review" view, not
                                    // the compose screen — pass the existing
                                    // requestId so MessageScreen picks it up.
                                    final existingRequestId =
                                        user.isMessageRequestSent == true
                                            ? (user.messageRequest?['id']
                                                    ?.toString() ??
                                                '')
                                            : '';
                                    context.pushNamed(
                                      RouteName.message,
                                      extra: {
                                        'roomId': '',
                                        'otherUserName': user.nickName,
                                        'otherUserAvatar': user.avatar ?? AppConst.unknown,
                                        'receiverId': user.id,
                                        'licenceId': user.licenceId ?? '',
                                        'isSendRequest': true,
                                        if (existingRequestId.isNotEmpty)
                                          'requestId': existingRequestId,
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  // Was all(20) with a 32 radius, which made
                                  // every row ~90px tall for a 48px avatar —
                                  // mostly empty space. Tighter padding and a
                                  // radius proportional to the new height.
                                  padding: ResponsiveHelper.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  margin: ResponsiveHelper.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient:AppColors.containerGradient,
                                    borderRadius: BorderRadius.circular(
                                      ResponsiveHelper.borderRadius(20),
                                    ),
                                    border: Border.all(color: AppColors.white,width: 0.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF071224,
                                        ).withValues(alpha: 0.06),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: ResponsiveHelper.width(48),
                                        height: ResponsiveHelper.width(48),
                                        child: ClipOval(
                                          child: UserAvatar(
                                            imagePath:
                                                user.avatar ?? AppConst.unknown,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: ResponsiveHelper.width(12),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user.nickName ?? '',
                                              style: context.bodyMedium.copyWith(
                                                color: AppColors.black,
                                                fontWeight: FontWeight.w700,
                                                fontSize:
                                                    ResponsiveHelper.fontSize(
                                                      16,
                                                    ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: ResponsiveHelper.height(
                                                4,
                                              ),
                                            ),
                                            Text(
                                              user.licenceId,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.questrial(
                                                fontSize:
                                                    ResponsiveHelper.fontSize(
                                                      14,
                                                    ),
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(
                                        width: ResponsiveHelper.width(8),
                                      ),

                                      // ✅ badge — নিজের আলাদা tap handler
                                      hasRoom
                                          ? Container(
                                              padding:
                                                  ResponsiveHelper.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.blue,
                                                    AppColors.darBlue,
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.blue
                                                        .withValues(alpha: 0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.chat_bubble_outline,
                                                    size:
                                                        ResponsiveHelper.iconSize(
                                                          14,
                                                        ),
                                                    color: AppColors.white,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        ResponsiveHelper.width(
                                                          4,
                                                        ),
                                                  ),
                                                  Text(
                                                    AppStrings.message.tr,
                                                    style: TextStyle(
                                                      color: AppColors.white,
                                                      fontSize:
                                                          ResponsiveHelper.fontSize(
                                                            12,
                                                          ),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : (user.isMessageRequestSent == true
                                                ? Container(
                                                    padding:
                                                        ResponsiveHelper.symmetric(
                                                          horizontal: 14,
                                                          vertical: 7,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.white,
                                                      border: Border.all(
                                                        color: AppColors.blue,
                                                        width: 1.2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            30,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      (user.messageRequest?['status']
                                                                  ?.toString() ??
                                                              'Pending')
                                                          .tr,
                                                      style: TextStyle(
                                                        color: AppColors.blue,
                                                        fontSize:
                                                            ResponsiveHelper.fontSize(
                                                              12,
                                                            ),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  )
                                                : GestureDetector(
                                                    // ✅ শুধু এই badge এ tap করলেই send-request স্ক্রিন খুলবে
                                                    onTap: () =>
                                                        _openSendRequestScreen(
                                                          context,
                                                          user,
                                                        ),
                                                    child: Container(
                                                      padding:
                                                          ResponsiveHelper.symmetric(
                                                            horizontal: 14,
                                                            vertical: 7,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              30,
                                                            ),
                                                        gradient:
                                                            LinearGradient(
                                                              colors: [
                                                                AppColors.blue,
                                                                AppColors
                                                                    .darBlue,
                                                              ],
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                            ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: AppColors
                                                                .blue
                                                                .withValues(
                                                                  alpha: 0.3,
                                                                ),
                                                            blurRadius: 8,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  4,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.send_rounded,
                                                            size:
                                                                ResponsiveHelper.iconSize(
                                                                  12,
                                                                ),
                                                            color: AppColors.white,
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                ResponsiveHelper.width(
                                                                  4,
                                                                ),
                                                          ),
                                                          Text(
                                                            AppStrings
                                                                .sendRequest
                                                                .tr,
                                                            style: TextStyle(
                                                              color:
                                                                  AppColors.white,
                                                              fontSize:
                                                                  ResponsiveHelper.fontSize(
                                                                    12,
                                                                  ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )),
                                    ],
                                  ),
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
      ),
    );
  }
}



