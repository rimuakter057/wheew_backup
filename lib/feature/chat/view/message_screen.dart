import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:platchatapp/helper/responsive_helper/responsive_helper.dart';
import 'package:platchatapp/share/widgets/custom_container/custom_container.dart';
import 'package:platchatapp/utils/assets_path/assets_path.dart';
import 'package:platchatapp/utils/color/app_colors.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  /// Sample message list (later socket.io messages will go here)
  final List<Map<String, dynamic>> messages = [
    {'text': 'Hi Georgina!', 'isMe': false},
    {'text': 'Hello! How are you?', 'isMe': true},
    {'text': 'I am good, thanks!', 'isMe': false},
    {'text': 'Great! Ready for today\'s task?', 'isMe': true},
  ];

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'inbox'.tr,
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
                  radius: ResponsiveHelper.width(22),
                  backgroundImage: const AssetImage(
                    'assets/images/person3.png',
                  ),
                ),
                SizedBox(width: ResponsiveHelper.spacing(12)),
                Text(
                  'Georgina',
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
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.width(16),
                vertical: ResponsiveHelper.height(8),
              ),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message['isMe'] as bool;

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      vertical: ResponsiveHelper.height(5),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveHelper.height(10),
                      horizontal: ResponsiveHelper.width(14),
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.blueBox : AppColors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: isMe
                            ? const Radius.circular(15)
                            : Radius.zero,
                        bottomRight: isMe
                            ? Radius.zero
                            : const Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: ResponsiveHelper.fontSize(12),
                      ),
                    ),
                  ),
                );
              },
            ),
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
              onTap: () {
                if (_controller.text.trim().isEmpty) return;
                setState(() {
                  messages.add({'text': _controller.text.trim(), 'isMe': true});
                  _controller.clear();
                });
              },
              child: SvgPicture.asset(AssetsPath.send),
            ),
          ],
        ),
      ),
    );
  }
}
