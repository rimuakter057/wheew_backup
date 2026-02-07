import 'package:flutter/material.dart';
import '../../../helper/responsive_helper/responsive_helper.dart';
import '../../../utils/extension/string_extension.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          _chatHeader(),

          /// Messages
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(ResponsiveHelper.padding(16)),
              children: [
                _leftBubble(
                  text: 'Heyy!!! Alexx',
                  delay: 0.0,
                ),
                _leftBubble(
                  text: 'when are we meeting its been so longgg since we meeted.',
                  delay: 0.2,
                ),
                _rightBubble(
                  text: 'Hyyy... georg.',
                  delay: 0.4,
                ),
                _rightBubble(
                  text: 'next week for sure.',
                  delay: 0.6,
                ),
                _rightBubble(
                  text:
                  'Lorem ipsum dolor sit amet\nI promise upcoming sun we will meet for sure.',
                  delay: 0.8,
                ),
              ],
            ),
          ),

          _messageInput(),
        ],
      ),
    );
  }

  /// Chat Header
  Widget _chatHeader() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.padding(12)),
      padding: EdgeInsets.all(ResponsiveHelper.padding(12)),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(ResponsiveHelper.borderRadius(16)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: ResponsiveHelper.width(22),
            backgroundImage: const AssetImage('assets/images/person3.png'),
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
    );
  }

  /// Left Message Bubble
  Widget _leftBubble({required String text, required double delay}) {
    return _animatedBubble(
      alignment: Alignment.centerLeft,
      offset: const Offset(-1, 0),
      color: Colors.black,
      textColor: Colors.white,
      text: text,
      delay: delay,
    );
  }

  /// Right Message Bubble
  Widget _rightBubble({required String text, required double delay}) {
    return _animatedBubble(
      alignment: Alignment.centerRight,
      offset: const Offset(1, 0),
      color: Colors.blue,
      textColor: Colors.white,
      text: text,
      delay: delay,
    );
  }

  /// Animated Bubble Core
  Widget _animatedBubble({
    required Alignment alignment,
    required Offset offset,
    required Color color,
    required Color textColor,
    required String text,
    required double delay,
  }) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(delay, 1, curve: Curves.easeOut),
    );

    return Align(
      alignment: alignment,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: offset,
          end: Offset.zero,
        ).animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: Container(
            margin: EdgeInsets.only(bottom: ResponsiveHelper.spacing(12)),
            padding: EdgeInsets.all(ResponsiveHelper.padding(14)),
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.width(260),
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.borderRadius(18),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: ResponsiveHelper.fontSize(14),
              ),
            ),
          ),
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
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.padding(16),
        ),
        height: ResponsiveHelper.buttonHeight(56),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.borderRadius(16),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Type here...',
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
                // send action
              },
              child: Icon(
                Icons.send_outlined,
                color: Colors.white,
                size: ResponsiveHelper.iconSize(22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}