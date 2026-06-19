// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart' hide Config;
// import 'package:platchatapp/core/router/routes_name.dart';
// import 'package:platchatapp/feature/chat/model/group_message_response_model.dart';
// import 'package:platchatapp/feature/chat/model/user_chat_model.dart';
// import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
// import 'package:platchatapp/helper/image_handler/image_handler.dart';
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
// import 'package:platchatapp/share/widgets/custom_container/custom_container.dart';
// import 'package:platchatapp/share/widgets/custom_image/custom_image.dart';
// import 'package:platchatapp/utils/app_const/app_const.dart';
// import 'package:platchatapp/utils/color/app_colors.dart';
// import 'package:go_router/go_router.dart';
// import 'package:platchatapp/helper/data_converter/data_converter.dart';
//
// class GroupMessageScreen extends StatefulWidget {
//   final String roomId;
//   final String groupName;
//   final String groupImage;
//   final List<GroupMessage> groupMembers;
//
//   const GroupMessageScreen({
//     super.key,
//     required this.roomId,
//     required this.groupName,
//     required this.groupImage,
//     required this.groupMembers,
//   });
//
//   @override
//   State<GroupMessageScreen> createState() => _GroupMessageScreenState();
// }
//
// class _GroupMessageScreenState extends State<GroupMessageScreen> {
//   final ChatController controller = Get.find<ChatController>();
//   final ScrollController _scrollController = ScrollController();
//   bool _isEmojiVisible = false;
//   final FocusNode _focusNode = FocusNode();
//
//   @override
//   void initState() {
//     super.initState();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // ✅ Join group socket emit
//       controller.joinGroup(roomId: widget.roomId);
//       controller.fetchPresetMessages();
//
//       // ✅ Group messages fetch
//       controller.fetchGroupMessages(
//         roomId: widget.roomId,
//         refresh: true,
//       );
//
//       // ✅ Socket listen
//       controller.listenGroupMessages();
//     });
//
//     _scrollController.addListener(_onScroll);
//   }
//
//   void _onScroll() {
//     if (!_scrollController.hasClients) return;
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 200 &&
//         controller.hasMoreGroupMessage &&
//         !controller.isLoadingMoreGroupMessage.value &&
//         !controller.isLoadingGroupMessage.value) {
//       controller.fetchGroupMessages(roomId: widget.roomId);
//     }
//   }
//
//   @override
//   void dispose() {
//     // ✅ Screen বন্ধ হলে groupRoomID clear — নতুন message এই room এ add হবে না
//     controller.groupRoomID.value = '';
//     _scrollController.dispose();
//     _focusNode.dispose();
//     controller.messageController.clear();
//     super.dispose();
//   }
//
//   // ✅ Leave Group confirmation dialog
//   void _showLeaveGroupDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(
//             ResponsiveHelper.borderRadius(16),
//           ),
//         ),
//         title: Text(
//           'Leave Group',
//           style: GoogleFonts.poppins(
//             fontSize: ResponsiveHelper.fontSize(16),
//             fontWeight: FontWeight.w600,
//             color: AppColors.black,
//           ),
//         ),
//         content: Text(
//           'Are you sure you want to leave "${widget.groupName}"?',
//           style: GoogleFonts.poppins(
//             fontSize: ResponsiveHelper.fontSize(14),
//             color: Colors.grey.shade600,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: Text(
//               'Cancel',
//               style: GoogleFonts.poppins(
//                 fontSize: ResponsiveHelper.fontSize(14),
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           Obx(
//                 () => TextButton(
//               onPressed: controller.isLeavingGroup.value
//                   ? null
//                   : () {
//                 Navigator.pop(ctx); // dialog বন্ধ
//                 controller.leaveGroup(
//                   roomId: widget.roomId,
//                   context: context,
//                   navigateBack: true,
//                 );
//               },
//               child: controller.isLeavingGroup.value
//                   ? SizedBox(
//                 width: 16,
//                 height: 16,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   color: Colors.red,
//                 ),
//               )
//                   : Text(
//                 'Leave',
//                 style: GoogleFonts.poppins(
//                   fontSize: ResponsiveHelper.fontSize(14),
//                   color: Colors.red,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: Column(
//         children: [
//           SizedBox(height: ResponsiveHelper.height(20)),
//
//           // ── Header ──────────────────────────────────────
//           CustomContainer(
//             margin: EdgeInsets.all(ResponsiveHelper.padding(16)),
//             vertical: ResponsiveHelper.padding(16),
//             horizontal: ResponsiveHelper.padding(0),
//             backgroundColor: AppColors.greyShade,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: Icon(Icons.arrow_back, color: AppColors.black),
//                     ),
//                     CircleAvatar(
//                       radius: ResponsiveHelper.borderRadius(22),
//                       backgroundColor: AppColors.blueClient.withOpacity(0.2),
//                       backgroundImage: widget.groupImage.isNotEmpty
//                           ? NetworkImage(widget.groupImage)
//                           : null,
//                       child: widget.groupImage.isEmpty
//                           ? Icon(Icons.group, color: AppColors.blueClient)
//                           : null,
//                     ),
//                     SizedBox(width: ResponsiveHelper.spacing(12)),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.groupName,
//                           style: GoogleFonts.poppins(
//                             fontSize: ResponsiveHelper.fontSize(16),
//                             fontWeight: FontWeight.w600,
//                             color: AppColors.black,
//                           ),
//                         ),
//                         Text(
//                           '${widget.groupMembers.length} ${'members'.tr}',
//                           style: GoogleFonts.poppins(
//                             fontSize: ResponsiveHelper.fontSize(12),
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//
//                 // ── Popup Menu ──────────────────────────
//                 PopupMenuButton<String>(
//                   icon: Icon(Icons.more_vert, color: AppColors.black),
//                   onSelected: (value) {
//                     if (value == "AddMembers") {
//                       context.pushNamed(
//                         RouteName.addMemberScreen,
//                         extra: {'roomId': widget.roomId},
//                       );
//                     } else if (value == "LeaveGroup") {
//                       // ✅ Leave group confirmation dialog
//                       _showLeaveGroupDialog();
//                     }
//                   },
//                   itemBuilder: (context) => [
//                     PopupMenuItem<String>(
//                       value: "AddMembers",
//                       child: Row(
//                         children: [
//                           Icon(Icons.person_add_outlined,
//                               color: AppColors.black),
//                           SizedBox(width: 8),
//                           Text(
//                             'Add Members',
//                             style: GoogleFonts.poppins(
//                               fontSize: ResponsiveHelper.fontSize(14),
//                               color: AppColors.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem<String>(
//                       enabled: false,
//                       height: 1,
//                       child: Divider(height: 1, color: Colors.grey.shade200),
//                     ),
//                     PopupMenuItem<String>(
//                       value: "LeaveGroup",
//                       child: Row(
//                         children: [
//                           Icon(Icons.exit_to_app_outlined, color: Colors.red),
//                           SizedBox(width: 8),
//                           Text(
//                             'Leave Group',
//                             style: GoogleFonts.poppins(
//                               fontSize: ResponsiveHelper.fontSize(14),
//                               color: Colors.red,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           // ── Messages List ────────────────────────────────
//           Expanded(
//             child: Obx(() {
//               // ✅ First load shimmer
//               if (controller.isLoadingGroupMessage.value &&
//                   controller.groupMessageList.isEmpty) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               // ✅ Empty state
//               if (controller.groupMessageList.isEmpty) {
//                 return Center(
//                   child: Text(
//                     'no_messages'.tr,
//                     style: GoogleFonts.poppins(
//                       fontSize: ResponsiveHelper.fontSize(16),
//                       color: Colors.grey,
//                     ),
//                   ),
//                 );
//               }
//
//               return ListView.builder(
//                 controller: _scrollController,
//                 reverse: true,
//                 padding: EdgeInsets.symmetric(
//                   horizontal: ResponsiveHelper.width(16),
//                   vertical: ResponsiveHelper.height(8),
//                 ),
//                 itemCount: controller.groupMessageList.length + 1,
//                 itemBuilder: (context, index) {
//                   // ✅ Pagination loader
//                   if (index == controller.groupMessageList.length) {
//                     return controller.isLoadingMoreGroupMessage.value
//                         ? const Padding(
//                       padding: EdgeInsets.all(8),
//                       child: Center(child: CircularProgressIndicator()),
//                     )
//                         : const SizedBox.shrink();
//                   }
//
//                   final GroupMessageResponseModel msg =
//                   controller.groupMessageList[index];
//                   final bool isMine = msg.isMine == true;
//                   final String senderName = msg.sender?.nickName ?? '';
//                   final String senderAvatar = msg.sender?.avatar ?? '';
//                   final String text = msg.message ?? '';
//                   final String time = formatTime(msg.createdAt ?? '');
//
//                   return Padding(
//                     padding:
//                     EdgeInsets.only(bottom: ResponsiveHelper.height(8)),
//                     child: Align(
//                       alignment: isMine
//                           ? Alignment.centerRight
//                           : Alignment.centerLeft,
//                       child: Column(
//                         crossAxisAlignment: isMine
//                             ? CrossAxisAlignment.end
//                             : CrossAxisAlignment.start,
//                         children: [
//                           // ✅ Other user: avatar + name
//                           if (!isMine)
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 // Avatar
//                                 CircleAvatar(
//                                   radius: ResponsiveHelper.iconSize(16),
//                                   backgroundImage: senderAvatar.isNotEmpty
//                                       ? NetworkImage(
//                                     ImageHandler.imagesHandle(
//                                       senderAvatar,
//                                       isProfile: true,
//                                     ),
//                                   )
//                                       : null,
//                                   backgroundColor:
//                                   AppColors.blueClient.withOpacity(0.2),
//                                   child: senderAvatar.isEmpty
//                                       ? Icon(
//                                     Icons.person,
//                                     size: ResponsiveHelper.iconSize(16),
//                                     color: AppColors.blueClient,
//                                   )
//                                       : null,
//                                 ),
//                                 SizedBox(width: ResponsiveHelper.width(6)),
//
//                                 // Message bubble
//                                 Column(
//                                   crossAxisAlignment:
//                                   CrossAxisAlignment.start,
//                                   children: [
//                                     // Sender name
//                                     Padding(
//                                       padding: EdgeInsets.only(
//                                         left: ResponsiveHelper.width(4),
//                                         bottom: ResponsiveHelper.height(2),
//                                       ),
//                                       child: Text(
//                                         senderName,
//                                         style: GoogleFonts.poppins(
//                                           fontSize:
//                                           ResponsiveHelper.fontSize(11),
//                                           color: Colors.grey,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                     _buildBubble(text, isMine, time),
//                                   ],
//                                 ),
//                               ],
//                             ),
//
//                           // ✅ My message
//                           if (isMine) _buildBubble(text, isMine, time),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             }),
//           ),
//
//           // ── Message Input ────────────────────────────────
//           _messageInput(),
//         ],
//       ),
//     );
//   }
//
//   // ── Message Bubble ───────────────────────────────────────────
//   Widget _buildBubble(String text, bool isMine, String time) {
//     return Container(
//       constraints: BoxConstraints(
//         maxWidth: ResponsiveHelper.width(272),
//       ),
//       margin: EdgeInsets.symmetric(
//         vertical: ResponsiveHelper.height(2),
//       ),
//       padding: EdgeInsets.symmetric(
//         vertical: ResponsiveHelper.height(10),
//         horizontal: ResponsiveHelper.width(14),
//       ),
//       decoration: BoxDecoration(
//         color: isMine ? AppColors.blueClient : AppColors.greenClient,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(ResponsiveHelper.borderRadius(15)),
//           topRight: Radius.circular(ResponsiveHelper.borderRadius(15)),
//           bottomLeft: isMine
//               ? Radius.circular(ResponsiveHelper.borderRadius(15))
//               : Radius.zero,
//           bottomRight: isMine
//               ? Radius.zero
//               : Radius.circular(ResponsiveHelper.borderRadius(15)),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment:
//         isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: [
//           Text(
//             text,
//             style: GoogleFonts.poppins(color: AppColors.white),
//           ),
//           SizedBox(height: ResponsiveHelper.height(4)),
//           Text(
//             time,
//             style: GoogleFonts.poppins(
//               fontSize: ResponsiveHelper.fontSize(10),
//               color: AppColors.white.withOpacity(0.7),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Message Input ────────────────────────────────────────────
//   Widget _messageInput() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // ── Preset Messages (API from controller) ────────
//         Obx(() {
//           if (controller.isPresetLoading.value) {
//             return SizedBox(
//               height: ResponsiveHelper.height(40),
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 padding: EdgeInsets.symmetric(
//                   horizontal: ResponsiveHelper.padding(16),
//                 ),
//                 itemCount: 5,
//                 separatorBuilder: (_, __) =>
//                     SizedBox(width: ResponsiveHelper.spacing(8)),
//                 itemBuilder: (context, index) {
//                   return _presetShimmerChip();
//                 },
//               ),
//             );
//           }
//
//           if (controller.presetMessages.isEmpty) {
//             return const SizedBox.shrink();
//           }
//
//           return SizedBox(
//             height: ResponsiveHelper.height(40),
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               padding: EdgeInsets.symmetric(
//                 horizontal: ResponsiveHelper.padding(16),
//               ),
//               itemCount: controller.presetMessages.length,
//               separatorBuilder: (_, __) =>
//                   SizedBox(width: ResponsiveHelper.spacing(8)),
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onTap: () {
//                     controller.messageController.text =
//                     controller.presetMessages[index];
//                     controller.messageController.selection =
//                         TextSelection.fromPosition(
//                           TextPosition(
//                             offset: controller.messageController.text.length,
//                           ),
//                         );
//                   },
//                   child: Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: ResponsiveHelper.padding(14),
//                       vertical: ResponsiveHelper.padding(8),
//                     ),
//                     decoration: BoxDecoration(
//                       color: AppColors.blueClient.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(
//                         ResponsiveHelper.borderRadius(20),
//                       ),
//                       border: Border.all(
//                         color: AppColors.blueClient,
//                         width: 1,
//                       ),
//                     ),
//                     child: Text(
//                       controller.presetMessages[index],
//                       style: GoogleFonts.poppins(
//                         fontSize: ResponsiveHelper.fontSize(12),
//                         color: AppColors.blueClient,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//         }),
//
//         SizedBox(height: ResponsiveHelper.height(6)),
//
//         // ── Text Field (unchanged) ───────────────────────
//         Padding(
//           padding: EdgeInsets.fromLTRB(
//             ResponsiveHelper.padding(16),
//             ResponsiveHelper.padding(8),
//             ResponsiveHelper.padding(16),
//             ResponsiveHelper.padding(8),
//           ),
//           child: Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: ResponsiveHelper.padding(8),
//               vertical: ResponsiveHelper.padding(4),
//             ),
//             decoration: BoxDecoration(
//               color: AppColors.greyShade,
//               borderRadius:
//               BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.emoji_emotions, color: AppColors.black),
//                   onPressed: () {
//                     _focusNode.unfocus();
//                     setState(() => _isEmojiVisible = !_isEmojiVisible);
//                   },
//                 ),
//                 Expanded(
//                   child: TextField(
//                     focusNode: _focusNode,
//                     controller: controller.messageController,
//                     minLines: 1,
//                     maxLines: 3,
//                     onTap: () {
//                       if (_isEmojiVisible) {
//                         setState(() => _isEmojiVisible = false);
//                       }
//                     },
//                     decoration: InputDecoration(
//                       hintText: "Type here...",
//                       fillColor: AppColors.greyShade,
//                       hintStyle: TextStyle(
//                         color: AppColors.black,
//                         fontSize: ResponsiveHelper.fontSize(16),
//                       ),
//                       border: InputBorder.none,
//                       isDense: true,
//                       contentPadding: EdgeInsets.symmetric(
//                         vertical: ResponsiveHelper.padding(8),
//                       ),
//                     ),
//                     style: TextStyle(
//                       color: AppColors.black,
//                       fontSize: ResponsiveHelper.fontSize(16),
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     final text = controller.messageController.text.trim();
//                     if (text.isEmpty) return;
//                     controller.sendGroupMessage(
//                       roomId: widget.roomId,
//                       message: text,
//                     );
//                   },
//                   child: Padding(
//                     padding: EdgeInsets.all(ResponsiveHelper.padding(8)),
//                     child: Icon(
//                       Icons.send_rounded,
//                       size: ResponsiveHelper.iconSize(24),
//                       color: AppColors.blueClient,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//
//         // ── Emoji Picker (unchanged) ─────────────────────
//         Offstage(
//           offstage: !_isEmojiVisible,
//           child: SizedBox(
//             height: ResponsiveHelper.height(250),
//             child: EmojiPicker(
//               textEditingController: controller.messageController,
//               config: Config(
//                 height: ResponsiveHelper.height(250),
//                 emojiViewConfig: EmojiViewConfig(
//                   columns: 7,
//                   emojiSizeMax: 28,
//                   verticalSpacing: 0,
//                   horizontalSpacing: 0,
//                   backgroundColor: Colors.white,
//                   noRecents: Text(
//                     'No recents yet',
//                     style: GoogleFonts.poppins(
//                       fontSize: 20,
//                       color: Colors.black26,
//                     ),
//                   ),
//                 ),
//                 categoryViewConfig: CategoryViewConfig(
//                   initCategory: Category.SMILEYS,
//                   indicatorColor: AppColors.blueClient,
//                   iconColor: Colors.grey,
//                   iconColorSelected: AppColors.blueClient,
//                   backspaceColor: Colors.red,
//                 ),
//                 bottomActionBarConfig: BottomActionBarConfig(
//                   showSearchViewButton: false,
//                 ),
//               ),
//             ),
//           ),
//         ),
//
//         SizedBox(height: ResponsiveHelper.height(16)),
//       ],
//     );
//   }
//
// // ── Shimmer chip ─────────────────────────────────────────────
//   Widget _presetShimmerChip() {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0.3, end: 1.0),
//       duration: const Duration(milliseconds: 900),
//       builder: (context, value, child) {
//         return Opacity(
//           opacity: value,
//           child: Container(
//             width: ResponsiveHelper.width(90),
//             height: ResponsiveHelper.height(36),
//             decoration: BoxDecoration(
//               color: AppColors.blueClient.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(
//                 ResponsiveHelper.borderRadius(20),
//               ),
//             ),
//           ),
//         );
//       },
//       onEnd: () => setState(() {}),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platchatapp/feature/chat/model/user_chat_model.dart';
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/chat/view/group/presentation/widgets/group_message_app_bar.dart';
import 'package:platchatapp/feature/chat/view/group/presentation/widgets/group_message_double.dart';
import 'package:platchatapp/feature/chat/view/group/presentation/widgets/group_message_input.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

import '../../../../../../helper/data_converter/data_converter.dart';

class GroupMessageScreen extends StatefulWidget {
  final String roomId;
  final String groupName;
  final String groupImage;
  final List<GroupMessage> groupMembers;

  const GroupMessageScreen({
    super.key,
    required this.roomId,
    required this.groupName,
    required this.groupImage,
    required this.groupMembers,
  });

  @override
  State<GroupMessageScreen> createState() => _GroupMessageScreenState();
}

class _GroupMessageScreenState extends State<GroupMessageScreen> {
  final ChatController controller = Get.find<ChatController>();
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();

    controller.groupRoomID.value = widget.roomId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ আগে join
      controller.joinGroup(roomId: widget.roomId);

      // ✅ তারপর fetch
      controller.fetchGroupMessages(roomId: widget.roomId, refresh: true);

      // ✅ সবার শেষে listen
      controller.listenGroupMessages();
    });

    _scrollController.addListener(_onScroll);
  }


  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        controller.hasMoreGroupMessage &&
        !controller.isLoadingMoreGroupMessage.value &&
        !controller.isLoadingGroupMessage.value) {
      controller.fetchGroupMessages(roomId: widget.roomId);
    }
  }

  @override
  void dispose() {
    controller.groupRoomID.value = '';
    _scrollController.dispose();
    controller.messageController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            SizedBox(height: ResponsiveHelper.height(20)),

            // ── App Bar ──────────────────────────────────────
            GroupMessageAppBar(
              roomId: widget.roomId,
              groupName: widget.groupName,
              groupImage: widget.groupImage,
            //  groupMembers: widget.groupMembers,
              controller: controller,
            ),

            // ── Messages List ────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoadingGroupMessage.value &&
                    controller.groupMessageList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.groupMessageList.isEmpty) {
                  return Center(
                    child: Text(
                      'no_messages'.tr,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveHelper.fontSize(16),
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.width(16),
                    vertical: ResponsiveHelper.height(8),
                  ),
                  itemCount: controller.groupMessageList.length + 1,
                  itemBuilder: (context, index) {
                    // Pagination loader at the end
                    if (index == controller.groupMessageList.length) {
                      return controller.isLoadingMoreGroupMessage.value
                          ?  Padding(
                        padding: ResponsiveHelper.all(8),
                        child: Center(child: CircularProgressIndicator()),
                      )
                          : const SizedBox.shrink();
                    }

                    final msg = controller.groupMessageList[index];
                    final bool isMine = msg.isMine == true;

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: ResponsiveHelper.height(8),
                      ),
                      child: GroupMessageBubble(
                        msg: msg,
                        isMine: isMine,
                        senderName: msg.sender?.nickName ?? '',
                        senderAvatar: msg.sender?.avatar ?? '',
                        text: msg.message ?? '',
                        time: formatTime(msg.createdAt ?? ''),
                      ),
                    );
                  },
                );
              }),
            ),

            // ── Message Input ────────────────────────────────
            GroupMessageInput(
              roomId: widget.roomId,
              controller: controller,
            ),
          ],
        ),
      ),
    );
  }

}