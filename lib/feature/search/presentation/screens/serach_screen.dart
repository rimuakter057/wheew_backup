// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:platchatapp/utils/language/app_string.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/chat/model/chat_model.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/helper/data_converter/data_converter.dart';
import 'package:platchatapp/share/widgets/avatar/user_avatar.dart'
    show UserAvatar;
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

  // ✅ Send Request dialog
  void _showSendRequestDialog(BuildContext context, dynamic user) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return _SendRequestDialog(user: user, controller: controller);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.primaryBackgroundGradient),
      child: Scaffold(
           backgroundColor: Colors.transparent,
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
                                color: Colors.grey[400],
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                size: ResponsiveHelper.iconSize(22),
                                color: Colors.grey[500],
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
                                  color: Colors.grey[500],
                                ),
                              )
                                  : null,
                              filled: true,
                              fillColor: Colors.transparent,
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
                              "No users found",
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
                                // ✅ পুরো card এর onTap শুধু roomId থাকলেই কাজ করবে
                                onTap: hasRoom
                                    ? () async {
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
                                      }
                                    : null, // ✅ roomId না থাকলে card tap এ কিছু হবে না
                                child: Container(
                                  padding: ResponsiveHelper.all(20),
                                  margin: ResponsiveHelper.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFFFFF),
                                        Color(0xFFC6D2E2),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      ResponsiveHelper.borderRadius(32),
                                    ),
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
                                                color: Colors.grey[500],
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
                                                color: AppColors.black,
                                                borderRadius:
                                                    BorderRadius.circular(20),
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
                                                    // ✅ শুধু এই badge এ tap করলেই request dialog খুলবে
                                                    onTap: () =>
                                                        _showSendRequestDialog(
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
                                                            color: Colors.white,
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
                                                                  Colors.white,
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

// ✅ Send Request Dialog কে আলাদা StatefulWidget হিসেবে বানানো হলো
class _SendRequestDialog extends StatefulWidget {
  final dynamic user;
  final ChatController controller;

  const _SendRequestDialog({required this.user, required this.controller});

  @override
  State<_SendRequestDialog> createState() => _SendRequestDialogState();
}

class _SendRequestDialogState extends State<_SendRequestDialog> {
  final TextEditingController messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // ✅ layout শেষ হওয়ার পর focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && messageFocusNode.canRequestFocus) {
        messageFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    // ✅ এটা তখনই কল হবে যখন widget আসলেই tree থেকে সরে যাবে (animation শেষে)
    messageController.dispose();
    messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          padding: EdgeInsets.all(ResponsiveHelper.width(20)),
          decoration: BoxDecoration(

            gradient: LinearGradient(
              colors: [Colors.white, Color(0xFFD4DDE9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: ResponsiveHelper.height(4)),
                    Container(
                      width: ResponsiveHelper.width(64),
                      height: ResponsiveHelper.width(64),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.blue, AppColors.darBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blue.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: ResponsiveHelper.iconSize(26),
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.height(14)),
                    Text(
                      AppStrings.sendMessageRequest.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.fontSize(17),
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.height(6)),
                    Text(
                      AppStrings.writeAShortMessageToIntroduceYourself.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.fontSize(13),
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.height(18)),
                    TextFormField(
                      controller: messageController,
                      focusNode: messageFocusNode,
                      maxLines: 3,
                      style: TextStyle(fontSize: ResponsiveHelper.fontSize(14)),
                      decoration: InputDecoration(
                        hintText: AppStrings.hiCanIMessageYou.tr,
                        hintStyle: TextStyle(
                          fontSize: ResponsiveHelper.fontSize(14),
                          color: Colors.grey[400],
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: EdgeInsets.all(
                          ResponsiveHelper.width(16),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: AppColors.blue,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Colors.redAccent),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.messageIsRequired.tr;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: ResponsiveHelper.height(22)),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            // ✅ শুধু pop() — কোনো manual dispose/unfocus দরকার নেই
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              padding: EdgeInsets.symmetric(
                                vertical: ResponsiveHelper.height(13),
                              ),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              AppStrings.cancel.tr,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                                fontSize: ResponsiveHelper.fontSize(14),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: ResponsiveHelper.width(12)),
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                colors: [AppColors.blue, AppColors.darBlue],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  final msg = messageController.text.trim();
                                  final navigator = Navigator.of(context);
                                  final ctrl = widget.controller;
                                  final u = widget.user;

                                  navigator.pop(); // dialog বন্ধ

                                  await ctrl.createMessageRequest(
                                    receiverId: u.id ?? '',
                                    firstMessage: msg,
                                    context: context,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                  vertical: ResponsiveHelper.height(13),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                AppStrings.send.tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: ResponsiveHelper.fontSize(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close_rounded,
                      size: ResponsiveHelper.iconSize(20),
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
