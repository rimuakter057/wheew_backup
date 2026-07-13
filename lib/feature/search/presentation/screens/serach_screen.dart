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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back_ios, color: AppColors.black),
        ),
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
                    hintStyle: TextStyle(fontSize: ResponsiveHelper.fontSize(16)),
                    prefixIcon: Icon(Icons.search, size: ResponsiveHelper.iconSize(24)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(30)),
                    ),
                  ),
                ),
              ),

              // Search results
              Expanded(
                child: Obx(() => !controller.hasSearched.value
                    ? const SizedBox()
                    : controller.isSearching.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.searchResults.isEmpty
                    ? Center(
                  child: Text(
                    "No users found",
                    style: context.bodySmall.copyWith(color: AppColors.black),
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
                            'otherUserAvatar': user.avatar ?? AppConst.unknown,
                            'receiverId': user.id,
                            "isBlockedByMe": false,
                            "isBlockedMe": false,
                            'voiceAutoSend': false,
                            'voiceMessage': null,
                          },
                        );

                        final newRoomId = controller.roomID.value;

                        if (newRoomId.isNotEmpty &&
                            (user.existingRoom?.id ?? '') != newRoomId) {
                          setState(() {
                            user.existingRoom = ExistingRoom2(id: newRoomId);
                          });
                        }
                      }
                          : null, // ✅ roomId না থাকলে card tap এ কিছু হবে না
                      child: Container(
                        padding: ResponsiveHelper.all(16),
                        margin: ResponsiveHelper.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.greyBorder),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            UserAvatar(imagePath: user.avatar ?? AppConst.unknown),
                            SizedBox(width: ResponsiveHelper.width(12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.nickName ?? '',
                                    style: context.bodyMedium.copyWith(
                                      color: AppColors.black,
                                      fontSize: ResponsiveHelper.fontSize(16),
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveHelper.height(4)),
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

                            SizedBox(width: ResponsiveHelper.width(8)),

                            // ✅ badge — নিজের আলাদা tap handler
                            hasRoom
                                ? Container(
                              padding: ResponsiveHelper.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.chat_bubble_outline,
                                      size: ResponsiveHelper.iconSize(14), color: AppColors.white),
                                  SizedBox(width: ResponsiveHelper.width(4)),
                                  Text(
                                    "Message".tr,
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: ResponsiveHelper.fontSize(12),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : GestureDetector(
                              // ✅ শুধু এই badge এ tap করলেই request dialog খুলবে
                              onTap: () => _showSendRequestDialog(context, user),
                              child: Container(
                                padding: ResponsiveHelper.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  border: Border.all(color: AppColors.black),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Send Request".tr,
                                  style: TextStyle(
                                    color: AppColors.black,
                                    fontSize: ResponsiveHelper.fontSize(12),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
              ),
            ],
          );
        },
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: AppColors.blue,
                        size: ResponsiveHelper.iconSize(20),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.width(12)),
                    Expanded(
                      child: Text(
                        "Send Message Request".tr,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.fontSize(17),
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.close_rounded,
                        size: ResponsiveHelper.iconSize(20),
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: ResponsiveHelper.height(6)),

                Text(
                  "Write a short message to introduce yourself".tr,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(13),
                    color: Colors.grey[500],
                  ),
                ),

                SizedBox(height: ResponsiveHelper.height(16)),

                TextFormField(
                  controller: messageController,
                  focusNode: messageFocusNode,
                  maxLines: 3,
                  style: TextStyle(fontSize: ResponsiveHelper.fontSize(14)),
                  decoration: InputDecoration(
                    hintText: "Hi, can I message you?".tr,
                    hintStyle: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(14),
                      color: Colors.grey[400],
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: EdgeInsets.all(ResponsiveHelper.width(14)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.blue, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.redAccent),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Message is required".tr;
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
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.height(12),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Cancel".tr,
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
                          backgroundColor: AppColors.blue,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.height(12),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Send".tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: ResponsiveHelper.fontSize(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
