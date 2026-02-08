import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:platchatapp/feature/profile/view/widgets/profile_avater_widgets.dart';
import 'package:platchatapp/helper/image_handler/image_handler.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/custom_container/custom_container.dart';
import 'package:platchatapp/utils/app_const/app_const.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';
import '../repository/chat_controller.dart'; // Import your controller

class MessageScreen extends StatefulWidget {
  final String roomId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String receiverId;

  const MessageScreen({
    super.key,
    required this.roomId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.receiverId,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final ChatController controller = Get.put(ChatController());
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    debugPrint("======================receiver id :${widget.receiverId}");

    controller.sendNewEmitMessage(
      receiverId:widget.receiverId,
      message: _controller.text.toString(),
    );


    controller.fetchRoomMessage(roomId: widget.roomId, refresh: true);

    // Scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100 &&
          controller.hasMoreMessage &&
          !controller.isLoadingMoreMessage.value) {
        // Load next page
        controller.fetchRoomMessage(roomId: widget.roomId);
      }
    });

  }




  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          widget.otherUserName,
          style: TextStyle(fontSize: ResponsiveHelper.fontSize(18)),
        ),
      ),
      body: Column(
        children: [
          /// Fixed heading container
          CustomContainer(
            margin: EdgeInsets.all(ResponsiveHelper.width(16)),
            backgroundColor: AppColors.greyShade,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(
                    ImageHandler.imagesHandle(widget.otherUserAvatar, isProfile: true),
                  ),
                ),





                SizedBox(width: ResponsiveHelper.spacing(12)),
                Text(
                  widget.otherUserName,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontSize(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          /// Chat messages list
          Expanded(
            child: Obx(() {
              final messages = controller.userMessageList;

              // 🔹 Only first page loading
              if (controller.isLoadingMessage.value && messages.isEmpty) {
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
                padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.width(16), vertical: ResponsiveHelper.height(8)),
                itemCount: messages.length + (controller.hasMoreMessage ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length) {
                    // 🔹 Only show bottom loading for pagination
                    return controller.isLoadingMoreMessage.value
                        ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(child: CircularProgressIndicator()),
                    )
                        : const SizedBox.shrink();
                  }

                  final msg = messages[index];
                  final bool isMine = msg.isMine == true;

                  return Align(
                    alignment:
                    isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        color: isMine ? AppColors.blueBox : AppColors.black,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(15),
                          topRight: const Radius.circular(15),
                          bottomLeft: isMine ? const Radius.circular(15) : Radius.zero,
                          bottomRight: isMine ? Radius.zero : const Radius.circular(15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.message ?? "",
                            style: const TextStyle(color: AppColors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            msg.createdAt != null
                                ? DateFormat.jm().format(DateTime.parse(msg.createdAt!))
                                : "",
                            style: const TextStyle(color: Colors.white54, fontSize: 10),
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
        padding:
        EdgeInsets.symmetric(horizontal: ResponsiveHelper.padding(16)),
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
                controller: _controller,
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
              onTap: () async{
                debugPrint("========================");
                if (_controller.text.trim().isEmpty) return;

                debugPrint("///////////////////////////////");


               await controller.sendNewEmitMessage(
                  receiverId:widget.receiverId,
                  message: _controller.text.toString(),
                );

                debugPrint(",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,");

                _controller.clear();
              },
              child: SvgPicture.asset(AssetsPath.send),
            ),



          ],
        ),
      ),
    );
  }


}
