// // ignore_for_file: prefer_final_fields
//
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart' hide Config;
// import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
// import 'package:platchatapp/feature/chat/view/widgets/block_by_me_widget.dart';
// import 'package:platchatapp/feature/chat/view/widgets/block_me_widget.dart';
// import 'package:platchatapp/feature/chat/view/widgets/message_screen_shimmer.dart';
// import 'package:platchatapp/feature/scan/presentation/widget/profile_card.dart';
// import 'package:platchatapp/helper/image_handler/image_handler.dart';
// import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
// import 'package:platchatapp/share/widgets/custom_container/custom_container.dart';
// import 'package:platchatapp/utils/app_const/app_const.dart';
// import 'package:platchatapp/utils/assets_path/assets_path.dart';
// import 'package:platchatapp/utils/color/app_colors.dart';
// import 'package:platchatapp/utils/extension/base_extension.dart';
//
// import '../../../../../../utils/string/bad_words.dart';
//
// class MessageScreen extends StatefulWidget {
//   final String? roomId;
//   final String otherUserName;
//   final String? otherUserAvatar;
//   final String receiverId;
//   final bool? isBlockedByMe;
//   final bool? isBlockedMe;
//
//   const MessageScreen({
//     super.key,
//     this.roomId,
//     required this.otherUserName,
//     this.otherUserAvatar,
//     required this.receiverId,
//     this.isBlockedByMe,
//     this.isBlockedMe,
//   });
//
//   @override
//   State<MessageScreen> createState() => _MessageScreenState();
// }
//
// class _MessageScreenState extends State<MessageScreen> {
//   final ChatController chatController = Get.put(ChatController());
//   //final TextEditingController messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//
//   // ✅ State variables
//   bool _isEmojiVisible = false;
//   FocusNode _focusNode = FocusNode();
//   late String _currentRoomId;
//
//   @override
//   void initState() {
//     super.initState();
//     _currentRoomId = widget.roomId ?? '';
//
//     chatController.isBlockedByMe.value = widget.isBlockedByMe ?? false;
//     chatController.isBlockedMe.value = widget.isBlockedMe ?? false;
//     chatController.fetchPresetMessages();
//
//     _initChat();
//
//     // ✅ Scroll listener যোগ করুন
//     _scrollController.addListener(_onScroll);
//
//     _focusNode.addListener(() {
//       if (_focusNode.hasFocus && _isEmojiVisible) {
//         setState(() => _isEmojiVisible = false);
//       }
//     });
//   }
//
//   Future<void> _initChat() async {
//     await Future.delayed(Duration.zero);
//     chatController.userMessageList.clear();
//     chatController.page.value = 1; // ✅ Page reset
//     chatController.roomID.value = widget.roomId ?? '';
//
//     if (_currentRoomId.isNotEmpty) {
//       chatController.fetchInboxMessage(roomId: _currentRoomId, refresh: true);
//     }
//   }
//
//   void _onScroll() {
//     if (!_scrollController.hasClients) return;
//
//     final pos = _scrollController.position;
//
//     // reverse:true ListView-এ উপরে scroll = maxScrollExtent এর কাছে যাওয়া
//     if (pos.pixels >= pos.maxScrollExtent - 200 &&
//         chatController.hasMoreMessage &&
//         !chatController.isLoadingMoreMessage.value) {
//       final roomId = _currentRoomId.isNotEmpty
//           ? _currentRoomId
//           : chatController.roomID.value;
//
//       if (roomId.isNotEmpty) {
//         chatController.fetchInboxMessage(
//           roomId: roomId,
//         ); // ✅ refresh নেই, পুরনো data load
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll); // ✅ listener remove করুন
//     _scrollController.dispose();
//     _focusNode.dispose();
//     chatController.roomID.value = '';
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//
//       body: RefreshIndicator(
//         onRefresh: () =>
//             chatController.fetchInboxMessage(roomId: widget.roomId),
//         child: Column(
//           children: [
//             SizedBox(height: ResponsiveHelper.height(20)),
//
//             /// Fixed heading container
//             CustomContainer(
//               margin: EdgeInsets.all(ResponsiveHelper.padding(16)),
//               vertical: ResponsiveHelper.padding(16),
//               horizontal: ResponsiveHelper.padding(0),
//               backgroundColor: AppColors.greyShade,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       IconButton(
//                         onPressed: () async {
//                           //TO DO: Clear messages and room ID when going back
//                           chatController.page.value = 1; // Reset pagination
//                           chatController.fetchChatList(refresh: false);
//                           Navigator.pop(context);
//                         },
//                         icon: Icon(Icons.arrow_back, color: AppColors.black),
//                       ),
//
//                       CircleAvatar(
//                         radius: ResponsiveHelper.borderRadius(22),
//                         backgroundImage: NetworkImage(
//                           ImageHandler.imagesHandle(
//                             widget.otherUserAvatar,
//                             isProfile: true,
//                           ),
//                         ),
//                       ),
//
//                       SizedBox(width: ResponsiveHelper.spacing(12)),
//
//                       Text(
//                         widget.otherUserName,
//                         style: GoogleFonts.poppins(
//                           fontSize: ResponsiveHelper.fontSize(16),
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.black,
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   PopupMenuButton<String>(
//                     icon: Icon(Icons.more_vert, color: AppColors.black),
//                     onSelected: (value) async {
//                       if (value == "Block") {
//                         chatController.block(widget.receiverId, context);
//                         chatController.isBlockedByMe.value = true;
//                       } else if (value == "Unblock") {
//                         chatController.unBlock(widget.receiverId, context);
//                         chatController.isBlockedByMe.value = false;
//                       } else if (value == "Rate") {
//                         await chatController.fetchMyRating(widget.receiverId);
//                         if (!context.mounted) return;
//                         _showRatingDialog(
//                           context: context,
//                           image: widget.otherUserAvatar ?? AppConst.unknown,
//                           name: widget.otherUserName,
//                           receiverId: widget.receiverId,
//                         );
//                       } else if (value == "ViewProfile") {
//                         showDialog(
//                           context: context,
//                           builder: (context) => Dialog(
//                             backgroundColor: Colors.transparent,
//                             child: ProfileCard(
//                               name: 'Rimu',
//                               rating: 4.8,
//                               address: 'address',
//                               showRating: true,
//                             ),
//                           ),
//                         );
//                       }
//                     },
//                     itemBuilder: (context) => [
//                       // ── View Profile ──────────────────────────
//                       PopupMenuItem<String>(
//                         value: "ViewProfile",
//                         child: Row(
//                           children: [
//                             Icon(Icons.person_outline_rounded, color: AppColors.black),
//                             SizedBox(width: 8),
//                             Text('view_profile'.tr),
//                           ],
//                         ),
//                       ),
//
//                       // ── Rate ──────────────────────────────────
//                       PopupMenuItem<String>(
//                         value: "Rate",
//                         child: Row(
//                           children: [
//                             Icon(Icons.star_rate_outlined, color: Colors.black),
//                             SizedBox(width: 8),
//                             Text('rate_user'.tr),
//                           ],
//                         ),
//                       ),
//
//                       // ── Block / Unblock ───────────────────────
//                       PopupMenuItem<String>(
//                         value: chatController.isBlockedByMe.value
//                             ? "Unblock"
//                             : "Block",
//                         child: Obx(
//                           () => Row(
//                             children: [
//                               Icon(
//                                 chatController.isBlockedByMe.value
//                                     ? Icons.lock_open
//                                     : Icons.block,
//                               ),
//                               SizedBox(width: 8),
//                               Text(
//                                 chatController.isBlockedByMe.value
//                                     ? "unblock".tr
//                                     : "block_".tr,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//
//                 ],
//               ),
//             ),
//
//             /// Chat messages list
//             Expanded(
//               child: Obx(() {
//                 final messages = chatController.userMessageList;
//
//                 // 🔹 Only first page loading
//                 if (chatController.isLoadingMessage.value && messages.isEmpty) {
//                   return MessageScreenShimmer(); //Center(child: LoadingWidget(color: AppColors.blue));
//                 }
//
//                 if (messages.isEmpty) {
//                   return Center(
//                     child: Text(
//                       'no_messages_yet'.tr,
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   );
//                 }
//
//                 return ListView.builder(
//                   controller: _scrollController,
//                   reverse: true,
//                   padding: ResponsiveHelper.symmetric(
//                     horizontal: ResponsiveHelper.width(16),
//                     vertical: ResponsiveHelper.height(8),
//                   ),
//                   itemCount:
//                       messages.length + (chatController.hasMoreMessage ? 1 : 0),
//                   itemBuilder: (context, index) {
//                     // ✅ এটা উপরে দেখাবে (reverse:true তে শেষ index = screen এর উপরে)
//                     if (index == messages.length) {
//                       return Obx(
//                         () => chatController.isLoadingMoreMessage.value
//                             ? const Padding(
//                                 padding: EdgeInsets.all(12),
//                                 child: Center(
//                                   child: CircularProgressIndicator(),
//                                 ),
//                               )
//                             : const SizedBox.shrink(),
//                       );
//                     }
//
//                     final msg = messages[index];
//                     final bool isMine = msg.isMine == true;
//
//                     return Align(
//                       alignment: isMine
//                           ? Alignment.centerRight
//                           : Alignment.centerLeft,
//                       child: Container(
//                         constraints: BoxConstraints(
//                           maxWidth: ResponsiveHelper.width(272),
//                         ),
//                         margin: EdgeInsets.symmetric(
//                           vertical: ResponsiveHelper.height(5),
//                         ),
//                         padding: EdgeInsets.symmetric(
//                           vertical: ResponsiveHelper.height(10),
//                           horizontal: ResponsiveHelper.width(14),
//                         ),
//                         decoration: BoxDecoration(
//                           color: isMine
//                               ? AppColors.blueClient
//                               : AppColors.greenClient,
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(
//                               ResponsiveHelper.borderRadius(15),
//                             ),
//                             topRight: Radius.circular(
//                               ResponsiveHelper.borderRadius(15),
//                             ),
//                             bottomLeft: isMine
//                                 ? Radius.circular(
//                                     ResponsiveHelper.borderRadius(15),
//                                   )
//                                 : Radius.zero,
//                             bottomRight: isMine
//                                 ? Radius.zero
//                                 : Radius.circular(
//                                     ResponsiveHelper.borderRadius(15),
//                                   ),
//                           ),
//                         ),
//                         child: Text(
//                           msg.message ?? "",
//                           style: GoogleFonts.poppins(color: AppColors.white),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               }),
//             ),
//     ///input field======================
//             Obx(() {
//               if (chatController.isBlockedByMe.value == true) {
//                 return BlockByMeWidget(
//                   name: widget.otherUserName,
//                   onUnblock: () {
//                     chatController.unBlock(widget.receiverId, context);
//                     chatController.isBlockedByMe.value = false;
//                   },
//                 );
//               } else if (chatController.isBlockedMe.value == true) {
//                 return const BlockMeWidget();
//               } else if (chatController.isBlockedByMe.value == false &&
//                   chatController.isBlockedMe.value == false) {
//                 return _messageInput();
//               } else {
//                 return _messageInput();
//               }
//             }),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Message Input
//
//   Widget _messageInput() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // ── Preset Messages ──────────────────────────
//         Obx(() {
//           if (chatController.isPresetLoading.value) {
//             return SizedBox(
//               height: ResponsiveHelper.height(40),
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 padding: EdgeInsets.symmetric(
//                   horizontal: ResponsiveHelper.padding(16),
//                 ),
//                 itemCount: 5, // skeleton count
//                 separatorBuilder: (_, __) =>
//                     SizedBox(width: ResponsiveHelper.spacing(8)),
//                 itemBuilder: (context, index) {
//                   return _presetShimmerChip();
//                 },
//               ),
//             );
//           }
//
//           if (chatController.presetMessages.isEmpty) {
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
//               itemCount: chatController.presetMessages.length,
//               separatorBuilder: (_, __) =>
//                   SizedBox(width: ResponsiveHelper.spacing(8)),
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onTap: () {
//                     chatController.messageController.text =
//                     chatController.presetMessages[index];
//                     chatController.messageController.selection =
//                         TextSelection.fromPosition(
//                           TextPosition(
//                             offset:
//                             chatController.messageController.text.length,
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
//                       chatController.presetMessages[index],
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
//         // ── Text Input Row ───────────────────────────
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
//               borderRadius: BorderRadius.circular(
//                 ResponsiveHelper.borderRadius(16),
//               ),
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 // Emoji Button
//                 IconButton(
//                   icon: const Icon(
//                     Icons.emoji_emotions,
//                     color: AppColors.black,
//                   ),
//                   onPressed: () {
//                     _focusNode.unfocus();
//                     setState(() => _isEmojiVisible = !_isEmojiVisible);
//                   },
//                 ),
//
//                 // Text Field
//                 Expanded(
//                   child: TextField(
//                     focusNode: _focusNode,
//                     controller: chatController.messageController,
//                     minLines: 1,
//                     maxLines: 3,
//                     onTap: () {
//                       if (_isEmojiVisible) {
//                         setState(() => _isEmojiVisible = false);
//                       }
//                     },
//                     decoration: InputDecoration(
//                       hintText: "type_here1".tr,
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
//
//                 // Send Button
//                 GestureDetector(
//                   onTap: () {
//                     String message =
//                     chatController.messageController.text.trim();
//                     if (message.isEmpty) return;
//
//                     bool containsBadWord =
//                         BadWords.english.any(
//                               (word) => message.toLowerCase().contains(
//                             word.toLowerCase(),
//                           ),
//                         ) ||
//                             BadWords.italian.any(
//                                   (word) => message.toLowerCase().contains(
//                                 word.toLowerCase(),
//                               ),
//                             );
//
//                     if (containsBadWord) {
//                       showTopSnackBar(context, "bad_word_error".tr);
//                       return;
//                     }
//
//                     chatController.sendNewEmitMessage(
//                       receiverId: widget.receiverId,
//                       message: message,
//                       roomId: _currentRoomId,
//                     );
//
//                     Future.delayed(const Duration(milliseconds: 500), () {
//                       if (_currentRoomId.isEmpty &&
//                           chatController.roomID.value.isNotEmpty) {
//                         setState(() {
//                           _currentRoomId = chatController.roomID.value;
//                         });
//                       }
//                     });
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
//         // ── Emoji Picker ─────────────────────────────
//         Offstage(
//           offstage: !_isEmojiVisible,
//           child: SizedBox(
//             height: ResponsiveHelper.height(250),
//             child: EmojiPicker(
//               textEditingController: chatController.messageController,
//               config: Config(
//                 height: ResponsiveHelper.height(250),
//                 emojiViewConfig: EmojiViewConfig(
//                   columns: 7,
//                   emojiSizeMax: 28,
//                   verticalSpacing: 0,
//                   horizontalSpacing: 0,
//                   backgroundColor: Colors.white,
//                   noRecents: Text(
//                     'no_recents_yet'.tr,
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
// // ── Shimmer Chip for preset loading ─────────────
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
//               borderRadius:
//               BorderRadius.circular(ResponsiveHelper.borderRadius(20)),
//             ),
//           ),
//         );
//       },
//       onEnd: () => setState(() {}), // pulse effect
//     );
//   }
// }
// ///=emoji==================================
// void showTopSnackBar(BuildContext context, String message) {
//   OverlayEntry overlayEntry = OverlayEntry(
//     builder: (context) => Positioned(
//       top: 50, // Top position
//       left: 16,
//       right: 16,
//       child: Material(
//         color: Colors.transparent,
//         child: Container(
//           padding: ResponsiveHelper.all(16),
//           decoration: BoxDecoration(
//             color: Colors.red.shade700,
//             borderRadius: BorderRadius.circular(
//               ResponsiveHelper.borderRadius(12),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 6,
//                 offset: Offset(0, 3),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.error_outline, color: Colors.white),
//               SizedBox(width: ResponsiveHelper.padding(12)),
//               Expanded(
//                 child: Text(
//                   message,
//                   style: GoogleFonts.poppins(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: ResponsiveHelper.fontSize(16),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
//
//   Overlay.of(context).insert(overlayEntry);
//
//   // Remove after 3 seconds
//   Future.delayed(Duration(seconds: 3)).then((_) => overlayEntry.remove());
// }
//
// ///show rating-=========================
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
// void _showRatingDialog({
//   required BuildContext context,
//   required String image,
//   required String name,
//   required String receiverId,
// }) {
//   final ChatController chatController = Get.find<ChatController>();
//   final int existing =
//       chatController.myRatingForRatee.value?.rating ?? 0;
//   double ratingValue = existing >= 1 && existing <= 5
//       ? existing.toDouble()
//       : 0;
//
//   final bool isUpdate =
//       (chatController.myRatingForRatee.value?.id.isNotEmpty == true);
//
//   showDialog(
//     context: context,
//     barrierDismissible: true,
//     barrierColor: Colors.black.withOpacity(0.5),
//     builder: (_) => StatefulBuilder(
//       builder: (dialogContext, setState) => Dialog(
//         backgroundColor: Colors.transparent,
//         insetPadding: EdgeInsets.symmetric(
//           horizontal: ResponsiveHelper.spacing(24),
//         ),
//         child: Container(
//           padding: EdgeInsets.only(
//             top: ResponsiveHelper.spacing(20),
//             left: ResponsiveHelper.spacing(20),
//             right: ResponsiveHelper.spacing(20),
//             bottom: ResponsiveHelper.spacing(24),
//           ),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(
//               ResponsiveHelper.borderRadius(24),
//             ),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // ── Close Button ──────────────────────────
//               Align(
//                 alignment: Alignment.topRight,
//                 child: GestureDetector(
//                   onTap: () => Navigator.pop(dialogContext),
//                   child: Container(
//                     padding: EdgeInsets.all(ResponsiveHelper.spacing(4)),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.close,
//                       size: ResponsiveHelper.iconSize(16),
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: ResponsiveHelper.spacing(4)),
//
//               // ── Avatar ───────────────────────────────
//               CircleAvatar(
//                 radius: ResponsiveHelper.borderRadius(30),
//                 backgroundImage: NetworkImage(
//                   ImageHandler.imagesHandle(image, isProfile: true),
//                 ),
//               ),
//
//               SizedBox(height: ResponsiveHelper.spacing(10)),
//
//               // ── Name ─────────────────────────────────
//               Text(
//                 name,
//                 style: GoogleFonts.poppins(
//                   fontSize: ResponsiveHelper.fontSize(16),
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.black,
//                 ),
//               ),
//
//               SizedBox(height: ResponsiveHelper.spacing(4)),
//
//               Text(
//                 isUpdate ? 'update_your_rating'.tr : 'tap_to_rate'.tr,
//                 style: GoogleFonts.poppins(
//                   fontSize: ResponsiveHelper.fontSize(12),
//                   color: Colors.grey.shade400,
//                 ),
//               ),
//
//               SizedBox(height: ResponsiveHelper.spacing(24)),
//
//               // ── Star rating (1–5, integer) ─────────────
//               SizedBox(
//                 height: ResponsiveHelper.iconSize(50),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(5, (starIndex) {
//                     final starValue = starIndex + 1;
//                     return GestureDetector(
//                       onTap: () => setState(() => ratingValue = starValue.toDouble()),
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: ResponsiveHelper.spacing(2),
//                         ),
//                         child: _buildStarIcon(starIndex, ratingValue),
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//
//               SizedBox(height: ResponsiveHelper.spacing(8)),
//
//               // ── Rating Label ──────────────────────────
//               AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 200),
//                 child: Text(
//                   key: ValueKey(ratingValue),
//                   _ratingLabel(ratingValue),
//                   style: GoogleFonts.poppins(
//                     fontSize: ResponsiveHelper.fontSize(14),
//                     color: ratingValue < 1
//                         ? Colors.transparent
//                         : Colors.amber.shade700,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: ResponsiveHelper.spacing(28)),
//
//               // ── Submit / Update Button ────────────────
//               Obx(() => SizedBox(
//                 width: double.infinity,
//                 height: ResponsiveHelper.buttonHeight(48),
//                 child: ElevatedButton(
//                   onPressed: (ratingValue < 1 ||
//                       chatController.isSubmittingRating.value)
//                       ? null
//                       : () {
//                     chatController.submitRating(
//                       rateeId: receiverId,
//                       rating: ratingValue,
//                       context: dialogContext,
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.blueClient,
//                     disabledBackgroundColor: Colors.grey.shade200,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(
//                         ResponsiveHelper.borderRadius(12),
//                       ),
//                     ),
//                   ),
//                   child: chatController.isSubmittingRating.value
//                       ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: Colors.white,
//                     ),
//                   )
//                       : Text(
//                     isUpdate ? 'update_rating'.tr : 'submit_rating'.tr,
//                     style: GoogleFonts.poppins(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                       fontSize: ResponsiveHelper.fontSize(14),
//                     ),
//                   ),
//                 ),
//               )),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }
//
// // ── Star icon builder (full / half / empty) ──────────────────
// Widget _buildStarIcon(int starIndex, double rating) {
//   final double value = rating - starIndex;
//
//   IconData icon;
//   Color color = Colors.amber;
//
//   if (value >= 1.0) {
//     icon = Icons.star_rounded; // full
//   } else if (value >= 0.5) {
//     icon = Icons.star_half_rounded; // half
//   } else {
//     icon = Icons.star_outline_rounded; // empty
//     color = Colors.grey.shade300;
//   }
//
//   return Icon(
//     icon,
//     color: color,
//     size: ResponsiveHelper.iconSize(44),
//   );
// }
//
// // ── Rating label helper ──────────────────────────────────────
// String _ratingLabel(double rating) {
//   if (rating == 0) return '';
//   if (rating <= 1.0) return 'rating_poor'.tr;
//   if (rating <= 2.0) return 'rating_fair'.tr;
//   if (rating <= 3.0) return 'rating_good'.tr;
//   if (rating <= 4.0) return 'rating_great'.tr;
//   return 'rating_excellent'.tr;
// }
//
//
//
//
// // void _showRatingDialog({
// //   required BuildContext context,
// //   required String image,
// //   required String name,
// // })
// // {
// //   double _rating = 0;
// //   final TextEditingController _commentController = TextEditingController();
// //
// //   showDialog(
// //     context: context,
// //     barrierDismissible: true,
// //     barrierColor: Colors.black.withOpacity(0.5),
// //     builder: (_) => StatefulBuilder(
// //       builder: (context, setState) => Dialog(
// //         backgroundColor: Colors.transparent,
// //         insetPadding: EdgeInsets.symmetric(
// //           horizontal: ResponsiveHelper.spacing(24),
// //         ),
// //         child: Container(
// //           padding: EdgeInsets.only(
// //             top: ResponsiveHelper.spacing(20),
// //             left: ResponsiveHelper.spacing(20),
// //             right: ResponsiveHelper.spacing(20),
// //             bottom: ResponsiveHelper.spacing(24),
// //           ),
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(
// //               ResponsiveHelper.borderRadius(24),
// //             ),
// //           ),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               // ── Close Button ──────────────────────────
// //               Align(
// //                 alignment: Alignment.topRight,
// //                 child: GestureDetector(
// //                   onTap: () => Navigator.pop(context),
// //                   child: Container(
// //                     padding: EdgeInsets.all(ResponsiveHelper.spacing(4)),
// //                     decoration: BoxDecoration(
// //                       color: Colors.grey.shade100,
// //                       shape: BoxShape.circle,
// //                     ),
// //                     child: Icon(
// //                       Icons.close,
// //                       size: ResponsiveHelper.iconSize(16),
// //                       color: Colors.grey.shade600,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //
// //               SizedBox(height: ResponsiveHelper.spacing(4)),
// //
// //               // // ── Avatar ────────────────────────────────
// //               CircleAvatar(
// //                 radius: ResponsiveHelper.borderRadius(22),
// //                 backgroundImage: NetworkImage(
// //                   ImageHandler.imagesHandle(
// //                     image,
// //                     isProfile: true,
// //                   ),
// //                 ),
// //               ),
// //
// //
// //               SizedBox(height: ResponsiveHelper.spacing(10)),
// //
// //               // ── Name ──────────────────────────────────
// //               // Text(
// //               //   name, // ✅ parameter থেকে
// //               //   style: TextStyle(
// //               //     fontSize: ResponsiveHelper.fontSize(16),
// //               //     fontWeight: FontWeight.bold,
// //               //     color: Colors.black,
// //               //   ),
// //               // ),
// //
// //               // Name
// //               Text(
// //                 name,
// //                 style: context.bodyMedium.copyWith(color: AppColors.black)
// //               ),
// //
// //               SizedBox(height: ResponsiveHelper.spacing(8)),
// //
// //               // Rating and Location
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   Icon(Icons.star, color: Colors.orange, size: ResponsiveHelper.iconSize(18)),
// //                  // SizedBox(width: 4),
// //                   Text(
// //                     "4.6",
// //                     style: context.bodySmall
// //                   ),
// //                   SizedBox(width: ResponsiveHelper.spacing(10)),
// //                   Icon(Icons.location_on, color: Colors.grey, size: ResponsiveHelper.iconSize(18)),
// //                   SizedBox(width: 4),
// //                   Text(
// //                     "address",
// //                     style: context.bodySmall
// //                   ),
// //                 ],
// //               ),
// //
// //
// //
// //
// //               SizedBox(height: ResponsiveHelper.spacing(20)),
// //
// //               // ── Star Rating ───────────────────────────
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: List.generate(5, (index) {
// //                   return GestureDetector(
// //                     onTap: () => setState(() => _rating = index + 1),
// //                     child: Padding(
// //                       padding: EdgeInsets.symmetric(
// //                         horizontal: ResponsiveHelper.spacing(4),
// //                       ),
// //                       child: Icon(
// //                         index < _rating
// //                             ? Icons.star_rounded
// //                             : Icons.star_outline_rounded,
// //                         color: Colors.amber,
// //                         size: ResponsiveHelper.iconSize(40),
// //                       ),
// //                     ),
// //                   );
// //                 }),
// //               ),
// //
// //               SizedBox(height: ResponsiveHelper.spacing(6)),
// //
// //               // ── Rating Label ──────────────────────────
// //               Text(
// //                 _rating == 0
// //                     ? ''
// //                     : _rating == 1
// //                     ? 'rating_poor'.tr
// //                     : _rating == 2
// //                     ? 'rating_fair'.tr
// //                     : _rating == 3
// //                     ? 'rating_good'.tr
// //                     : _rating == 4
// //                     ? 'rating_great'.tr
// //                     : 'rating_excellent'.tr,
// //                 style: TextStyle(
// //                   fontSize: ResponsiveHelper.fontSize(13),
// //                   color: Colors.grey.shade500,
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //               ),
// //
// //               SizedBox(height: ResponsiveHelper.spacing(16)),
// //
// //               // ── Comment ───────────────────────────────
// //               TextField(
// //                 controller: _commentController,
// //                 maxLines: 3,
// //                 style: TextStyle(fontSize: ResponsiveHelper.fontSize(13)),
// //                 decoration: InputDecoration(
// //                   hintText: 'add_comment'.tr,
// //                   hintStyle: TextStyle(
// //                     fontSize: ResponsiveHelper.fontSize(13),
// //                     color: Colors.grey.shade400,
// //                   ),
// //                   contentPadding: EdgeInsets.all(ResponsiveHelper.spacing(12)),
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(
// //                       ResponsiveHelper.borderRadius(12),
// //                     ),
// //                     borderSide: BorderSide(color: Colors.grey.shade200),
// //                   ),
// //                   enabledBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(
// //                       ResponsiveHelper.borderRadius(12),
// //                     ),
// //                     borderSide: BorderSide(color: Colors.grey.shade200),
// //                   ),
// //                   focusedBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(
// //                       ResponsiveHelper.borderRadius(12),
// //                     ),
// //                     borderSide: BorderSide(color: AppColors.black),
// //                   ),
// //                 ),
// //               ),
// //
// //               SizedBox(height: ResponsiveHelper.spacing(20)),
// //
// //               // ── Submit Button ─────────────────────────
// //               SizedBox(
// //                 width: double.infinity,
// //                 height: ResponsiveHelper.buttonHeight(48),
// //                 child: ElevatedButton(
// //                   onPressed: () {},
// //
// //                   // onPressed: _rating == 0
// //                   //     ? null
// //                   //     : () {
// //                   //   Navigator.pop(context);
// //                   //   chatController.submitRating(
// //                   //     receiverId: widget.receiverId,
// //                   //     rating: _rating,
// //                   //     comment: _commentController.text.trim(),
// //                   //     context: context,
// //                   //   );
// //                   // },
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: AppColors.blueClient,
// //                     disabledBackgroundColor: Colors.grey.shade200,
// //                     elevation: 0,
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(
// //                         ResponsiveHelper.borderRadius(12),
// //                       ),
// //                     ),
// //                   ),
// //                   child: Text(
// //                     'submit_rating'.tr,
// //                     style: context.bodySmall.copyWith(color: AppColors.white)
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     ),
// //   );
// // }
// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:platchatapp/feature/chat/repository/chat_controller.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/widgets/message_appbar.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/widgets/message_double.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/widgets/message_input.dart';
import 'package:platchatapp/feature/chat/view/message/presentation/widgets/rating_dialog.dart';
import 'package:platchatapp/feature/chat/view/widgets/block_by_me_widget.dart';
import 'package:platchatapp/feature/chat/view/widgets/block_me_widget.dart';
import 'package:platchatapp/feature/chat/view/widgets/message_screen_shimmer.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/utils/color/app_colors.dart';


class MessageScreen extends StatefulWidget {
  final String? roomId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String receiverId;
  final bool? isBlockedByMe;
  final bool? isBlockedMe;

  const MessageScreen({
    super.key,
    this.roomId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.receiverId,
    this.isBlockedByMe,
    this.isBlockedMe,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final ChatController chatController = Get.put(ChatController());
  final ScrollController _scrollController = ScrollController();
  late String _currentRoomId;

  @override
  void initState() {
    super.initState();
    _currentRoomId = widget.roomId ?? '';

    chatController.isBlockedByMe.value = widget.isBlockedByMe ?? false;
    chatController.isBlockedMe.value = widget.isBlockedMe ?? false;
    chatController.fetchPresetMessages();

    _initChat();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initChat() async {
    await Future.delayed(Duration.zero);
    chatController.userMessageList.clear();
    chatController.page.value = 1;
    chatController.roomID.value = widget.roomId ?? '';

    if (_currentRoomId.isNotEmpty) {
      chatController.fetchInboxMessage(roomId: _currentRoomId, refresh: true);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200 &&
        chatController.hasMoreMessage &&
        !chatController.isLoadingMoreMessage.value) {
      final roomId = _currentRoomId.isNotEmpty
          ? _currentRoomId
          : chatController.roomID.value;
      if (roomId.isNotEmpty) {
        chatController.fetchInboxMessage(roomId: roomId);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    chatController.roomID.value = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        onRefresh: () =>
            chatController.fetchInboxMessage(roomId: widget.roomId),
        child: Column(
          children: [
            SizedBox(height: ResponsiveHelper.height(20)),

            // ── App Bar ──────────────────────────────────────
            MessageAppBar(
              otherUserName: widget.otherUserName,
              otherUserAvatar: widget.otherUserAvatar,
              receiverId: widget.receiverId,
              chatController: chatController,
              onRateTap: () async {
                await chatController.fetchMyRating(widget.receiverId);
                if (!context.mounted) return;
                showRatingDialog(
                  context: context,
                  image: widget.otherUserAvatar ?? '',
                  name: widget.otherUserName,
                  receiverId: widget.receiverId,
                );
              },
            ),

            // ── Messages List ────────────────────────────────
            Expanded(
              child: Obx(() {
                final messages = chatController.userMessageList;

                if (chatController.isLoadingMessage.value &&
                    messages.isEmpty) {
                  return MessageScreenShimmer();
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'no_messages_yet'.tr,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: ResponsiveHelper.symmetric(
                    horizontal: ResponsiveHelper.width(16),
                    vertical: ResponsiveHelper.height(8),
                  ),
                  itemCount: messages.length +
                      (chatController.hasMoreMessage ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Pagination loader
                    if (index == messages.length) {
                      return Obx(
                            () => chatController.isLoadingMoreMessage.value
                            ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                            : const SizedBox.shrink(),
                      );
                    }

                    final msg = messages[index];
                    final bool isMine = msg.isMine == true;

                    return MessageBubble(
                      message: msg.message ?? '',
                      isMine: isMine,
                    );
                  },
                );
              }),
            ),

            // ── Input / Block Widgets ─────────────────────────
            Obx(() {
              if (chatController.isBlockedByMe.value) {
                return BlockByMeWidget(
                  name: widget.otherUserName,
                  onUnblock: () {
                    chatController.unBlock(widget.receiverId, context);
                    chatController.isBlockedByMe.value = false;
                  },
                );
              } else if (chatController.isBlockedMe.value) {
                return const BlockMeWidget();
              } else {
                return MessageInput(
                  chatController: chatController,
                  currentRoomId: _currentRoomId,
                  receiverId: widget.receiverId,
                  onRoomIdUpdate: (newId) {
                    setState(() => _currentRoomId = newId);
                  },
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}