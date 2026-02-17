import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/custom_container/custom_container.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import '../repository/chat_controller.dart'; // Import your controller

class MessageScreen extends StatefulWidget {
  final String? roomId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String receiverId;

  const MessageScreen({
    super.key,
    this.roomId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.receiverId,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final ChatController chatController = Get.put(ChatController());
  //final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();



  @override
  void initState() {
    super.initState();

    debugPrint("📨 Opening chat - Receiver: ${widget.receiverId}, Room: ${widget.roomId}");

    // ⭐ Async initialization
    _initChat();

    // Scroll listener
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initChat() async {
    // Wait for build to complete
    await Future.delayed(Duration.zero);

    // Set room ID
    chatController.roomID.value = widget.roomId??"";

    // Fetch messages
    chatController.fetchRoomMessage(roomId: widget.roomId, refresh: true);

    debugPrint("✅ Chat initialized for room: ${widget.roomId}");
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100 &&
        chatController.hasMoreMessage &&
        !chatController.isLoadingMoreMessage.value) {
      chatController.fetchRoomMessage(roomId: widget.roomId);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    chatController.roomID.value = ""; // Clear room ID
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      // appBar: AppBar(
      //   leading: IconButton(
      //     onPressed: () async {
      //       chatController.fetchChatRooms();
      //       Navigator.pop(context);
      //     },
      //     icon: Icon(Icons.arrow_back),
      //   ),
      //   backgroundColor: Colors.white,
      //   centerTitle: true,
      //   title: Text(
      //     widget.otherUserName,
      //     style: TextStyle(fontSize: ResponsiveHelper.fontSize(18)),
      //   ),
      // ),
      body: RefreshIndicator(
        onRefresh: () => chatController.fetchRoomMessage(roomId: widget.roomId),
        child: Column(
          children: [
            SizedBox(height: ResponsiveHelper.height(20),),
            /// Fixed heading container
            CustomContainer(
              margin: EdgeInsets.all(ResponsiveHelper.padding(16)),
              vertical: ResponsiveHelper.padding(16),
              horizontal: ResponsiveHelper.padding(0),
              backgroundColor: AppColors.greyShade,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [


                      IconButton(
                        onPressed: () async {
                          chatController.fetchChatRooms();
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back,color: AppColors.black),
                      ),

                      CircleAvatar(
                        radius: ResponsiveHelper.borderRadius(22),
                        backgroundImage: NetworkImage(
                          ImageHandler.imagesHandle(
                            widget.otherUserAvatar,
                            isProfile: true,
                          ),
                        ),
                      ),
                      
                      SizedBox(width: ResponsiveHelper.spacing(12)),

                      Text(
                        widget.otherUserName,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveHelper.fontSize(16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.black),
                    color: AppColors.white,
                    onSelected: (value) {

                      print("Selected: $value");
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: "Block",
                        child: Row(
                          children: [
                            Icon(Icons.block,size: ResponsiveHelper.iconSize(16),color: AppColors.black,),
                            SizedBox(width: ResponsiveHelper.spacing(8),),
                            Text("Block",style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w400
                            ),),
                          ],
                        ),
                      ),


                    ],
                  ),
                 
                ],
              ),
            ),

            /// Chat messages list
            Expanded(
              child: Obx(() {
                final messages = chatController.userMessageList;

                // 🔹 Only first page loading
                if (chatController.isLoadingMessage.value && messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      "No messages yet",
                      style: TextStyle(color: Colors.grey),
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
                  itemCount:
                      messages.length + (chatController.hasMoreMessage ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      // 🔹 Only show bottom loading for pagination
                      return chatController.isLoadingMoreMessage.value
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : const SizedBox.shrink();
                    }

                    final msg = messages[index];
                    final bool isMine = msg.isMine == true;

                    return Align(
                      alignment: isMine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: ResponsiveHelper.width(272)),
                        margin: EdgeInsets.symmetric(
                          vertical: ResponsiveHelper.height(5),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveHelper.height(10),
                          horizontal: ResponsiveHelper.width(14),
                        ),
                        decoration: BoxDecoration(
                          color: isMine ? AppColors.blueBox : AppColors.black,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                              ResponsiveHelper.borderRadius(15),
                            ),
                            topRight: Radius.circular(
                              ResponsiveHelper.borderRadius(15),
                            ),
                            bottomLeft: isMine
                                ? Radius.circular(
                                    ResponsiveHelper.borderRadius(15),
                                  )
                                : Radius.zero,
                            bottomRight: isMine
                                ? Radius.zero
                                : Radius.circular(
                                    ResponsiveHelper.borderRadius(15),
                                  ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isMine
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.message ?? "",
                              style: GoogleFonts.poppins(color: AppColors.white),
                            ),
                            SizedBox(height: ResponsiveHelper.height(4)),
                            Text(
                              msg.createdAt != null
                                  ? DateFormat.jm().format(
                                      DateTime.parse(msg.createdAt!),
                                    )
                                  : "",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: ResponsiveHelper.fontSize(14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            /// Message Input Field
            _messageInput(),
          ],
        ),
      ),
    );
  }

  /// Message Input
  Widget _messageInput() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ResponsiveHelper.padding(16),
        ResponsiveHelper.padding(8),
        ResponsiveHelper.padding(16),
        ResponsiveHelper.padding(16),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.padding(16)),
        height: ResponsiveHelper.buttonHeight(56),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(16),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: chatController.messageController,
                decoration: InputDecoration(
                  hintText: 'Type here...',
                  fillColor: AppColors.black,
                  hintStyle: TextStyle(
                    color: Colors.white54,
                    fontSize: ResponsiveHelper.fontSize(16),
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveHelper.fontSize(16),
                ),
              ),
            ),

            GestureDetector(
              onTap: () async {
                debugPrint("========================");
                if (chatController.messageController.text.trim().isEmpty)
                  return;

                debugPrint("///////////////////////////////");

                chatController.sendNewEmitMessage(
                  receiverId: widget.receiverId,
                  message: chatController.messageController.text.toString(),
                );

                debugPrint(",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,");

                // chatController.messageController.clear();
              },
              child: SvgPicture.asset(AssetsPath.send),
            ),
          ],
        ),
      ),
    );
  }
}
